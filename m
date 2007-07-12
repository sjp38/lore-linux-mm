Date: Thu, 12 Jul 2007 11:38:32 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 07/12] Memoryless nodes: SLUB support
In-Reply-To: <20070712183323.GD10067@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0707121138220.10793@schroedinger.engr.sgi.com>
References: <20070711182219.234782227@sgi.com> <20070711182251.433134748@sgi.com>
 <20070711170736.f6c304d3.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0707111835130.3806@schroedinger.engr.sgi.com>
 <20070712183323.GD10067@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, kxr@sgi.com, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 12 Jul 2007, Nishanth Aravamudan wrote:

> This description is out of date. There is no for_each_memory_node() any
> more, I think you meant for_each_node_state().

Correct.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
