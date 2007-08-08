Date: Tue, 7 Aug 2007 17:14:31 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH 1/2][UPDATED] hugetlb: search harder for memory in
 alloc_fresh_huge_page()
In-Reply-To: <20070807230200.GC15714@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0708071714060.5001@schroedinger.engr.sgi.com>
References: <20070807171432.GY15714@us.ibm.com> <1186517722.5067.31.camel@localhost>
 <20070807221240.GB15714@us.ibm.com> <Pine.LNX.4.64.0708071553440.4438@schroedinger.engr.sgi.com>
 <20070807230200.GC15714@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, anton@samba.org, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 7 Aug 2007, Nishanth Aravamudan wrote:

> Which change? Using nid without a VM_BUG_ON (as in the original patch)
> or adding a VM_BUG_ON and using page_to_nid()?

Adding VM_BUG_ON. If page_alloc does not work then something basic is 
broken.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
