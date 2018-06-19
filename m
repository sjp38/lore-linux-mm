Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0BF4A6B0003
	for <linux-mm@kvack.org>; Mon, 18 Jun 2018 20:50:23 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id z10-v6so16325989qki.5
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 17:50:23 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id k42-v6si15867375qtc.66.2018.06.18.17.50.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jun 2018 17:50:21 -0700 (PDT)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w5J0mjux035405
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 00:50:21 GMT
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by aserp2120.oracle.com with ESMTP id 2jmtgwp4f3-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 00:50:21 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w5J0oK7i031770
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 00:50:20 GMT
Received: from abhmp0001.oracle.com (abhmp0001.oracle.com [141.146.116.7])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w5J0oKro028576
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 00:50:20 GMT
Received: by mail-oi0-f51.google.com with SMTP id a141-v6so16600975oii.8
        for <linux-mm@kvack.org>; Mon, 18 Jun 2018 17:50:20 -0700 (PDT)
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
Date: Mon, 18 Jun 2018 20:49:39 -0400
Message-ID: <CAGM2reboodsYSbu6PPDNoFS7zWH0W1w84TCgouu0EL4sOyGbMg@mail.gmail.com>
Subject: Re: [PATCH v3] x86/e820: put !E820_TYPE_RAM regions into memblock.reserved
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mhocko@kernel.org, n-horiguchi@ah.jp.nec.com, Linux Memory Management List <linux-mm@kvack.org>, osalvador@techadventures.net, osalvador@suse.de, Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, willy@infradead.org, LKML <linux-kernel@vger.kernel.org>, mingo@kernel.org, dan.j.williams@intel.com, ying.huang@intel.com

> So I expect this patch needs a cc:stable, which I'll add.
Yes.
> The optimiation patch seems less important and I'd like to hold that
> off for 4.19-rc1?
I agree, the optimization is not as important, and can wait for 4.19.
