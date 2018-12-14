Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E69BD8E01D1
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 06:25:24 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id c3so2673720eda.3
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 03:25:24 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 91si10546eda.102.2018.12.14.03.25.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Dec 2018 03:25:23 -0800 (PST)
Subject: Re: [PATCHv3] mm/pageblock: throw compiling time error if
 pageblock_bits can not hold MIGRATE_TYPES
References: <1544508709-11358-1-git-send-email-kernelfans@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <f11c25b0-2933-cc1a-aeb4-c7fbb462ac5f@suse.cz>
Date: Fri, 14 Dec 2018 12:22:22 +0100
MIME-Version: 1.0
In-Reply-To: <1544508709-11358-1-git-send-email-kernelfans@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pingfan Liu <kernelfans@gmail.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Oscar Salvador <osalvador@suse.de>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Alexander Duyck <alexander.h.duyck@linux.intel.com>

On 12/11/18 7:11 AM, Pingfan Liu wrote:
> Currently, NR_PAGEBLOCK_BITS and MIGRATE_TYPES are not associated by code.
> If someone adds extra migrate type, then he may forget to enlarge the
> NR_PAGEBLOCK_BITS. Hence it requires some way to fix.
> NR_PAGEBLOCK_BITS depends on MIGRATE_TYPES, while these macro
> spread on two different .h file with reverse dependency, it is a little
> hard to refer to MIGRATE_TYPES in pageblock-flag.h. This patch tries to
> remind such relation in compiling-time.
> 
> Signed-off-by: Pingfan Liu <kernelfans@gmail.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>
