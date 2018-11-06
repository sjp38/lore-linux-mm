Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id A00B46B0308
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 06:01:04 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id b34-v6so7562947edb.3
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 03:01:04 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 34-v6si1429456edu.308.2018.11.06.03.01.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Nov 2018 03:01:03 -0800 (PST)
Message-ID: <1541502047.2871.2.camel@suse.de>
Subject: Re: [PATCH] mm, memory_hotplug: check zone_movable in
 has_unmovable_pages
From: osalvador <osalvador@suse.de>
Date: Tue, 06 Nov 2018 12:00:47 +0100
In-Reply-To: <20181106095524.14629-1-mhocko@kernel.org>
References: <20181106095524.14629-1-mhocko@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Baoquan He <bhe@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue, 2018-11-06 at 10:55 +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Reported-and-tested-by: Baoquan He <bhe@redhat.com>
> Acked-by: Baoquan He <bhe@redhat.com>
> Fixes: "mm, memory_hotplug: make has_unmovable_pages more robust")
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Looks good to me.

Reviewed-by: Oscar Salvador <osalvador@suse.de>


Oscar Salvador
