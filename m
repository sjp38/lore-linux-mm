Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6B6A26B0275
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 16:32:28 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id p19-v6so14452296ioh.4
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 13:32:28 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id g4-v6si11034361ioa.9.2018.07.02.13.32.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 13:32:27 -0700 (PDT)
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w62KSjo8113518
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 20:32:26 GMT
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by aserp2130.oracle.com with ESMTP id 2jwyccp479-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 02 Jul 2018 20:32:26 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w62KWPaG026271
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 20:32:25 GMT
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w62KWP3Z028244
	for <linux-mm@kvack.org>; Mon, 2 Jul 2018 20:32:25 GMT
Received: by mail-oi0-f42.google.com with SMTP id 13-v6so6437576ois.1
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 13:32:24 -0700 (PDT)
MIME-Version: 1.0
References: <20180607100256.GA9129@hori1.linux.bs1.fc.nec.co.jp>
 <20180613054107.GA5329@hori1.linux.bs1.fc.nec.co.jp> <20180613090700.GG13364@dhcp22.suse.cz>
 <20180614051618.GB17860@hori1.linux.bs1.fc.nec.co.jp> <20180614053859.GA9863@techadventures.net>
 <20180614063454.GA32419@hori1.linux.bs1.fc.nec.co.jp> <20180614213033.GA19374@techadventures.net>
 <20180615010927.GC1196@hori1.linux.bs1.fc.nec.co.jp> <20180615072947.GB23273@hori1.linux.bs1.fc.nec.co.jp>
 <20180615084142.GE24039@dhcp22.suse.cz> <20180615140000.44tht4f3ek3lh2u2@xakep.localdomain>
 <20180618163616.52645949a8e4a0f73819fd62@linux-foundation.org>
 <CAGM2reZ6PTYw3NivSCO5WMCrYGJH_-piz8TtYgpwLWT=SnBGYA@mail.gmail.com> <20180702132830.9ee21727cae72a5d52e3052d@linux-foundation.org>
In-Reply-To: <20180702132830.9ee21727cae72a5d52e3052d@linux-foundation.org>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Mon, 2 Jul 2018 16:31:48 -0400
Message-ID: <CAGM2reaUHFX63ZKiiDhXriUmtLAxH3QOePbm7mGkRMgjNXtTXQ@mail.gmail.com>
Subject: Re: [PATCH v3] x86/e820: put !E820_TYPE_RAM regions into memblock.reserved
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mhocko@kernel.org, n-horiguchi@ah.jp.nec.com, Linux Memory Management List <linux-mm@kvack.org>, osalvador@techadventures.net, osalvador@suse.de, Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, willy@infradead.org, LKML <linux-kernel@vger.kernel.org>, mingo@kernel.org, dan.j.williams@intel.com, ying.huang@intel.com

> http://ozlabs.org/~akpm/mmots/broken-out/mm-skip-invalid-pages-block-at-a-time-in-zero_resv_unresv.patch
> has been in -mm since Jun 18, so all is well.

Ah missed it. Thank you.

Pavel
