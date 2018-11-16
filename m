Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 68E426B0913
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 05:39:08 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id x98-v6so11605567ede.0
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 02:39:08 -0800 (PST)
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id p17-v6si2734ejb.4.2018.11.16.02.39.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Nov 2018 02:39:07 -0800 (PST)
Message-ID: <1542364721.3020.5.camel@suse.com>
Subject: Re: [PATCH 4/5] mm, memory_hotplug: print reason for the offlining
 failure
From: osalvador <osalvador@suse.com>
Date: Fri, 16 Nov 2018 11:38:41 +0100
In-Reply-To: <20181116083020.20260-5-mhocko@kernel.org>
References: <20181116083020.20260-1-mhocko@kernel.org>
	 <20181116083020.20260-5-mhocko@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Baoquan He <bhe@redhat.com>, Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Fri, 2018-11-16 at 09:30 +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> The memory offlining failure reporting is inconsistent and
> insufficient.
> Some error paths simply do not report the failure to the log at all.
> When we do report there are no details about the reason of the
> failure
> and there are several of them which makes memory offlining failures
> hard to debug.
> 
> Make sure that the
> 	memory offlining [mem %#010llx-%#010llx] failed
> message is printed for all failures and also provide a short textual
> reason for the failure e.g.
> 
> [ 1984.506184] rac1 kernel: memory offlining [mem 0x82600000000-
> 0x8267fffffff] failed due to signal backoff
> 
> this tells us that the offlining has failed because of a signal
> pending
> aka user intervention.
> 
> [akpm: tweak messages a bit]
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Reviewed-by: Oscar Salvador <osalvador@suse.de>
