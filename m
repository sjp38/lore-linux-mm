Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id D07886B0264
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 16:46:24 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id cy9so383224470pac.0
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 13:46:24 -0800 (PST)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id a10si11632433pas.56.2016.01.14.13.46.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jan 2016 13:46:23 -0800 (PST)
Received: by mail-pa0-x22a.google.com with SMTP id uo6so367744706pac.1
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 13:46:23 -0800 (PST)
Date: Thu, 14 Jan 2016 13:46:22 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v4 1/2] memory-hotplug: add automatic onlining policy
 for the newly added memory
In-Reply-To: <87pox44kbs.fsf@vitty.brq.redhat.com>
Message-ID: <alpine.DEB.2.10.1601141345430.16227@chino.kir.corp.google.com>
References: <1452617777-10598-1-git-send-email-vkuznets@redhat.com> <1452617777-10598-2-git-send-email-vkuznets@redhat.com> <alpine.DEB.2.10.1601121535150.28831@chino.kir.corp.google.com> <87fuy168wa.fsf@vitty.brq.redhat.com>
 <alpine.DEB.2.10.1601131648550.3847@chino.kir.corp.google.com> <87pox44kbs.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: linux-mm@kvack.org, Jonathan Corbet <corbet@lwn.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Daniel Kiper <daniel.kiper@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, David Vrabel <david.vrabel@citrix.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Xishi Qiu <qiuxishi@huawei.com>, Mel Gorman <mgorman@techsingularity.net>, "K. Y. Srinivasan" <kys@microsoft.com>, Igor Mammedov <imammedo@redhat.com>, Kay Sievers <kay@vrfy.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org

On Thu, 14 Jan 2016, Vitaly Kuznetsov wrote:

> > My suggestion is to just simply document that auto-onlining can add the 
> > memory but fail to online it and the failure is silent to userspace.  If 
> > userspace cares, it can check the online status of the added memory blocks 
> > itself.
> 
> The problem is not only that it's silent, but also that
> /sys/devices/system/memory/*/state will lie as we create all memory
> blocks in MEM_ONLINE state and from online_pages() error we can't figure
> out which particular block failed. 'v5' which I sent yesterday is
> supposed to fix the issue (blocks are onlined with
> memory_block_change_state() which handles failures.
> 

Would you mind documenting that in the memory-hotplug.txt as an add-on 
patch to your v5, which appears ready to go?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
