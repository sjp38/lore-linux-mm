Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 11D2B6B0035
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 16:27:44 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id lj1so3159203pab.29
        for <linux-mm@kvack.org>; Tue, 19 Nov 2013 13:27:44 -0800 (PST)
Received: from psmtp.com ([74.125.245.172])
        by mx.google.com with SMTP id v7si12484398pbi.338.2013.11.19.13.27.42
        for <linux-mm@kvack.org>;
        Tue, 19 Nov 2013 13:27:43 -0800 (PST)
Message-ID: <528BD7B8.4030108@oracle.com>
Date: Tue, 19 Nov 2013 14:27:20 -0700
From: Khalid Aziz <khalid.aziz@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] mm: hugetlb: use get_page_foll in follow_hugetlb_page
References: <1384537668-10283-1-git-send-email-aarcange@redhat.com> <1384537668-10283-3-git-send-email-aarcange@redhat.com>
In-Reply-To: <1384537668-10283-3-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pravin Shelar <pshelar@nicira.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ben Hutchings <bhutchings@solarflare.com>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

On 11/15/2013 10:47 AM, Andrea Arcangeli wrote:
> get_page_foll is more optimal and is always safe to use under the PT
> lock. More so for hugetlbfs as there's no risk of race conditions with
> split_huge_page regardless of the PT lock.
>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>

--
Khalid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
