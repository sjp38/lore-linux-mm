Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id EF3726B01F4
	for <linux-mm@kvack.org>; Tue, 20 Apr 2010 21:03:36 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3L13XhC014054
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 21 Apr 2010 10:03:33 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2408B45DE4F
	for <linux-mm@kvack.org>; Wed, 21 Apr 2010 10:03:33 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id F00F545DE4E
	for <linux-mm@kvack.org>; Wed, 21 Apr 2010 10:03:32 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D8B82E08006
	for <linux-mm@kvack.org>; Wed, 21 Apr 2010 10:03:32 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8E2CDE08003
	for <linux-mm@kvack.org>; Wed, 21 Apr 2010 10:03:32 +0900 (JST)
Date: Wed, 21 Apr 2010 09:59:35 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: repost - RFC [Patch] Remove
 "please try 'cgroup_disable=memory' option if you don't want memory cgroups"
 printk at boot time.
Message-Id: <20100421095935.54109d78.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4BCE4D34.5050200@cn.fujitsu.com>
References: <1271773587.28748.134.camel@dhcp-100-19-198.bos.redhat.com>
	<20100421092502.787371b5.kamezawa.hiroyu@jp.fujitsu.com>
	<4BCE4D34.5050200@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Larry Woodman <lwoodman@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 21 Apr 2010 08:56:20 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:

> > My biggest concern is that we don't have man(5) cgroup as other file systems.
> > If we have man(5), the best place for this kind of information will be it.
> > I think most of users will never see kernel-parameter.txt ..
> > 
> > If usual distros are shipped with man(5) cgroup, I agree removing
> > this in upstream.
> > (We have man pages for libcgroup but not man(5) for cgroup file system.)
> > 
> > I'm sorry if I don't notice that the latest man package has cgroup section.
> > 
> 
> We have a man-page for cpuset, which was written by Paul Jackson,
> the author of cpuset.
> 
But there is no description about "cpuset can be mounted as cgroup".

Maybe there are no updates for 2 years even if it exists.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
