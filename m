Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id B857A6B0005
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 14:53:36 -0400 (EDT)
Received: by mail-pf0-f173.google.com with SMTP id c20so39061666pfc.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 11:53:36 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id rw6si1222687pab.80.2016.04.06.11.53.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Apr 2016 11:53:35 -0700 (PDT)
Date: Wed, 6 Apr 2016 11:53:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/2] memory_hotplug: introduce config and command line
 options to set the default onlining policy
Message-Id: <20160406115334.82af80e922f8b3eec6336a8b@linux-foundation.org>
In-Reply-To: <1459950312-25504-1-git-send-email-vkuznets@redhat.com>
References: <1459950312-25504-1-git-send-email-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Dan Williams <dan.j.williams@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, David Vrabel <david.vrabel@citrix.com>, David Rientjes <rientjes@google.com>, Igor Mammedov <imammedo@redhat.com>, Lennart Poettering <lennart@poettering.net>

On Wed,  6 Apr 2016 15:45:10 +0200 Vitaly Kuznetsov <vkuznets@redhat.com> wrote:

> This patchset continues the work I started with:
> 
> commit 31bc3858ea3ebcc3157b3f5f0e624c5962f5a7a6
> Author: Vitaly Kuznetsov <vkuznets@redhat.com>
> Date:   Tue Mar 15 14:56:48 2016 -0700
> 
>     memory-hotplug: add automatic onlining policy for the newly added memory
> 
> Initially I was going to stop there and bring the policy setting logic to
> userspace. I met two issues on this way:
> 
> 1) It is possible to have memory hotplugged at boot (e.g. with QEMU). These
>    blocks stay offlined if we turn the onlining policy on by userspace.
> 
> 2) My attempt to bring this policy setting to systemd failed, systemd
>    maintainers suggest to change the default in kernel or ... to use tmpfiles.d
>    to alter the policy (which looks like a hack to me): 
>    https://github.com/systemd/systemd/pull/2938

That discussion really didn't come to a conclusion and I don't
understand why you consider Lennert's "recommended way" to be a hack?

> Here I suggest to add a config option to set the default value for the policy
> and a kernel command line parameter to make the override.

But the patchset looks pretty reasonable regardless of the above.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
