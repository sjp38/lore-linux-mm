Subject: Re: [RFC][PATCH 1/2][UPDATED] hugetlb: search harder for memory in
	alloc_fresh_huge_page()
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0708071553440.4438@schroedinger.engr.sgi.com>
References: <20070807171432.GY15714@us.ibm.com>
	 <1186517722.5067.31.camel@localhost> <20070807221240.GB15714@us.ibm.com>
	 <Pine.LNX.4.64.0708071553440.4438@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Wed, 08 Aug 2007 09:17:28 -0400
Message-Id: <1186579048.5055.5.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, anton@samba.org, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2007-08-07 at 15:54 -0700, Christoph Lameter wrote:
> On Tue, 7 Aug 2007, Nishanth Aravamudan wrote:
> 
> > > 
> > > Not that I don't trust __GFP_THISNODE, but may I suggest a
> > > "VM_BUG_ON(page_to_nid(page) != nid)" -- up above the spin_lock(), of
> > > course.  Better yet, add the assertion and drop this one line change?
> 
> Dont do this change.

[being equally terse] Why?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
