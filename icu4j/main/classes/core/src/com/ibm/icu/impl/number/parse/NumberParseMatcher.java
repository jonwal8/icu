// © 2017 and later: Unicode, Inc. and others.
// License & terms of use: http://www.unicode.org/copyright.html#License
package com.ibm.icu.impl.number.parse;

import com.ibm.icu.text.UnicodeSet;

/**
 * @author sffc
 *
 */
public interface NumberParseMatcher {
    /**
     * Runs this matcher starting at the beginning of the given StringSegment. If this matcher finds something
     * interesting in the StringSegment, it should update the offset of the StringSegment corresponding to how many
     * chars were matched.
     *
     * @param segment
     *            The StringSegment to match against. Matches always start at the beginning of the segment. The segment
     *            is guaranteed to contain at least one char.
     * @param result
     *            The data structure to store results if the match succeeds.
     * @return Whether this matcher thinks there may be more interesting chars beyond the end of the string segment.
     */
    public boolean match(StringSegment segment, ParsedNumber result);

    /**
     * Should return a set representing all possible chars (UTF-16 code units) that could be the first char that this
     * matcher can consume. This method is only called during construction phase, and its return value is used to skip
     * this matcher unless a segment begins with a char in this set. To make this matcher always run, return
     * {@link UnicodeSet#ALL_CODE_POINTS}.
     */
    public UnicodeSet getLeadChars(boolean ignoreCase);

    /**
     * Method called at the end of a parse, after all matchers have failed to consume any more chars. Allows a matcher
     * to make final modifications to the result given the knowledge that no more matches are possible.
     *
     * @param result
     *            The data structure to store results.
     */
    public void postProcess(ParsedNumber result);
}
