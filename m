Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0B4226B0007
	for <linux-mm@kvack.org>; Fri, 15 Jun 2018 10:10:13 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id b65-v6so4290848plb.5
        for <linux-mm@kvack.org>; Fri, 15 Jun 2018 07:10:13 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n2-v6si6528981pgu.420.2018.06.15.07.10.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Jun 2018 07:10:11 -0700 (PDT)
Date: Fri, 15 Jun 2018 16:10:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] x86/e820: put !E820_TYPE_RAM regions into
 memblock.reserved
Message-ID: <20180615141008.GJ24039@dhcp22.suse.cz>
References: <20180613054107.GA5329@hori1.linux.bs1.fc.nec.co.jp>
 <20180613090700.GG13364@dhcp22.suse.cz>
 <20180614051618.GB17860@hori1.linux.bs1.fc.nec.co.jp>
 <20180614053859.GA9863@techadventures.net>
 <20180614063454.GA32419@hori1.linux.bs1.fc.nec.co.jp>
 <20180614213033.GA19374@techadventures.net>
 <20180615010927.GC1196@hori1.linux.bs1.fc.nec.co.jp>
 <20180615072947.GB23273@hori1.linux.bs1.fc.nec.co.jp>
 <20180615084142.GE24039@dhcp22.suse.cz>
 <20180615140000.44tht4f3ek3lh2u2@xakep.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180615140000.44tht4f3ek3lh2u2@xakep.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Oscar Salvador <osalvador@techadventures.net>, Oscar Salvador <osalvador@suse.de>, Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Matthew Wilcox <willy@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "mingo@kernel.org" <mingo@kernel.org>, "dan.j.williams@intel.com" <dan.j.williams@intel.com>, Huang Ying <ying.huang@intel.com>

On Fri 15-06-18 10:00:00, Pavel Tatashin wrote:
[...]
> But, I think the 2nd patch with the optimization above should go along this
> this fix.

Yes, ideally with some numbers.
-- 
Michal Hocko
SUSE Labs
