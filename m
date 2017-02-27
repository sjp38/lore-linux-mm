Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7D93B6B0038
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 06:50:24 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id n130so116832147qke.7
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 03:50:24 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 52si11561017qtv.302.2017.02.27.03.50.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Feb 2017 03:50:23 -0800 (PST)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [RFC PATCH] mm, hotplug: get rid of auto_online_blocks
References: <20170227092817.23571-1-mhocko@kernel.org>
	<87lgssvtni.fsf@vitty.brq.redhat.com> <20170227112510.GA4129@osiris>
Date: Mon, 27 Feb 2017 12:50:19 +0100
In-Reply-To: <20170227112510.GA4129@osiris> (Heiko Carstens's message of "Mon,
	27 Feb 2017 12:25:10 +0100")
Message-ID: <87a897x37o.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, linux-api@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-s390@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org, Michal Hocko <mhocko@suse.com>

Heiko Carstens <heiko.carstens@de.ibm.com> writes:

> On Mon, Feb 27, 2017 at 11:02:09AM +0100, Vitaly Kuznetsov wrote:
>> A couple of other thoughts:
>> 1) Having all newly added memory online ASAP is probably what people
>> want for all virtual machines.

Sorry, obviously missed 'x86' in the above statement.

>
> This is not true for s390. On s390 we have "standby" memory that a guest
> sees and potentially may use if it sets it online. Every guest that sets
> memory offline contributes to the hypervisor's standby memory pool, while
> onlining standby memory takes memory away from the standby pool.
>
> The use-case is that a system administrator in advance knows the maximum
> size a guest will ever have and also defines how much memory should be used
> at boot time. The difference is standby memory.
>
> Auto-onlining of standby memory is the last thing we want.
>

This is actually a very good example of why we need the config
option. s390 kernels will have it disabled.

-- 
  Vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
