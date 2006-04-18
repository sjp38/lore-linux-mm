Date: Mon, 17 Apr 2006 18:57:40 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 5/5] Swapless V2: Revise main migration logic
In-Reply-To: <20060418094212.3ece222f.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0604171856290.2986@schroedinger.engr.sgi.com>
References: <20060413235406.15398.42233.sendpatchset@schroedinger.engr.sgi.com>
 <20060413235432.15398.23912.sendpatchset@schroedinger.engr.sgi.com>
 <20060414101959.d59ac82d.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0604131832020.16220@schroedinger.engr.sgi.com>
 <20060414113455.15fd5162.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0604140945320.18453@schroedinger.engr.sgi.com>
 <20060415090639.dde469e8.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0604151040450.25886@schroedinger.engr.sgi.com>
 <20060417091830.bca60006.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0604170958100.29732@schroedinger.engr.sgi.com>
 <20060418090439.3e2f0df4.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0604171724070.2752@schroedinger.engr.sgi.com>
 <20060418094212.3ece222f.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: akpm@osdl.org, hugh@veritas.com, linux-kernel@vger.kernel.org, lee.schermerhorn@hp.com, linux-mm@kvack.org, taka@valinux.co.jp, marcelo.tosatti@cyclades.com
List-ID: <linux-mm.kvack.org>

On Tue, 18 Apr 2006, KAMEZAWA Hiroyuki wrote:

> BTW, when copying mm, mm->mmap_sem is held. Is mm->mmap_sem is not held while 
> page migraion now ? I'm sorry I can't catch up all changes.
> or Is this needed for lazy migration (migration-on-fault) ?

mmap_sem must be held during page migration due to the way we retrieve the 
anonymous vma.

I think you would want to get rid of that requirement for the hotplug 
remove. But how do we reliably get to the anon_vma of the page without 
mmap_sem?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
