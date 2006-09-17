Date: Sun, 17 Sep 2006 05:41:25 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
In-Reply-To: <20060917041707.28171868.pj@sgi.com>
Message-ID: <Pine.LNX.4.64.0609170540020.14516@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
 <20060914220011.2be9100a.akpm@osdl.org> <20060914234926.9b58fd77.pj@sgi.com>
 <20060915002325.bffe27d1.akpm@osdl.org> <20060915004402.88d462ff.pj@sgi.com>
 <20060915010622.0e3539d2.akpm@osdl.org> <Pine.LNX.4.63.0609151601230.9416@chino.corp.google.com>
 <Pine.LNX.4.63.0609161734220.16748@chino.corp.google.com>
 <20060917041707.28171868.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: David Rientjes <rientjes@google.com>, akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 17 Sep 2006, Paul Jackson wrote:

> Aha - notice the following code in kernel/cpuset.c:
> 
> int __cpuset_zone_allowed(struct zone *z, gfp_t gfp_mask)
> {
>         int node;                       /* node that zone z is on */
>         ...
>         node = z->zone_pgdat->node_id;
> 
> Looks like an open coded zone_to_nid() invocation that wasn't
> addressed by Christoph's patch.
> 
> Tsk tsk ... shame on whomever open coded that one ;).

Are you sure that you are looking at a current tree? This is zone_to_nid 
here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
