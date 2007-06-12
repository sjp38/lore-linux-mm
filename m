Date: Mon, 11 Jun 2007 19:55:21 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH v6][RFC] Fix hugetlb pool allocation with empty nodes
In-Reply-To: <20070612023421.GL3798@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0706111954360.25390@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0706111537250.20954@schroedinger.engr.sgi.com>
 <20070611225213.GB14458@us.ibm.com> <20070611230829.GC14458@us.ibm.com>
 <20070611231008.GD14458@us.ibm.com> <Pine.LNX.4.64.0706111615450.23857@schroedinger.engr.sgi.com>
 <20070612001542.GJ14458@us.ibm.com> <Pine.LNX.4.64.0706111745491.24389@schroedinger.engr.sgi.com>
 <20070612021245.GH3798@us.ibm.com> <Pine.LNX.4.64.0706111921370.25134@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0706111923580.25207@schroedinger.engr.sgi.com>
 <20070612023421.GL3798@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Jun 2007, Nishanth Aravamudan wrote:

> nid is static to alloc_fresh_huge_page().

Ahh did not see that. Can you not call simply into interleave() from 
mempolicy.c? It will get you the counter that you need.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
