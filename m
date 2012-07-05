Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 82BE86B0071
	for <linux-mm@kvack.org>; Thu,  5 Jul 2012 09:26:45 -0400 (EDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1Smm4s-0007Yh-Bn
	for linux-mm@kvack.org; Thu, 05 Jul 2012 15:26:38 +0200
Received: from 117.57.98.8 ([117.57.98.8])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Thu, 05 Jul 2012 15:26:38 +0200
Received: from xiyou.wangcong by 117.57.98.8 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Thu, 05 Jul 2012 15:26:38 +0200
From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH 4/4] mm/hotplug: mark memory hotplug code in
 page_alloc.c as __meminit
Date: Thu, 5 Jul 2012 13:26:21 +0000 (UTC)
Message-ID: <jt44ls$lq0$2@dough.gmane.org>
References: <1341481532-1700-1-git-send-email-jiang.liu@huawei.com>
 <1341481532-1700-4-git-send-email-jiang.liu@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

On Thu, 05 Jul 2012 at 09:45 GMT, Jiang Liu <jiang.liu@huawei.com> wrote:
> Mark functions used by both boot and memory hotplug as __meminit to reduce
> memory footprint when memory hotplug is disabled.
>
> Alos guard zone_pcp_update() with CONFIG_MEMORY_HOTPLUG because it's only
> used by memory hotplug code.
>

If so, why not move it to mm/memory_hotplug.c and make it static?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
