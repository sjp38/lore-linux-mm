Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 115D98E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 16:26:08 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id t7so10343796edr.21
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 13:26:08 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n25sor9553141edd.1.2018.12.18.13.26.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Dec 2018 13:26:06 -0800 (PST)
Date: Tue, 18 Dec 2018 21:26:05 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] memory_hotplug: add missing newlines to debugging output
Message-ID: <20181218212605.4wa35jzlewp3rj7f@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181218162307.10518-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181218162307.10518-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pavel Tatashin <pasha.tatashin@soleen.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue, Dec 18, 2018 at 05:23:07PM +0100, Michal Hocko wrote:
>From: Michal Hocko <mhocko@suse.com>
>
>pages_correctly_probed is missing new lines which means that the line is
>not printed rightaway but it rather waits for additional printks.
>
>Add \n to all three messages in pages_correctly_probed.
>
>Fixes: b77eab7079d9 ("mm/memory_hotplug: optimize probe routine")
>Signed-off-by: Michal Hocko <mhocko@suse.com>

Reviewed-by: Wei Yang <richard.weiyang@gmail.com>

>---
> drivers/base/memory.c | 6 +++---
> 1 file changed, 3 insertions(+), 3 deletions(-)
>
>diff --git a/drivers/base/memory.c b/drivers/base/memory.c
>index 0e5985682642..b5ff45ab7967 100644
>--- a/drivers/base/memory.c
>+++ b/drivers/base/memory.c
>@@ -207,15 +207,15 @@ static bool pages_correctly_probed(unsigned long start_pfn)
> 			return false;
> 
> 		if (!present_section_nr(section_nr)) {
>-			pr_warn("section %ld pfn[%lx, %lx) not present",
>+			pr_warn("section %ld pfn[%lx, %lx) not present\n",
> 				section_nr, pfn, pfn + PAGES_PER_SECTION);
> 			return false;
> 		} else if (!valid_section_nr(section_nr)) {
>-			pr_warn("section %ld pfn[%lx, %lx) no valid memmap",
>+			pr_warn("section %ld pfn[%lx, %lx) no valid memmap\n",
> 				section_nr, pfn, pfn + PAGES_PER_SECTION);
> 			return false;
> 		} else if (online_section_nr(section_nr)) {
>-			pr_warn("section %ld pfn[%lx, %lx) is already online",
>+			pr_warn("section %ld pfn[%lx, %lx) is already online\n",
> 				section_nr, pfn, pfn + PAGES_PER_SECTION);
> 			return false;
> 		}
>-- 
>2.19.2

-- 
Wei Yang
Help you, Help me
