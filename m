Date: Mon, 11 Jun 2007 19:25:08 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH v6][RFC] Fix hugetlb pool allocation with empty nodes
In-Reply-To: <Pine.LNX.4.64.0706111921370.25134@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0706111923580.25207@schroedinger.engr.sgi.com>
References: <20070611202728.GD9920@us.ibm.com>
 <Pine.LNX.4.64.0706111417540.20454@schroedinger.engr.sgi.com>
 <20070611221036.GA14458@us.ibm.com> <Pine.LNX.4.64.0706111537250.20954@schroedinger.engr.sgi.com>
 <20070611225213.GB14458@us.ibm.com> <20070611230829.GC14458@us.ibm.com>
 <20070611231008.GD14458@us.ibm.com> <Pine.LNX.4.64.0706111615450.23857@schroedinger.engr.sgi.com>
 <20070612001542.GJ14458@us.ibm.com> <Pine.LNX.4.64.0706111745491.24389@schroedinger.engr.sgi.com>
 <20070612021245.GH3798@us.ibm.com> <Pine.LNX.4.64.0706111921370.25134@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Jun 2007, Christoph Lameter wrote:

> On Mon, 11 Jun 2007, Nishanth Aravamudan wrote:
> 
> > static int nid = first_node(node_populated_map), I get:
> > 
> > mm/hugetlb.c:108: error: initializer element is not constant
> 
> Remove the static.

Cutting down the CCs.

Removing static wont help if the variable is still global. You need to 
define a local variable. Then it can be initialized with a variable 
expression.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
