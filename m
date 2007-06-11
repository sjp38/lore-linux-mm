Date: Mon, 11 Jun 2007 16:45:30 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH v4] Add populated_map to account for memoryless nodes
In-Reply-To: <20070611234155.GG14458@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0706111642450.24042@schroedinger.engr.sgi.com>
References: <20070611202728.GD9920@us.ibm.com>
 <Pine.LNX.4.64.0706111417540.20454@schroedinger.engr.sgi.com>
 <20070611221036.GA14458@us.ibm.com> <Pine.LNX.4.64.0706111537250.20954@schroedinger.engr.sgi.com>
 <20070611225213.GB14458@us.ibm.com> <Pine.LNX.4.64.0706111559490.21107@schroedinger.engr.sgi.com>
 <20070611234155.GG14458@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: lee.schermerhorn@hp.com, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Jun 2007, Nishanth Aravamudan wrote:

> Eep, except that we don't initialize node_populated_mask unless we're
> NUMA. Also, do you think it's worth adding the comment in mmzone.h that
> now now NUMA policies depend on present_pages?

No need to initialize if we do not use it. You may to #ifdef it out
by moving the definition. Please sent a diff against the earlier patch 
since Andrew already merged it.

present_pages just indicates that there is memory on the node. So I am not 
sure that this will help.

> +
> +	/*
> +	 * record populated zones for use when INTERLEAVE'ing or using
> +	 * GFP_THISNODE
> +	 */

There may be other purposes as well. No need to enumerate those here.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
