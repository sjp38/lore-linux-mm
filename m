Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id EE0E66B0253
	for <linux-mm@kvack.org>; Thu,  7 Apr 2016 04:42:56 -0400 (EDT)
Received: by mail-qg0-f48.google.com with SMTP id f105so33555840qge.2
        for <linux-mm@kvack.org>; Thu, 07 Apr 2016 01:42:56 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 30si5136083qgt.32.2016.04.07.01.42.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Apr 2016 01:42:56 -0700 (PDT)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH 0/2] memory_hotplug: introduce config and command line options to set the default onlining policy
References: <1459950312-25504-1-git-send-email-vkuznets@redhat.com>
	<20160406115334.82af80e922f8b3eec6336a8b@linux-foundation.org>
Date: Thu, 07 Apr 2016 10:42:50 +0200
In-Reply-To: <20160406115334.82af80e922f8b3eec6336a8b@linux-foundation.org>
	(Andrew Morton's message of "Wed, 6 Apr 2016 11:53:34 -0700")
Message-ID: <874mbdizcl.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Dan Williams <dan.j.williams@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, David Vrabel <david.vrabel@citrix.com>, David Rientjes <rientjes@google.com>, Igor Mammedov <imammedo@redhat.com>, Lennart Poettering <lennart@poettering.net>

Andrew Morton <akpm@linux-foundation.org> writes:

> On Wed,  6 Apr 2016 15:45:10 +0200 Vitaly Kuznetsov <vkuznets@redhat.com> wrote:
>
>> This patchset continues the work I started with:
>> 
>> commit 31bc3858ea3ebcc3157b3f5f0e624c5962f5a7a6
>> Author: Vitaly Kuznetsov <vkuznets@redhat.com>
>> Date:   Tue Mar 15 14:56:48 2016 -0700
>> 
>>     memory-hotplug: add automatic onlining policy for the newly added memory
>> 
>> Initially I was going to stop there and bring the policy setting logic to
>> userspace. I met two issues on this way:
>> 
>> 1) It is possible to have memory hotplugged at boot (e.g. with QEMU). These
>>    blocks stay offlined if we turn the onlining policy on by userspace.
>> 
>> 2) My attempt to bring this policy setting to systemd failed, systemd
>>    maintainers suggest to change the default in kernel or ... to use tmpfiles.d
>>    to alter the policy (which looks like a hack to me): 
>>    https://github.com/systemd/systemd/pull/2938
>
> That discussion really didn't come to a conclusion and I don't
> understand why you consider Lennert's "recommended way" to be a hack?

Just the name. To me 'tmpfiles.d' doesn't sound like an appropriate
place to search for kernel tunables settings. It would be much better in
case we had something like 'tunables.d' for that.

-- 
  Vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
