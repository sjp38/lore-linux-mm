Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 7E4FD6B0034
	for <linux-mm@kvack.org>; Fri, 24 May 2013 13:06:56 -0400 (EDT)
Date: Fri, 24 May 2013 18:06:44 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH 3/3] mm/kmemleak.c: Merge the consecutive scan-areas.
Message-ID: <20130524170644.GB22600@arm.com>
References: <519224DF.3070807@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <519224DF.3070807@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: majianpeng <majianpeng@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Tue, May 14, 2013 at 12:49:51PM +0100, majianpeng wrote:
> If the scan-areas are adjacent,it can merge in order to reduce memomy.

Have you found any significant reduction in the memory size?

What we miss though is removing an area (and I found a use-case for it).

> +    hlist_for_each_entry(area, &object->area_list, node) {
> +        if (ptr + size == area->start) {
> +            area->start = ptr;
> +            area->size += size;
> +            goto out_unlock;
> +        } else if (ptr == area->start + area->size) {
> +            area->size += size;
> +            goto out_unlock;

I prefer to keep 'goto' only for the error path. You could add a 'bool
merged' and another 'if' block for area allocation.

I'll pick the other too patches.

Thanks.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
