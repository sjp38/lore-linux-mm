Date: Mon, 11 Sep 2000 11:45:20 -0600
From: Neil Schemenauer <nascheme@enme.ucalgary.ca>
Subject: Re: [PATCH] Page aging for 2.4.0-test8
Message-ID: <20000911114520.A22732@keymaster.enme.ucalgary.ca>
References: <20000910214150.A30532@acs.ucalgary.ca> <Pine.LNX.4.21.0009111311220.21018-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.21.0009111311220.21018-100000@duckman.distro.conectiva>; from Rik van Riel on Mon, Sep 11, 2000 at 01:12:32PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 11, 2000 at 01:12:32PM -0300, Rik van Riel wrote:
> Your idea /heavily/ penalises libc and executable pages by aging them
> more often than anonymous pages...

I don't think I age anonymous pages any more than any other type of
page.  Perhaps you are saying that shared pages should recieve some
bonus?  That is a different issue and it is handled naturally with my
patch.  If shared pages are actually used then PageTouch() will be
called on them more often.  This should work better than the current
PG_referenced bit.

Prehaps I am missing your point.  Can you explain in more detail how
these pages are aged more often?

  Neil
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
