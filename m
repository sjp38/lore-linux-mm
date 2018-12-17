Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id EC0178E0001
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 07:28:14 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id b7so8580676eda.10
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 04:28:14 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i88si5080346edd.48.2018.12.17.04.28.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 04:28:13 -0800 (PST)
Date: Mon, 17 Dec 2018 13:28:12 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 1/1] mm, memory_hotplug: Initialize struct pages for
 the full memory section
Message-ID: <20181217122812.GJ30879@dhcp22.suse.cz>
References: <20181212172712.34019-1-zaslonko@linux.ibm.com>
 <20181212172712.34019-2-zaslonko@linux.ibm.com>
 <476a80cb-5524-16c1-6dd5-da5febbd6139@redhat.com>
 <bcd0c49c-e417-ef8b-996f-99ecef540d9c@redhat.com>
 <20181214202315.1c685f1e@thinkpad>
 <cffab731-81e0-b80c-665e-c9a62faed4ec@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cffab731-81e0-b80c-665e-c9a62faed4ec@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>, Mikhail Zaslonko <zaslonko@linux.ibm.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pavel.Tatashin@microsoft.com, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com

On Mon 17-12-18 10:38:32, David Hildenbrand wrote:
[...]
> I am wondering if we should fix this on the memblock level instead than.
> Something like, before handing memory over to the page allocator, add
> memory as reserved up to the last section boundary. Or even when setting
> the physical memory limit (mem= scenario).

Memory initialization is spread over several places and that makes it
really hard to grasp and maintain. I do not really see why we should
make memblock even more special. We do intialize the section worth of
memory here so it sounds like a proper place to quirk for incomplete
sections.
-- 
Michal Hocko
SUSE Labs
