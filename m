Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B34396B02A4
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 00:31:53 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6T4VoKl004441
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 29 Jul 2010 13:31:50 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5188545DE4F
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 13:31:50 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 27E8945DE4E
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 13:31:50 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F7391DB8038
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 13:31:50 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BA1E71DB803E
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 13:31:49 +0900 (JST)
Date: Thu, 29 Jul 2010 13:27:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 1/7][memcg] virtually indexed array library.
Message-Id: <20100729132703.2d53e8a4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100729093226.7b899930.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100727165155.8b458b7f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100727165303.7d7d18e9.kamezawa.hiroyu@jp.fujitsu.com>
	<20100728124513.85bfa047.akpm@linux-foundation.org>
	<20100729093226.7b899930.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, gthelen@google.com, m-ikeda@ds.jp.nec.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 29 Jul 2010 09:32:26 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Wed, 28 Jul 2010 12:45:13 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
 
> > My gut reaction to this sort of thing is "run away in terror".  It
> > encourages kernel developers to operate like lackadaisical userspace
> > developers and to assume that underlying code can perform heroic and
> > immortal feats.  But it can't.  This is the kernel and the kernel is a
> > tough and hostile place and callers should be careful and defensive and
> > take great efforts to minimise the strain they put upon other systems.
> > 
> > IOW, can we avoid doing this?
> > 
> 

I'll use pre-allocated pointer array in the next version. It's simple even
if a bit slow.

==
struct mem_cgroup *mem_cgroups[CONFIG_MAX_MEM_CGROUPS] __read_mostly;
#define id_to_memcg(id)		mem_cgroups[id];
==
But this can use hugepage-mapping-for-kernel...so, can be quick.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
