Date: Sun, 17 Nov 2002 17:12:01 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: get_user_pages rewrite rediffed against 2.5.47-mm1
Message-ID: <20021118011201.GD11776@holomorphy.com>
References: <20021112205848.B5263@nightmaster.csn.tu-chemnitz.de> <3DD1642A.4A7C663C@digeo.com> <20021115085827.Z659@nightmaster.csn.tu-chemnitz.de> <3DD56256.C0911282@digeo.com> <20021118002710.B659@nightmaster.csn.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20021118002710.B659@nightmaster.csn.tu-chemnitz.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Cc: Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Nov 18, 2002 at 12:27:10AM +0100, Ingo Oeser wrote:
> Most of the page walking users got simpler and also the
> hugetlb code looks much better now. 
> The diffstat shows 554 deletions and 224 additions, which is not
> too bad for a cleanup, which also adds a feature.
> BTW: make_pages_present needs a rewrite, because it duplicates
>    work from its callers. The only non-trivial user is mm/mremap.c,
>    the rest of it I could do.
> Comments are VERY welcome. bzip2ed patch attached.
> Regards
> Ingo Oeser

Terrific. Bringing the hugetlb code closer to Linux-native idioms/style
is excellent. From my POV the change has no visible deficits remaining.


Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
