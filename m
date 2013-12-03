Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f47.google.com (mail-qa0-f47.google.com [209.85.216.47])
	by kanga.kvack.org (Postfix) with ESMTP id 4375E6B0071
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 18:07:55 -0500 (EST)
Received: by mail-qa0-f47.google.com with SMTP id w5so6078090qac.13
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 15:07:55 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id b15si29663564qey.134.2013.12.03.15.07.54
        for <linux-mm@kvack.org>;
        Tue, 03 Dec 2013 15:07:54 -0800 (PST)
Message-ID: <529E6447.4030304@redhat.com>
Date: Tue, 03 Dec 2013 18:07:51 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 04/15] mm: numa: Serialise parallel get_user_page against
 THP migration
References: <1386060721-3794-1-git-send-email-mgorman@suse.de> <1386060721-3794-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1386060721-3794-5-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Alex Thorlton <athorlton@sgi.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/03/2013 03:51 AM, Mel Gorman wrote:

> +
> +	if (page_count(page) != 2) {
> +		set_pmd_at(mm, mmun_start, pmd, orig_entry);
> +		flush_tlb_range(vma, mmun_start, mmun_end);

The mmun_start and mmun_end variables are introduced in patch 5.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
