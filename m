Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 54B9B6B0003
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 08:07:33 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id 6so1610303iti.4
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 05:07:33 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id s78si9937543itb.40.2018.02.16.05.07.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Feb 2018 05:07:31 -0800 (PST)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w1GD6Yrv120348
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 13:07:31 GMT
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by aserp2120.oracle.com with ESMTP id 2g5xjbgbqn-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 13:07:31 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w1GD7TIF021526
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 13:07:29 GMT
Received: from abhmp0002.oracle.com (abhmp0002.oracle.com [141.146.116.8])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w1GD7SCb013661
	for <linux-mm@kvack.org>; Fri, 16 Feb 2018 13:07:29 GMT
Received: by mail-oi0-f46.google.com with SMTP id b3so2208900oib.11
        for <linux-mm@kvack.org>; Fri, 16 Feb 2018 05:07:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180216091304.hgp5tn25nleuy4jc@gmail.com>
References: <20180215165920.8570-1-pasha.tatashin@oracle.com>
 <20180215165920.8570-5-pasha.tatashin@oracle.com> <20180216091304.hgp5tn25nleuy4jc@gmail.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Fri, 16 Feb 2018 08:07:26 -0500
Message-ID: <CAOAebxvwaHT8fQ+FnJYi90ogZtJ1wpRqvXYfx=KPsiX_gVp9tA@mail.gmail.com>
Subject: Re: [v4 4/6] mm/memory_hotplug: optimize probe routine
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Steve Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Vlastimil Babka <vbabka@suse.cz>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com, bhe@redhat.com

> Reviewed-by: Ingo Molnar <mingo@kernel.org>

Thank you!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
