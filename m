Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 215AC6B0038
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 07:56:47 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id z61so15315007wrc.6
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 04:56:47 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b62si6002052wrd.98.2017.02.23.04.56.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Feb 2017 04:56:45 -0800 (PST)
Date: Thu, 23 Feb 2017 13:56:43 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] memory-hotplug: Use dev_online for memhp_auto_offline
Message-ID: <20170223125643.GA29064@dhcp22.suse.cz>
References: <20170221172234.8047.33382.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
 <878toy1sgd.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <878toy1sgd.fsf@vitty.brq.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: Nathan Fontenot <nfont@linux.vnet.ibm.com>, linux-mm@kvack.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, mdroth@linux.vnet.ibm.com

On Wed 22-02-17 10:32:34, Vitaly Kuznetsov wrote:
[...]
> > There is a workaround in that a user could online the memory or have
> > a udev rule to online the memory by using the sysfs interface. The
> > sysfs interface to online memory goes through device_online() which
> > should updated the dev->offline flag. I'm not sure that having kernel
> > memory hotplug rely on userspace actions is the correct way to go.
> 
> Using udev rule for memory onlining is possible when you disable
> memhp_auto_online but in some cases it doesn't work well, e.g. when we
> use memory hotplug to address memory pressure the loop through userspace
> is really slow and memory consuming, we may hit OOM before we manage to
> online newly added memory.

How does the in-kernel implementation prevents from that?

> In addition to that, systemd/udev folks
> continuosly refused to add this udev rule to udev calling it stupid as
> it actually is an unconditional and redundant ping-pong between kernel
> and udev.

This is a policy and as such it doesn't belong to the kernel. The whole
auto-enable in the kernel is just plain wrong IMHO and we shouldn't have
merged it.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
