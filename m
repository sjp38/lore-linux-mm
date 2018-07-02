Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 335D46B0006
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 16:05:43 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id x13-v6so14189799iog.16
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 13:05:43 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id s188-v6si4652732iod.68.2018.07.02.13.05.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 13:05:42 -0700 (PDT)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w62K4bpP102376
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 20:05:41 GMT
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by aserp2120.oracle.com with ESMTP id 2jx1tnwvy2-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 02 Jul 2018 20:05:41 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w62K5eS3016988
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 20:05:40 GMT
Received: from abhmp0014.oracle.com (abhmp0014.oracle.com [141.146.116.20])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w62K5eUg011453
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 20:05:40 GMT
Received: by mail-oi0-f52.google.com with SMTP id d189-v6so9983480oib.6
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 13:05:39 -0700 (PDT)
MIME-Version: 1.0
References: <20180607100256.GA9129@hori1.linux.bs1.fc.nec.co.jp>
 <20180613054107.GA5329@hori1.linux.bs1.fc.nec.co.jp> <20180613090700.GG13364@dhcp22.suse.cz>
 <20180614051618.GB17860@hori1.linux.bs1.fc.nec.co.jp> <20180614053859.GA9863@techadventures.net>
 <20180614063454.GA32419@hori1.linux.bs1.fc.nec.co.jp> <20180614213033.GA19374@techadventures.net>
 <20180615010927.GC1196@hori1.linux.bs1.fc.nec.co.jp> <20180615072947.GB23273@hori1.linux.bs1.fc.nec.co.jp>
 <20180615084142.GE24039@dhcp22.suse.cz> <20180615140000.44tht4f3ek3lh2u2@xakep.localdomain>
 <20180618163616.52645949a8e4a0f73819fd62@linux-foundation.org>
In-Reply-To: <20180618163616.52645949a8e4a0f73819fd62@linux-foundation.org>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Mon, 2 Jul 2018 16:05:04 -0400
Message-ID: <CAGM2reZ6PTYw3NivSCO5WMCrYGJH_-piz8TtYgpwLWT=SnBGYA@mail.gmail.com>
Subject: Re: [PATCH v3] x86/e820: put !E820_TYPE_RAM regions into memblock.reserved
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mhocko@kernel.org, n-horiguchi@ah.jp.nec.com, Linux Memory Management List <linux-mm@kvack.org>, osalvador@techadventures.net, osalvador@suse.de, Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, willy@infradead.org, LKML <linux-kernel@vger.kernel.org>, mingo@kernel.org, dan.j.williams@intel.com, ying.huang@intel.com

> So I expect this patch needs a cc:stable, which I'll add.
>
> The optimiation patch seems less important and I'd like to hold that
> off for 4.19-rc1?

Hi Andrew,

Should I resend the optimization patch [1] once 4.18 is released, or
will you include it, and I do not need to do anything?

[1] http://lkml.kernel.org/r/20180615155733.1175-1-pasha.tatashin@oracle.com

Thank you,
Pavel
