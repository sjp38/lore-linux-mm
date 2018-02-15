Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 930426B0003
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 08:41:54 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id p142so592906itp.0
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 05:41:54 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id m15si1310318ioe.64.2018.02.15.05.41.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Feb 2018 05:41:53 -0800 (PST)
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w1FDfqLc158221
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 13:41:52 GMT
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by userp2130.oracle.com with ESMTP id 2g5b2k83ps-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 13:41:52 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w1FDfqSb027894
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 13:41:52 GMT
Received: from abhmp0015.oracle.com (abhmp0015.oracle.com [141.146.116.21])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w1FDfqTs013832
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 13:41:52 GMT
Received: by mail-ot0-f180.google.com with SMTP id l24so1517773otj.3
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 05:41:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180215115316.GD7275@dhcp22.suse.cz>
References: <20180213193159.14606-1-pasha.tatashin@oracle.com>
 <20180213193159.14606-4-pasha.tatashin@oracle.com> <20180215115316.GD7275@dhcp22.suse.cz>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Thu, 15 Feb 2018 08:41:50 -0500
Message-ID: <CAOAebxtS8nHtz+FC034FsTDWrDNtKPcxR-9Z=CkgR4yr2=5YEQ@mail.gmail.com>
Subject: Re: [PATCH v3 3/4] mm: uninitialized struct page poisoning sanity checking
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Steve Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Vlastimil Babka <vbabka@suse.cz>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, bhe@redhat.com

> Acked-by: Michal Hocko <mhocko@suse.com>

Thank you, I will do the changes that you requested.

Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
