Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 53A7A6B0388
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 12:41:13 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id v77so2697744wmv.5
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 09:41:13 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p76si7266355wmg.164.2017.02.23.09.41.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 23 Feb 2017 09:41:12 -0800 (PST)
Date: Thu, 23 Feb 2017 18:41:07 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] memory-hotplug: Use dev_online for memhp_auto_offline
Message-ID: <20170223174106.GB13822@dhcp22.suse.cz>
References: <20170221172234.8047.33382.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
 <878toy1sgd.fsf@vitty.brq.redhat.com>
 <20170223125643.GA29064@dhcp22.suse.cz>
 <87bmttyqxf.fsf@vitty.brq.redhat.com>
 <20170223150920.GB29056@dhcp22.suse.cz>
 <877f4gzz4d.fsf@vitty.brq.redhat.com>
 <20170223161241.GG29056@dhcp22.suse.cz>
 <8737f4zwx5.fsf@vitty.brq.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8737f4zwx5.fsf@vitty.brq.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: Nathan Fontenot <nfont@linux.vnet.ibm.com>, linux-mm@kvack.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, mdroth@linux.vnet.ibm.com

On Thu 23-02-17 17:36:38, Vitaly Kuznetsov wrote:
> Michal Hocko <mhocko@kernel.org> writes:
[...]
> > Is a grow from 256M -> 128GB really something that happens in real life?
> > Don't get me wrong but to me this sounds quite exaggerated. Hotmem add
> > which is an operation which has to allocate memory has to scale with the
> > currently available memory IMHO.
> 
> With virtual machines this is very real and not exaggerated at
> all. E.g. Hyper-V host can be tuned to automatically add new memory when
> guest is running out of it. Even 100 blocks can represent an issue.

Do you have any reference to a bug report. I am really curious because
something really smells wrong and it is not clear that the chosen
solution is really the best one.
[...]
> > Because the udev will run a code which can cope with that - retry if the
> > error is recoverable or simply report with all the details. Compare that
> > to crawling the system log to see that something has broken...
> 
> I don't know much about udev, but the most common rule to online memory
> I've met is:
> 
> SUBSYSTEM=="memory", ACTION=="add", ATTR{state}=="offline",  ATTR{state}="online"
> 
> doesn't do anything smart.

So what? Is there anything that prevents doing something smarter?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
