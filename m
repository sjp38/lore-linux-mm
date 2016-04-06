Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 8F43C6B0273
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 18:13:29 -0400 (EDT)
Received: by mail-pf0-f180.google.com with SMTP id c20so41881380pfc.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 15:13:29 -0700 (PDT)
Received: from mail-pf0-x236.google.com (mail-pf0-x236.google.com. [2607:f8b0:400e:c00::236])
        by mx.google.com with ESMTPS id d27si6311180pfj.14.2016.04.06.15.13.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Apr 2016 15:13:28 -0700 (PDT)
Received: by mail-pf0-x236.google.com with SMTP id c20so41881260pfc.1
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 15:13:28 -0700 (PDT)
Date: Wed, 6 Apr 2016 15:13:27 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 0/2] memory_hotplug: introduce config and command line
 options to set the default onlining policy
In-Reply-To: <20160406115334.82af80e922f8b3eec6336a8b@linux-foundation.org>
Message-ID: <alpine.DEB.2.10.1604061512460.10401@chino.kir.corp.google.com>
References: <1459950312-25504-1-git-send-email-vkuznets@redhat.com> <20160406115334.82af80e922f8b3eec6336a8b@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Dan Williams <dan.j.williams@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, David Vrabel <david.vrabel@citrix.com>, Igor Mammedov <imammedo@redhat.com>, Lennart Poettering <lennart@poettering.net>

On Wed, 6 Apr 2016, Andrew Morton wrote:

> > This patchset continues the work I started with:
> > 
> > commit 31bc3858ea3ebcc3157b3f5f0e624c5962f5a7a6
> > Author: Vitaly Kuznetsov <vkuznets@redhat.com>
> > Date:   Tue Mar 15 14:56:48 2016 -0700
> > 
> >     memory-hotplug: add automatic onlining policy for the newly added memory
> > 
> > Initially I was going to stop there and bring the policy setting logic to
> > userspace. I met two issues on this way:
> > 
> > 1) It is possible to have memory hotplugged at boot (e.g. with QEMU). These
> >    blocks stay offlined if we turn the onlining policy on by userspace.
> > 
> > 2) My attempt to bring this policy setting to systemd failed, systemd
> >    maintainers suggest to change the default in kernel or ... to use tmpfiles.d
> >    to alter the policy (which looks like a hack to me): 
> >    https://github.com/systemd/systemd/pull/2938
> 
> That discussion really didn't come to a conclusion and I don't
> understand why you consider Lennert's "recommended way" to be a hack?
> 
> > Here I suggest to add a config option to set the default value for the policy
> > and a kernel command line parameter to make the override.
> 
> But the patchset looks pretty reasonable regardless of the above.
> 

I don't understand why initscripts simply cannot crawl sysfs memory blocks 
and online them for the same behavior.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
