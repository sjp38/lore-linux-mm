Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 613496B026F
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 16:28:33 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id u130-v6so6876473pgc.0
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 13:28:33 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t127-v6si10908410pfb.303.2018.07.02.13.28.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Jul 2018 13:28:32 -0700 (PDT)
Date: Mon, 2 Jul 2018 13:28:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3] x86/e820: put !E820_TYPE_RAM regions into
 memblock.reserved
Message-Id: <20180702132830.9ee21727cae72a5d52e3052d@linux-foundation.org>
In-Reply-To: <CAGM2reZ6PTYw3NivSCO5WMCrYGJH_-piz8TtYgpwLWT=SnBGYA@mail.gmail.com>
References: <20180607100256.GA9129@hori1.linux.bs1.fc.nec.co.jp>
	<20180613054107.GA5329@hori1.linux.bs1.fc.nec.co.jp>
	<20180613090700.GG13364@dhcp22.suse.cz>
	<20180614051618.GB17860@hori1.linux.bs1.fc.nec.co.jp>
	<20180614053859.GA9863@techadventures.net>
	<20180614063454.GA32419@hori1.linux.bs1.fc.nec.co.jp>
	<20180614213033.GA19374@techadventures.net>
	<20180615010927.GC1196@hori1.linux.bs1.fc.nec.co.jp>
	<20180615072947.GB23273@hori1.linux.bs1.fc.nec.co.jp>
	<20180615084142.GE24039@dhcp22.suse.cz>
	<20180615140000.44tht4f3ek3lh2u2@xakep.localdomain>
	<20180618163616.52645949a8e4a0f73819fd62@linux-foundation.org>
	<CAGM2reZ6PTYw3NivSCO5WMCrYGJH_-piz8TtYgpwLWT=SnBGYA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: mhocko@kernel.org, n-horiguchi@ah.jp.nec.com, Linux Memory Management List <linux-mm@kvack.org>, osalvador@techadventures.net, osalvador@suse.de, Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, willy@infradead.org, LKML <linux-kernel@vger.kernel.org>, mingo@kernel.org, dan.j.williams@intel.com, ying.huang@intel.com

On Mon, 2 Jul 2018 16:05:04 -0400 Pavel Tatashin <pasha.tatashin@oracle.com> wrote:

> > So I expect this patch needs a cc:stable, which I'll add.
> >
> > The optimiation patch seems less important and I'd like to hold that
> > off for 4.19-rc1?
> 
> Hi Andrew,
> 
> Should I resend the optimization patch [1] once 4.18 is released, or
> will you include it, and I do not need to do anything?
> 
> [1] http://lkml.kernel.org/r/20180615155733.1175-1-pasha.tatashin@oracle.com
> 

http://ozlabs.org/~akpm/mmots/broken-out/mm-skip-invalid-pages-block-at-a-time-in-zero_resv_unresv.patch
has been in -mm since Jun 18, so all is well.
