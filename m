Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 685C36B0005
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 04:43:09 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id c3so2286868eda.3
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 01:43:09 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bq27-v6si6442440ejb.275.2018.11.13.01.43.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Nov 2018 01:43:07 -0800 (PST)
Date: Tue, 13 Nov 2018 10:43:05 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: UBSAN: Undefined behaviour in mm/page_alloc.c
Message-ID: <20181113094305.GM15120@dhcp22.suse.cz>
References: <CAEAjamseRRHu+TaTkd1TwpLNm8mtDGP=2K0WKLF0wH-3iLcW_w@mail.gmail.com>
 <20181109084353.GA5321@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181109084353.GA5321@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Kyungtae Kim <kt0755@gmail.com>, pavel.tatashin@microsoft.com, vbabka@suse.cz, osalvador@suse.de, rppt@linux.vnet.ibm.com, aaron.lu@intel.com, iamjoonsoo.kim@lge.com, alexander.h.duyck@linux.intel.com, mgorman@techsingularity.net, lifeasageek@gmail.com, threeearcat@gmail.com, syzkaller@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

Andrew, could you take the patch please? This patch contains a comment
update as suggested by Tetsuo. I do not think there were any other
unresolved concerns.
