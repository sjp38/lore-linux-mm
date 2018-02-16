Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 485CE6B0006
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 08:10:11 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id g24so3131865iob.13
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 05:10:11 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id q13si9954555itb.109.2018.02.16.05.10.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Feb 2018 05:10:10 -0800 (PST)
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w1GD6nB8187874
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 13:10:09 GMT
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2130.oracle.com with ESMTP id 2g5xdq8ecm-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 13:10:09 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w1GDA8cQ025609
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 13:10:08 GMT
Received: from abhmp0015.oracle.com (abhmp0015.oracle.com [141.146.116.21])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w1GDA8NV024523
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 13:10:08 GMT
Received: by mail-oi0-f48.google.com with SMTP id u6so2226188oiv.9
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 05:10:07 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180216092330.k7hutkvjmy7nope3@gmail.com>
References: <20180215165920.8570-1-pasha.tatashin@oracle.com>
 <20180215165920.8570-4-pasha.tatashin@oracle.com> <20180216092330.k7hutkvjmy7nope3@gmail.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Fri, 16 Feb 2018 08:10:06 -0500
Message-ID: <CAOAebxv6iJ=iz4=J-d2XHwXxF-CFK1Gs_W7fDLcF9yoV=av_uw@mail.gmail.com>
Subject: Re: [v4 3/6] mm: uninitialized struct page poisoning sanity checking
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Steve Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Vlastimil Babka <vbabka@suse.cz>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, bhe@redhat.com

OK, I will update the title.

>
> Please always start patch titles with a verb, i.e.:
>
>  mm: Add uninitialized struct page poisoning sanity check

OK, I will update the title.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
