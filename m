Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1605F6B000A
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 08:15:41 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id w203so1621589itf.5
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 05:15:41 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id f31si3269578ioi.326.2018.02.16.05.15.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Feb 2018 05:15:40 -0800 (PST)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w1GDFb8i126132
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 13:15:39 GMT
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by aserp2120.oracle.com with ESMTP id 2g5xjbgccy-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 13:15:38 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w1GDCW7a031492
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 13:12:32 GMT
Received: from abhmp0006.oracle.com (abhmp0006.oracle.com [141.146.116.12])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w1GDCW8P019000
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 13:12:32 GMT
Received: by mail-oi0-f49.google.com with SMTP id t145so2235346oif.8
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 05:12:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180216092959.gkm6d4j2zplk724r@gmail.com>
References: <20180215165920.8570-1-pasha.tatashin@oracle.com>
 <20180215165920.8570-7-pasha.tatashin@oracle.com> <20180216092959.gkm6d4j2zplk724r@gmail.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Fri, 16 Feb 2018 08:12:31 -0500
Message-ID: <CAOAebxuFivBx+6kexgV0JRtdxi+j9qy-hReMPsYk8NmzaKUNkQ@mail.gmail.com>
Subject: Re: [v4 6/6] mm/memory_hotplug: optimize memory hotplug
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Steve Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Vlastimil Babka <vbabka@suse.cz>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, bhe@redhat.com

>
>   Reviewed-by: Ingo Molnar <mingo@kernel.org>

Thank you for your review! I will address all of your comments in the
next patch iteration.

Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
