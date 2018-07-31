Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6841E6B000A
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 09:04:38 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id d5-v6so3478150edq.3
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 06:04:38 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b101-v6si3417895edf.205.2018.07.31.06.04.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jul 2018 06:04:37 -0700 (PDT)
Date: Tue, 31 Jul 2018 15:04:34 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: make __paginginit based on CONFIG_MEMORY_HOTPLUG
Message-ID: <20180731130434.GL4557@dhcp22.suse.cz>
References: <20180731124504.27582-1-osalvador@techadventures.net>
 <CAGM2rebds=A5m1ZB1LtD7oxMzM9gjVQvm-QibHjEENmXViw5eA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGM2rebds=A5m1ZB1LtD7oxMzM9gjVQvm-QibHjEENmXViw5eA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: osalvador@techadventures.net, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, kirill.shutemov@linux.intel.com, iamjoonsoo.kim@lge.com, Mel Gorman <mgorman@suse.de>, Souptick Joarder <jrdr.linux@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, osalvador@suse.de

On Tue 31-07-18 08:49:11, Pavel Tatashin wrote:
> Hi Oscar,
> 
> Have you looked into replacing __paginginit via __meminit ? What is
> the reason to keep both?

All these init variants make my head spin so reducing their number is
certainly a desirable thing to do. b5a0e01132943 has added this variant
so it might give a clue about the dependencies.
-- 
Michal Hocko
SUSE Labs
