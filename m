Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8CFFD6B02CD
	for <linux-mm@kvack.org>; Tue, 15 May 2018 17:33:40 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id r7-v6so4610685ith.5
        for <linux-mm@kvack.org>; Tue, 15 May 2018 14:33:40 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id c63-v6si1034804itb.89.2018.05.15.14.33.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 May 2018 14:33:39 -0700 (PDT)
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w4FLQxdJ153407
	for <linux-mm@kvack.org>; Tue, 15 May 2018 21:33:38 GMT
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2120.oracle.com with ESMTP id 2hx29w290v-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Tue, 15 May 2018 21:33:38 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w4FLXabg029268
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Tue, 15 May 2018 21:33:37 GMT
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w4FLXavE026451
	for <linux-mm@kvack.org>; Tue, 15 May 2018 21:33:36 GMT
Received: by mail-oi0-f48.google.com with SMTP id b130-v6so1545120oif.12
        for <linux-mm@kvack.org>; Tue, 15 May 2018 14:33:36 -0700 (PDT)
MIME-Version: 1.0
References: <20180515175124.1770-1-pasha.tatashin@oracle.com> <20180515141240.c7587ed53a0ff32ff984e3d2@linux-foundation.org>
In-Reply-To: <20180515141240.c7587ed53a0ff32ff984e3d2@linux-foundation.org>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Tue, 15 May 2018 17:33:00 -0400
Message-ID: <CAGM2reaoLmTa6v5rsOHFwcBYuxYq0AEoOy8BJktWN-WibWoEVA@mail.gmail.com>
Subject: Re: [PATCH v5] mm: don't allow deferred pages with NEED_PER_CPU_KM
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, LKML <linux-kernel@vger.kernel.org>, tglx@linutronix.de, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, mgorman@techsingularity.net, mingo@kernel.org, peterz@infradead.org, Steven Rostedt <rostedt@goodmis.org>, Fengguang Wu <fengguang.wu@intel.com>, Dennis Zhou <dennisszhou@gmail.com>

> > My recent fix exposed this problem,

> "my recent fix" isn't very useful.  I changed this to identify
> c9e97a1997 ("mm: initialize pages on demand during boot"), yes?

Yes, thank you.

Pavel
