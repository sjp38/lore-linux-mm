Date: Tue, 7 Aug 2007 15:54:36 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH 1/2][UPDATED] hugetlb: search harder for memory in
 alloc_fresh_huge_page()
In-Reply-To: <20070807221240.GB15714@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0708071553440.4438@schroedinger.engr.sgi.com>
References: <20070807171432.GY15714@us.ibm.com> <1186517722.5067.31.camel@localhost>
 <20070807221240.GB15714@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, anton@samba.org, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 7 Aug 2007, Nishanth Aravamudan wrote:

> > 
> > Not that I don't trust __GFP_THISNODE, but may I suggest a
> > "VM_BUG_ON(page_to_nid(page) != nid)" -- up above the spin_lock(), of
> > course.  Better yet, add the assertion and drop this one line change?

Dont do this change.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
