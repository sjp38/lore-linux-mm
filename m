Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id 6549B6B025F
	for <linux-mm@kvack.org>; Thu,  7 Apr 2016 04:47:47 -0400 (EDT)
Received: by mail-qg0-f43.google.com with SMTP id f105so33622864qge.2
        for <linux-mm@kvack.org>; Thu, 07 Apr 2016 01:47:47 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t65si5146928qhc.2.2016.04.07.01.47.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Apr 2016 01:47:46 -0700 (PDT)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH 0/2] memory_hotplug: introduce config and command line options to set the default onlining policy
In-Reply-To: <alpine.DEB.2.10.1604061512460.10401@chino.kir.corp.google.com>
	(David Rientjes's message of "Wed, 6 Apr 2016 15:13:27 -0700 (PDT)")
References: <1459950312-25504-1-git-send-email-vkuznets@redhat.com>
	<20160406115334.82af80e922f8b3eec6336a8b@linux-foundation.org>
	<alpine.DEB.2.10.1604061512460.10401@chino.kir.corp.google.com>
Date: Thu, 07 Apr 2016 10:47:41 +0200
Message-ID: <87y48phkk2.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Dan Williams <dan.j.williams@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, David Vrabel <david.vrabel@citrix.com>, Igor Mammedov <imammedo@redhat.com>, Lennart Poettering <lennart@poettering.net>

David Rientjes <rientjes@google.com> writes:

> On Wed, 6 Apr 2016, Andrew Morton wrote:
>
>> > This patchset continues the work I started with:
>> > 
>> > commit 31bc3858ea3ebcc3157b3f5f0e624c5962f5a7a6
>> > Author: Vitaly Kuznetsov <vkuznets@redhat.com>
>> > Date:   Tue Mar 15 14:56:48 2016 -0700
>> > 
>> >     memory-hotplug: add automatic onlining policy for the newly added memory
>> > 
>> > Initially I was going to stop there and bring the policy setting logic to
>> > userspace. I met two issues on this way:
>> > 
>> > 1) It is possible to have memory hotplugged at boot (e.g. with QEMU). These
>> >    blocks stay offlined if we turn the onlining policy on by userspace.
>> > 
>> > 2) My attempt to bring this policy setting to systemd failed, systemd
>> >    maintainers suggest to change the default in kernel or ... to use tmpfiles.d
>> >    to alter the policy (which looks like a hack to me): 
>> >    https://github.com/systemd/systemd/pull/2938
>> 
>> That discussion really didn't come to a conclusion and I don't
>> understand why you consider Lennert's "recommended way" to be a hack?
>> 
>> > Here I suggest to add a config option to set the default value for the policy
>> > and a kernel command line parameter to make the override.
>> 
>> But the patchset looks pretty reasonable regardless of the above.
>> 
>
> I don't understand why initscripts simply cannot crawl sysfs memory blocks 
> and online them for the same behavior.

Yes, they can. With this patchset I don't bring any new features, it's
rather a convenience so linux distros can make memory hotplug work
'out of the box' without such distro-specific initscripts. Memory
hotplug is a standard feature of all major virt technologies so I think
it's pretty reasonable to have an option to make it work 'by default'
available.

-- 
  Vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
