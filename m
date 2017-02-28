Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 355596B0395
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 05:21:17 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id d18so12047601pgh.2
        for <linux-mm@kvack.org>; Tue, 28 Feb 2017 02:21:17 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id z17si1407091pgf.39.2017.02.28.02.21.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Feb 2017 02:21:16 -0800 (PST)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1SAIeM1059942
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 05:21:15 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28vyqf321r-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 05:21:15 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Tue, 28 Feb 2017 10:21:13 -0000
Date: Tue, 28 Feb 2017 11:21:05 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [RFC PATCH] mm, hotplug: get rid of auto_online_blocks
References: <20170227092817.23571-1-mhocko@kernel.org>
 <87lgssvtni.fsf@vitty.brq.redhat.com>
 <20170227112510.GA4129@osiris>
 <20170227154304.GK26504@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170227154304.GK26504@dhcp22.suse.cz>
Message-Id: <20170228102105.GA13872@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vitaly Kuznetsov <vkuznets@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, linux-api@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-s390@vger.kernel.org, xen-devel@lists.xenproject.org, linux-acpi@vger.kernel.org

On Mon, Feb 27, 2017 at 04:43:04PM +0100, Michal Hocko wrote:
> On Mon 27-02-17 12:25:10, Heiko Carstens wrote:
> > On Mon, Feb 27, 2017 at 11:02:09AM +0100, Vitaly Kuznetsov wrote:
> > > A couple of other thoughts:
> > > 1) Having all newly added memory online ASAP is probably what people
> > > want for all virtual machines.
> > 
> > This is not true for s390. On s390 we have "standby" memory that a guest
> > sees and potentially may use if it sets it online. Every guest that sets
> > memory offline contributes to the hypervisor's standby memory pool, while
> > onlining standby memory takes memory away from the standby pool.
> > 
> > The use-case is that a system administrator in advance knows the maximum
> > size a guest will ever have and also defines how much memory should be used
> > at boot time. The difference is standby memory.
> > 
> > Auto-onlining of standby memory is the last thing we want.
> > 
> > > Unfortunately, we have additional complexity with memory zones
> > > (ZONE_NORMAL, ZONE_MOVABLE) and in some cases manual intervention is
> > > required. Especially, when further unplug is expected.
> > 
> > This also is a reason why auto-onlining doesn't seem be the best way.
> 
> Can you imagine any situation when somebody actually might want to have
> this knob enabled? From what I understand it doesn't seem to be the
> case.

I can only speak for s390, and at least here I think auto-online is always
wrong, especially if you consider the added complexity that you may want to
online memory sometimes to ZONE_NORMAL and sometimes to ZONE_MOVABLE.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
