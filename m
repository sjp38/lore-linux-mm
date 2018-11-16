Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 90F8E6B090C
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 05:34:38 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id d41so5348896eda.12
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 02:34:38 -0800 (PST)
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id a12-v6si203034ejk.197.2018.11.16.02.34.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Nov 2018 02:34:37 -0800 (PST)
Message-ID: <1542364443.3020.3.camel@suse.com>
Subject: Re: [PATCH 3/5] mm, memory_hotplug: drop pointless block alignment
 checks from __offline_pages
From: osalvador <osalvador@suse.com>
Date: Fri, 16 Nov 2018 11:34:03 +0100
In-Reply-To: <20181116083020.20260-4-mhocko@kernel.org>
References: <20181116083020.20260-1-mhocko@kernel.org>
	 <20181116083020.20260-4-mhocko@kernel.org>
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
> This function is never called from a context which would provide
> misaligned pfn range so drop the pointless check.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

I vaguely remember that someone reported a problem about misaligned
range on powerpc.
Not sure at which stage was (online/offline).
Although I am not sure if that was valid at all.

Reviewed-by: Oscar Salvador <osalvador@suse.de>
