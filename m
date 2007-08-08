Subject: Re: [RFC][PATCH 1/2][UPDATED] hugetlb: search harder for memory in
	alloc_fresh_huge_page()
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070808013256.GE15714@us.ibm.com>
References: <20070807171432.GY15714@us.ibm.com>
	 <1186517722.5067.31.camel@localhost> <20070807221240.GB15714@us.ibm.com>
	 <Pine.LNX.4.64.0708071553440.4438@schroedinger.engr.sgi.com>
	 <20070807230200.GC15714@us.ibm.com>
	 <Pine.LNX.4.64.0708071714060.5001@schroedinger.engr.sgi.com>
	 <20070808013256.GE15714@us.ibm.com>
Content-Type: text/plain
Date: Wed, 08 Aug 2007 09:20:29 -0400
Message-Id: <1186579229.5055.8.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Christoph Lameter <clameter@sgi.com>, anton@samba.org, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2007-08-07 at 18:32 -0700, Nishanth Aravamudan wrote:
> On 07.08.2007 [17:14:31 -0700], Christoph Lameter wrote:
> > On Tue, 7 Aug 2007, Nishanth Aravamudan wrote:
> > 
> > > Which change? Using nid without a VM_BUG_ON (as in the original patch)
> > > or adding a VM_BUG_ON and using page_to_nid()?
> > 
> > Adding VM_BUG_ON. If page_alloc does not work then something basic is 
> > broken.
> 
> I agree. So perhaps there needs to be a VM_BUG_ON_ONCE() or something
> somewhere in the core code for the case of a __GFP_THISNODE allocation
> going off node?

That would work for me.  But, I would like to see us use the existing
page_to_nid() for the accounting.  I like to avoid silent corruption of
the accounting.  Things will work--for a while anyway--if pages get
returned on the wrong node and the accounting gets messed up.  But, it
can result in non-obvious problems some time later.  I hate it when that
happens :-).

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
