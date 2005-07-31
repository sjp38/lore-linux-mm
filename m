Date: Sun, 31 Jul 2005 05:52:34 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: get_user_pages() with write=1 and force=1 gets read-only pages.
Message-ID: <20050731105234.GA2254@lnx-holt.americas.sgi.com>
References: <20050730205319.GA1233@lnx-holt.americas.sgi.com> <Pine.LNX.4.61.0507302255390.5143@goblin.wat.veritas.com> <42EC2ED6.2070700@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <42EC2ED6.2070700@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Hugh Dickins <hugh@veritas.com>, Robin Holt <holt@sgi.com>, Roland McGrath <roland@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Should there be a check to ensure we don't return VM_FAULT_RACE when the
pte which was inserted is exactly the same one we would have inserted?
Could we generalize that more to the point of only returning VM_FAULT_RACE
when write access was requested but the racing pte was not writable?

Most of the test cases I have thrown at this have gotten the writer
faulting first which did not result in problems.  I would hate to slow
things down if not necessary.  I am unaware of more issues than the one
I have been tripping.

Thanks,
Robin Holt
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
