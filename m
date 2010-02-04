Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id A81336B0047
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 22:31:14 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o143V9Zf022877
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 4 Feb 2010 12:31:09 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2CB5145DE51
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 12:31:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0C7E845DE62
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 12:31:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D3696EF8003
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 12:31:08 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 86DD9E78003
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 12:31:08 +0900 (JST)
Date: Thu, 4 Feb 2010 12:27:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [stable] [PATCH] devmem: check vmalloc address on kmem
 read/write
Message-Id: <20100204122742.2e1c38f8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100204031854.GA14324@localhost>
References: <20100122045914.993668874@intel.com>
	<20100203234724.GA23902@kroah.com>
	<20100204024202.GD6343@localhost>
	<20100204115801.cac7c342.kamezawa.hiroyu@jp.fujitsu.com>
	<20100204031854.GA14324@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Greg KH <greg@kroah.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@suse.de>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "stable@kernel.org" <stable@kernel.org>, "juha_motorsportcom@luukku.com" <juha_motorsportcom@luukku.com>
List-ID: <linux-mm.kvack.org>

On Thu, 4 Feb 2010 11:18:54 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> On Thu, Feb 04, 2010 at 10:58:01AM +0800, KAMEZAWA Hiroyuki wrote:
> > On Thu, 4 Feb 2010 10:42:02 +0800
> > Wu Fengguang <fengguang.wu@intel.com> wrote:
> > 
> > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > 
> > > commit 325fda71d0badc1073dc59f12a948f24ff05796a upstream.
> > > 
> > > Otherwise vmalloc_to_page() will BUG().
> > > 
> > > This also makes the kmem read/write implementation aligned with mem(4):
> > > "References to nonexistent locations cause errors to be returned." Here
> > > we return -ENXIO (inspired by Hugh) if no bytes have been transfered
> > > to/from user space, otherwise return partial read/write results.
> > > 
> > 
> > Wu-san, I have additonal fix to this patch. Now, *ppos update is unstable..
> > Could you make merged one ?
> > Maybe this one makes the all behavior clearer.
> > 
> > ==
> > This is a more fix for devmem-check-vmalloc-address-on-kmem-read-write.patch
> > Now, the condition for updating *ppos is not good. (it's updated even if EFAULT
> > occurs..). This fixes that.
> > 
> > 
> > Reported-by: "Juha Leppanen" <juha_motorsportcom@luukku.com>
> 
> Sorry, can you elaborate the problem? How it break the application?
> 
> It looks that do_generic_file_read() also updates *ppos progressively,
> no one complains about that.
> 
Ah...it seems I misunderstood something...ok, *ppos should be updated every time.

I startted from adding comment on following line and got into a maze.

>   return (virtr + wrote) ? : err;

Sorry for noise.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
