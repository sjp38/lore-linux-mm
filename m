Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f170.google.com (mail-qk0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id 532F4828DF
	for <linux-mm@kvack.org>; Fri, 15 Jan 2016 08:14:00 -0500 (EST)
Received: by mail-qk0-f170.google.com with SMTP id s5so5101465qkd.0
        for <linux-mm@kvack.org>; Fri, 15 Jan 2016 05:14:00 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d32si6118507qgd.67.2016.01.15.05.13.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jan 2016 05:13:59 -0800 (PST)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH v4 1/2] memory-hotplug: add automatic onlining policy for the newly added memory
References: <1452617777-10598-1-git-send-email-vkuznets@redhat.com>
	<1452617777-10598-2-git-send-email-vkuznets@redhat.com>
	<alpine.DEB.2.10.1601121535150.28831@chino.kir.corp.google.com>
	<87fuy168wa.fsf@vitty.brq.redhat.com>
	<alpine.DEB.2.10.1601131648550.3847@chino.kir.corp.google.com>
	<87pox44kbs.fsf@vitty.brq.redhat.com>
	<alpine.DEB.2.10.1601141345430.16227@chino.kir.corp.google.com>
Date: Fri, 15 Jan 2016 14:13:50 +0100
In-Reply-To: <alpine.DEB.2.10.1601141345430.16227@chino.kir.corp.google.com>
	(David Rientjes's message of "Thu, 14 Jan 2016 13:46:22 -0800 (PST)")
Message-ID: <87io2v0yup.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Jonathan Corbet <corbet@lwn.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Daniel Kiper <daniel.kiper@oracle.com>, Dan Williams <dan.j.williams@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, David Vrabel <david.vrabel@citrix.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Xishi Qiu <qiuxishi@huawei.com>, Mel Gorman <mgorman@techsingularity.net>, "K. Y. Srinivasan" <kys@microsoft.com>, Igor Mammedov <imammedo@redhat.com>, Kay Sievers <kay@vrfy.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org

David Rientjes <rientjes@google.com> writes:

> On Thu, 14 Jan 2016, Vitaly Kuznetsov wrote:
>
>> > My suggestion is to just simply document that auto-onlining can add the 
>> > memory but fail to online it and the failure is silent to userspace.  If 
>> > userspace cares, it can check the online status of the added memory blocks 
>> > itself.
>> 
>> The problem is not only that it's silent, but also that
>> /sys/devices/system/memory/*/state will lie as we create all memory
>> blocks in MEM_ONLINE state and from online_pages() error we can't figure
>> out which particular block failed. 'v5' which I sent yesterday is
>> supposed to fix the issue (blocks are onlined with
>> memory_block_change_state() which handles failures.
>> 
>
> Would you mind documenting that in the memory-hotplug.txt as an add-on 
> patch to your v5, which appears ready to go?

Sure,

I'll mention possible failures diring automatic onlining. It seems v5
wasn't picked by Andrew and I also have one nitpick in PATCH 2 to
address so I'll send v6.

Thanks,

-- 
  Vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
