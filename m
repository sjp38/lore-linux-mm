Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2D5D46B0038
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 12:34:55 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id y51so6723689wry.6
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 09:34:55 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 196si14268407wmg.65.2017.02.27.09.34.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 27 Feb 2017 09:34:54 -0800 (PST)
Date: Mon, 27 Feb 2017 18:34:51 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, hotplug: get rid of auto_online_blocks
Message-ID: <20170227173451.GR26504@dhcp22.suse.cz>
References: <20170227092817.23571-1-mhocko@kernel.org>
 <20170227172852.t52egmv743fi26ds@arbab-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170227172852.t52egmv743fi26ds@arbab-laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, linux-api@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-s390@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org

On Mon 27-02-17 11:28:52, Reza Arbab wrote:
> On Mon, Feb 27, 2017 at 10:28:17AM +0100, Michal Hocko wrote:
> >diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> >index 134a2f69c21a..a72f7f64ee26 100644
> >--- a/include/linux/memory_hotplug.h
> >+++ b/include/linux/memory_hotplug.h
> >@@ -100,8 +100,6 @@ extern void __online_page_free(struct page *page);
> >
> >extern int try_online_node(int nid);
> >
> >-extern bool memhp_auto_online;
> >-
> >#ifdef CONFIG_MEMORY_HOTREMOVE
> >extern bool is_pageblock_removable_nolock(struct page *page);
> >extern int arch_remove_memory(u64 start, u64 size);
> >@@ -272,7 +270,7 @@ static inline void remove_memory(int nid, u64 start, u64 size) {}
> >
> >extern int walk_memory_range(unsigned long start_pfn, unsigned long end_pfn,
> >		void *arg, int (*func)(struct memory_block *, void *));
> >-extern int add_memory(int nid, u64 start, u64 size);
> >+extern int add_memory(int nid, u64 start, u64 size, bool online);
> >extern int add_memory_resource(int nid, struct resource *resource, bool online);
> >extern int zone_for_memory(int nid, u64 start, u64 size, int zone_default,
> >		bool for_device);
> 
> It would be nice if instead of a 'bool online' argument, add_memory() and
> add_memory_resource() took an 'int online_type', ala online_pages().
> 
> That way we could specify offline, online, online+movable, etc.

Sure that would require more changes though and as such it is out of
scope of this patch. But you are right, this is a logical follow up
step.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
