Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id D104E6B02B3
	for <linux-mm@kvack.org>; Tue, 15 May 2018 12:00:11 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id ay8-v6so333091plb.9
        for <linux-mm@kvack.org>; Tue, 15 May 2018 09:00:11 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id a4-v6si325536plp.219.2018.05.15.09.00.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 May 2018 09:00:07 -0700 (PDT)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w4FFtwit169879
	for <linux-mm@kvack.org>; Tue, 15 May 2018 16:00:04 GMT
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by aserp2120.oracle.com with ESMTP id 2hx29w1456-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Tue, 15 May 2018 16:00:04 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w4FG02ir020494
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Tue, 15 May 2018 16:00:03 GMT
Received: from abhmp0007.oracle.com (abhmp0007.oracle.com [141.146.116.13])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w4FG0200019742
	for <linux-mm@kvack.org>; Tue, 15 May 2018 16:00:02 GMT
Received: by mail-ot0-f179.google.com with SMTP id t1-v6so779859oth.8
        for <linux-mm@kvack.org>; Tue, 15 May 2018 09:00:01 -0700 (PDT)
MIME-Version: 1.0
References: <20180510115356.31164-1-pasha.tatashin@oracle.com>
 <20180510123039.GF5325@dhcp22.suse.cz> <CAGM2reZbYR96_uv-SB=5eL6tt0OSq9yXhtA-B2TGHbRQtfGU6g@mail.gmail.com>
 <20180515091036.GC12670@dhcp22.suse.cz> <CAGM2reaQusBA-nmQ5xqH4u-EVxgJCnaHAZs=1AXFOpNWTh7VbQ@mail.gmail.com>
 <20180515125541.GH12670@dhcp22.suse.cz>
In-Reply-To: <20180515125541.GH12670@dhcp22.suse.cz>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Tue, 15 May 2018 11:59:25 -0400
Message-ID: <CAGM2reYGFjG38FW0nEf1gwRMfDyVQ7QCGZ83VewxXgedeT=Zsg@mail.gmail.com>
Subject: Re: [PATCH v2] mm: allow deferred page init for vmemmap only
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, tglx@linutronix.de, Linux Memory Management List <linux-mm@kvack.org>, mgorman@techsingularity.net, mingo@kernel.org, peterz@infradead.org, Steven Rostedt <rostedt@goodmis.org>, Fengguang Wu <fengguang.wu@intel.com>, Dennis Zhou <dennisszhou@gmail.com>

> This will always be a maze as the early boot tends to be. Sad but true.
> That is why I am not really convinced we should use a large hammer and
> disallow deferred page initialization just because UP implementation of
> pcp does something too early. We should instead rule that one odd case.
> Your patch simply doesn't rule a large class of potential issues. It
> just rules out a potentially useful feature for an odd case. See my
> point?

Hi Michal,

OK, I will send an updated patch with disabling deferred pages only whe
NEED_PER_CPU_KM. Hopefully, we won't see similar issues in other places.

Thank you,
Pavel
