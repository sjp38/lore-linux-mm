Date: Mon, 27 Feb 2006 18:43:08 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: page_lock_anon_vma(): remove check for mapped page
In-Reply-To: <Pine.LNX.4.64.0602271028240.3185@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.61.0602271839450.9471@goblin.wat.veritas.com>
References: <Pine.LNX.4.64.0602241658030.24668@schroedinger.engr.sgi.com>
 <Pine.LNX.4.61.0602251400520.7164@goblin.wat.veritas.com>
 <Pine.LNX.4.61.0602260359080.9682@goblin.wat.veritas.com>
 <Pine.LNX.4.64.0602252152500.29338@schroedinger.engr.sgi.com>
 <Pine.LNX.4.61.0602261558370.13368@goblin.wat.veritas.com>
 <Pine.LNX.4.64.0602270748280.2419@schroedinger.engr.sgi.com>
 <Pine.LNX.4.61.0602271608510.8280@goblin.wat.veritas.com>
 <Pine.LNX.4.64.0602270837460.2849@schroedinger.engr.sgi.com>
 <Pine.LNX.4.61.0602271658240.8669@goblin.wat.veritas.com>
 <Pine.LNX.4.64.0602270934260.3185@schroedinger.engr.sgi.com>
 <Pine.LNX.4.61.0602271823260.9352@goblin.wat.veritas.com>
 <Pine.LNX.4.64.0602271028240.3185@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 27 Feb 2006, Christoph Lameter wrote:
> 
> The check_mapped can be done in a different way since there is no need
> for an rcu lock because we now have the requirement to hold 
> mmap_sem for protection.

You're right, I hadn't thought of it that way round, you're
better off simply avoiding page_lock_anon_vma for your usage.

Acked-by: Hugh Dickins <hugh@veritas.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
