Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 218156B0005
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 08:42:31 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id l19so309357ioc.19
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 05:42:31 -0800 (PST)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id g62si1508677ioa.170.2018.02.15.05.42.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Feb 2018 05:42:30 -0800 (PST)
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w1FDgQZV120401
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 13:42:29 GMT
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by aserp2130.oracle.com with ESMTP id 2g5b4y81sa-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 13:42:28 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w1FDdmxk004096
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 13:39:48 GMT
Received: from abhmp0012.oracle.com (abhmp0012.oracle.com [141.146.116.18])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w1FDdmjF012864
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 13:39:48 GMT
Received: by mail-ot0-f174.google.com with SMTP id 73so23374629oti.12
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 05:39:47 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180215113725.GC7275@dhcp22.suse.cz>
References: <20180213193159.14606-1-pasha.tatashin@oracle.com>
 <20180213193159.14606-3-pasha.tatashin@oracle.com> <20180215113725.GC7275@dhcp22.suse.cz>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Thu, 15 Feb 2018 08:39:47 -0500
Message-ID: <CAOAebxu5EM1qhC=pS2cCqjGfBabFEj0aQQNon1nAz5_3YPOsCw@mail.gmail.com>
Subject: Re: [PATCH v3 2/4] x86/mm/memory_hotplug: determine block size based
 on the end of boot memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Steve Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Vlastimil Babka <vbabka@suse.cz>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, bhe@redhat.com

> I dunno. If x86 maintainers are OK with this then why not, but I do not
> like how this is x86 specific. I would much rather address this by
> making the memblock user interface more sane.
>

Hi Michal,

Ingo Molnar reviewed this patch, and Okayed it.

Thank you,
Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
