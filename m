Date: Mon, 11 Jun 2007 09:12:45 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH v2] gfp.h: GFP_THISNODE can go to other nodes if some
 are unpopulated
In-Reply-To: <466D44C6.6080105@shadowen.org>
Message-ID: <Pine.LNX.4.64.0706110911080.15326@schroedinger.engr.sgi.com>
References: <20070607150425.GA15776@us.ibm.com>
 <Pine.LNX.4.64.0706071103240.24988@schroedinger.engr.sgi.com>
 <20070607220149.GC15776@us.ibm.com> <466D44C6.6080105@shadowen.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, Lee.Schermerhorn@hp.com, anton@samba.org, mel@csn.ul.ie, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Jun 2007, Andy Whitcroft wrote:

> Its strange behaviour for sure.  The users of this in the slab are not
> getting what they expected.  So its possible they would also want
> something similar to what you are proposing for hugetlbfs.  I also
> wonder if the name should be changed to GFP_NEARTHISNODE or something.

Well maybe we better fix this? I put an effort into using only cachelines 
already used for GFP_THISNODE since this is in a very performance 
critical path but at that point I was not thinking that we 
would have memoryless nodes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
