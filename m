Date: Thu, 03 Apr 2003 10:39:37 -0600
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: [PATCH 2.5.66-mm2] Fix page_convert_anon locking issues
Message-ID: <23590000.1049387977@baldur.austin.ibm.com>
In-Reply-To: <Pine.LNX.4.44.0304031727420.2014-100000@localhost.localdomain>
References: <Pine.LNX.4.44.0304031727420.2014-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

--On Thursday, April 03, 2003 17:33:31 +0100 Hugh Dickins
<hugh@veritas.com> wrote:

> No: see the various checks on page_count(page) in vmscan.c:
> though page_convert_anon temporarily leaves a page with neither
> mapcount nor the right number of pte pointers, page_count is unaffected.

Oh, hmm... Ok, so it's safe... This could have some interesting
implications all around.

Dave

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
