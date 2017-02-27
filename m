Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8650D6B0038
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 10:43:08 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id u48so2443535wrc.0
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 07:43:08 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u133si13850063wmu.53.2017.02.27.07.43.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 27 Feb 2017 07:43:07 -0800 (PST)
Date: Mon, 27 Feb 2017 16:43:04 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, hotplug: get rid of auto_online_blocks
Message-ID: <20170227154304.GK26504@dhcp22.suse.cz>
References: <20170227092817.23571-1-mhocko@kernel.org>
 <87lgssvtni.fsf@vitty.brq.redhat.com>
 <20170227112510.GA4129@osiris>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170227112510.GA4129@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, linux-api@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-s390@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org

On Mon 27-02-17 12:25:10, Heiko Carstens wrote:
> On Mon, Feb 27, 2017 at 11:02:09AM +0100, Vitaly Kuznetsov wrote:
> > A couple of other thoughts:
> > 1) Having all newly added memory online ASAP is probably what people
> > want for all virtual machines.
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
> > Unfortunately, we have additional complexity with memory zones
> > (ZONE_NORMAL, ZONE_MOVABLE) and in some cases manual intervention is
> > required. Especially, when further unplug is expected.
> 
> This also is a reason why auto-onlining doesn't seem be the best way.

Can you imagine any situation when somebody actually might want to have
this knob enabled? From what I understand it doesn't seem to be the
case.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
