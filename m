Date: Mon, 24 Sep 2007 12:07:44 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/4] hugetlb: search harder for memory in alloc_fresh_huge_page()
In-Reply-To: <20070924162220.GA26104@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0709241207220.29673@schroedinger.engr.sgi.com>
References: <20070906182134.GA7779@us.ibm.com> <20070914172638.GT24941@us.ibm.com>
 <Pine.LNX.4.64.0709141041390.15683@schroedinger.engr.sgi.com>
 <20070924162220.GA26104@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: wli@holomorphy.com, agl@us.ibm.com, lee.schermerhorn@hp.com, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 24 Sep 2007, Nishanth Aravamudan wrote:

> Yes, I'll keep tracking -mm with my series. I wonder, though, if it
> would be possible to at least get the bugfixes for memoryless nodes in
> hugetlb code (patches 1 and 2) in to -mm sooner rather than later (I can
> fix your issues with the static variable, I hope). The other two patches
> are more feature-like, so can be postponed for now.

Sure. Please post them and CC me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
