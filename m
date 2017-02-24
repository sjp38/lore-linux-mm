Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 156286B0038
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 11:40:32 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id n130so10714275qke.7
        for <linux-mm@kvack.org>; Fri, 24 Feb 2017 08:40:32 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i10si5975000qtg.210.2017.02.24.08.40.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Feb 2017 08:40:27 -0800 (PST)
From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [RFC PATCH] memory-hotplug: Use dev_online for memhp_auto_offline
References: <20170223161241.GG29056@dhcp22.suse.cz>
	<8737f4zwx5.fsf@vitty.brq.redhat.com>
	<20170223174106.GB13822@dhcp22.suse.cz>
	<87tw7kydto.fsf@vitty.brq.redhat.com>
	<20170224133714.GH19161@dhcp22.suse.cz>
	<87efyny90q.fsf@vitty.brq.redhat.com>
	<20170224144147.GJ19161@dhcp22.suse.cz>
	<87a89by6hd.fsf@vitty.brq.redhat.com>
	<20170224153227.GL19161@dhcp22.suse.cz>
	<8760jzy3iu.fsf@vitty.brq.redhat.com>
	<20170224162317.GN19161@dhcp22.suse.cz>
Date: Fri, 24 Feb 2017 17:40:25 +0100
In-Reply-To: <20170224162317.GN19161@dhcp22.suse.cz> (Michal Hocko's message
	of "Fri, 24 Feb 2017 17:23:17 +0100")
Message-ID: <871suny22u.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Nathan Fontenot <nfont@linux.vnet.ibm.com>, linux-mm@kvack.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, mdroth@linux.vnet.ibm.com, kys@microsoft.com

Michal Hocko <mhocko@kernel.org> writes:

> On Fri 24-02-17 17:09:13, Vitaly Kuznetsov wrote:

>> I have a smal  guest and I want to add more memory to it and the
>> result is ... OOM. Not something I expected.
>
> Which is not all that unexpected if you use a technology which has to
> allocated in order to add more memory.
>

My point is: why should users care about this? It's our problem that we
can't always hotplug memory. And I think this problem is solvable.

>> 
>> While this will most probably work for me I still disagree with the
>> concept of 'one size fits all' here and the default 'false' for ACPI,
>> we're taking away the feature from KVM/Vmware folks so they'll again
>> come up with the udev rule which has known issues.
>
> Well, AFAIU acpi_memory_device_add is a standard way how to announce
> physical memory added to the system. Where does the KVM/VMware depend on
> this to do memory ballooning?

As far as I understand memory hotplug in KVM/VMware is pure ACPI memory
hotplug, there is no specific code for it.

-- 
  Vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
