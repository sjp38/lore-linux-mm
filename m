Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 764436B058E
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 01:23:28 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id w129-v6so7971009oib.18
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 22:23:28 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 6-v6si1102475oip.83.2018.11.07.22.23.27
        for <linux-mm@kvack.org>;
        Wed, 07 Nov 2018 22:23:27 -0800 (PST)
Subject: Re: [RFC PATCH 4/5] mm, memory_hotplug: print reason for the
 offlining failure
References: <20181107101830.17405-1-mhocko@kernel.org>
 <20181107101830.17405-5-mhocko@kernel.org>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <18bd20ff-7b3c-bcf2-042d-5ab59fdd42e1@arm.com>
Date: Thu, 8 Nov 2018 11:53:21 +0530
MIME-Version: 1.0
In-Reply-To: <20181107101830.17405-5-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <OSalvador@suse.com>, Baoquan He <bhe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>



On 11/07/2018 03:48 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> The memory offlining failure reporting is inconsistent and insufficient.
> Some error paths simply do not report the failure to the log at all.
> When we do report there are no details about the reason of the failure
> and there are several of them which makes memory offlining failures
> hard to debug.
> 
> Make sure that the
> 	memory offlining [mem %#010llx-%#010llx] failed
> message is printed for all failures and also provide a short textual
> reason for the failure e.g.
> 
> [ 1984.506184] rac1 kernel: memory offlining [mem 0x82600000000-0x8267fffffff] failed due to signal backoff
> 
> this tells us that the offlining has failed because of a signal pending
> aka user intervention.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

It might help to enumerate these failure reason strings and use macros.
