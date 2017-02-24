Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id D05656B0038
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 11:52:28 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id v30so13739237wrc.4
        for <linux-mm@kvack.org>; Fri, 24 Feb 2017 08:52:28 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h1si10794730wrb.231.2017.02.24.08.52.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Feb 2017 08:52:27 -0800 (PST)
Date: Fri, 24 Feb 2017 17:52:25 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] memory-hotplug: Use dev_online for memhp_auto_offline
Message-ID: <20170224165224.GA9363@dhcp22.suse.cz>
References: <20170223174106.GB13822@dhcp22.suse.cz>
 <87tw7kydto.fsf@vitty.brq.redhat.com>
 <20170224133714.GH19161@dhcp22.suse.cz>
 <87efyny90q.fsf@vitty.brq.redhat.com>
 <20170224144147.GJ19161@dhcp22.suse.cz>
 <87a89by6hd.fsf@vitty.brq.redhat.com>
 <20170224153227.GL19161@dhcp22.suse.cz>
 <8760jzy3iu.fsf@vitty.brq.redhat.com>
 <20170224162317.GN19161@dhcp22.suse.cz>
 <871suny22u.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <871suny22u.fsf@vitty.brq.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: Nathan Fontenot <nfont@linux.vnet.ibm.com>, linux-mm@kvack.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, mdroth@linux.vnet.ibm.com, kys@microsoft.com

On Fri 24-02-17 17:40:25, Vitaly Kuznetsov wrote:
> Michal Hocko <mhocko@kernel.org> writes:
> 
> > On Fri 24-02-17 17:09:13, Vitaly Kuznetsov wrote:
[...]
> >> While this will most probably work for me I still disagree with the
> >> concept of 'one size fits all' here and the default 'false' for ACPI,
> >> we're taking away the feature from KVM/Vmware folks so they'll again
> >> come up with the udev rule which has known issues.
> >
> > Well, AFAIU acpi_memory_device_add is a standard way how to announce
> > physical memory added to the system. Where does the KVM/VMware depend on
> > this to do memory ballooning?
> 
> As far as I understand memory hotplug in KVM/VMware is pure ACPI memory
> hotplug, there is no specific code for it.

VMware has its ballooning driver AFAIK and I have no idea what KVM uses.
Anyway, acpi_memory_device_add is no different from doing a physical
memory hotplug IIUC so there shouldn't be any difference to how it is
handled.

I will post the patch as an RFC sometimes next week, let's see what
others think about it.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
