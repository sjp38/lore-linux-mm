Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 0CEA66B01F5
	for <linux-mm@kvack.org>; Tue, 20 Apr 2010 20:29:04 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3L0T2uA028066
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 21 Apr 2010 09:29:02 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 758F045DE52
	for <linux-mm@kvack.org>; Wed, 21 Apr 2010 09:29:01 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 93AC345DE4F
	for <linux-mm@kvack.org>; Wed, 21 Apr 2010 09:28:58 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7C3AE1DB803A
	for <linux-mm@kvack.org>; Wed, 21 Apr 2010 09:28:58 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2CA661DB804B
	for <linux-mm@kvack.org>; Wed, 21 Apr 2010 09:28:55 +0900 (JST)
Date: Wed, 21 Apr 2010 09:25:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: repost - RFC [Patch] Remove
 "please try 'cgroup_disable=memory' option if you don't want memory cgroups"
 printk at boot time.
Message-Id: <20100421092502.787371b5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1271773587.28748.134.camel@dhcp-100-19-198.bos.redhat.com>
References: <1271773587.28748.134.camel@dhcp-100-19-198.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Larry Woodman <lwoodman@redhat.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 20 Apr 2010 10:26:27 -0400
Larry Woodman <lwoodman@redhat.com> wrote:

> Re-posting, cc'ing linux-mm as requested:
> 
> We are considering removing this printk at boot time from RHEL because
> it will confuse customers, encourage them to change the boot parameters
> and generate extraneous support calls.  Its documented in
> Documentation/kernel-parameters.txt anyway.  Any thoughts???
> 
> Larry Woodman
> 
For RHEL, I agree removing the message makes sense.
But I'm unsure that small machine users, who never use memcg, can notice some
amount of memory are eaten at boot time.

Many distro tends to enable memcg by default and consume memory.

 	printk(KERN_INFO "allocated %ld bytes of page_cgroup\n", total_usage);
-	printk(KERN_INFO "please try 'cgroup_disable=memory' option if you"
-	" don't want memory cgroups\n");

Hmm.

	printk(KERN_INFO "If you don't want page_cgroup,
			  you can disable this by boot option, cgroup_disable=memory".)

My biggest concern is that we don't have man(5) cgroup as other file systems.
If we have man(5), the best place for this kind of information will be it.
I think most of users will never see kernel-parameter.txt ..

If usual distros are shipped with man(5) cgroup, I agree removing
this in upstream.
(We have man pages for libcgroup but not man(5) for cgroup file system.)

I'm sorry if I don't notice that the latest man package has cgroup section.

Bye,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
