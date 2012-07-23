Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 1DEAD6B005A
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 04:25:18 -0400 (EDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1StDx0-00056a-I5
	for linux-mm@kvack.org; Mon, 23 Jul 2012 10:25:10 +0200
Received: from 112.132.186.225 ([112.132.186.225])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Mon, 23 Jul 2012 10:25:10 +0200
Received: from xiyou.wangcong by 112.132.186.225 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Mon, 23 Jul 2012 10:25:10 +0200
From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH RESEND v2 3/3] mm/sparse: remove index_init_lock
Date: Mon, 23 Jul 2012 08:20:18 +0000 (UTC)
Message-ID: <juj1g2$qh3$2@dough.gmane.org>
References: <1343010702-28720-1-git-send-email-shangw@linux.vnet.ibm.com>
 <1343010702-28720-3-git-send-email-shangw@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

On Mon, 23 Jul 2012 at 02:31 GMT, Gavin Shan <shangw@linux.vnet.ibm.com> wrote:
> sparse_index_init uses index_init_lock spinlock to protect root
> mem_section assignment. The lock is not necessary anymore because the
> function is called only during the boot (during paging init which
> is executed only from a single CPU) and from the hotplug code (by
> add_memory via arch_add_memory) which uses mem_hotplug_mutex.
>
> The lock has been introduced by 28ae55c9 (sparsemem extreme: hotplug
> preparation) and sparse_index_init was used only during boot at that
> time.
>
> Later when the hotplug code (and add_memory) was introduced there was
> no synchronization so it was possible to online more sections from
> the same root probably (though I am not 100% sure about that).
> The first synchronization has been added by 6ad696d2 (mm: allow memory
> hotplug and hibernation in the same kernel) which has been later
> replaced by the mem_hotplug_mutex - 20d6c96b (mem-hotplug: introduce
> {un}lock_memory_hotplug()).
>
> Let's remove the lock as it is not needed and it makes the code more
> confusing.
>
> [mhocko@suse.cz: changelog]
> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
> Reviewed-by: Michal Hocko <mhocko@suse.cz>

Reviewed-by: Cong Wang <xiyou.wangcong@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
