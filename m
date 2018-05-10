Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 249506B05F7
	for <linux-mm@kvack.org>; Thu, 10 May 2018 07:56:21 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id x21-v6so1035286pfn.23
        for <linux-mm@kvack.org>; Thu, 10 May 2018 04:56:21 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id k75-v6si629218pfk.369.2018.05.10.04.56.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 May 2018 04:56:20 -0700 (PDT)
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w4ABtxld066173
	for <linux-mm@kvack.org>; Thu, 10 May 2018 11:56:19 GMT
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp2130.oracle.com with ESMTP id 2hv6m4k6yp-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 10 May 2018 11:56:19 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w4ABuIXV022601
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 10 May 2018 11:56:18 GMT
Received: from abhmp0011.oracle.com (abhmp0011.oracle.com [141.146.116.17])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w4ABuIOA021748
	for <linux-mm@kvack.org>; Thu, 10 May 2018 11:56:18 GMT
Received: by mail-oi0-f46.google.com with SMTP id c203-v6so1497125oib.7
        for <linux-mm@kvack.org>; Thu, 10 May 2018 04:56:17 -0700 (PDT)
MIME-Version: 1.0
References: <20180509191713.23794-1-pasha.tatashin@oracle.com> <20180509210920.GZ32366@dhcp22.suse.cz>
In-Reply-To: <20180509210920.GZ32366@dhcp22.suse.cz>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Thu, 10 May 2018 11:55:42 +0000
Message-ID: <CAGM2reZEK3-sRwCF4Zuyzk789zp1ghA0D4GQYqcHV4npNPPJVA@mail.gmail.com>
Subject: Re: [PATCH] mm: allow deferred page init for vmemmap only
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, tglx@linutronix.de, Linux Memory Management List <linux-mm@kvack.org>, mgorman@techsingularity.net, mingo@kernel.org, peterz@infradead.org, Steven Rostedt <rostedt@goodmis.org>, Fengguang Wu <fengguang.wu@intel.com>, Dennis Zhou <dennisszhou@gmail.com>

> This doesn't really explain why CONFIG_SPARSMEM or DISCONTIG has the
> problem.

Hi Michal,

Thank you for reviewing this patch. I sent out a version two of this patch,
with expanded explanation of the problem.

Thank you,
Pavel
