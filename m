Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id DE80E6B004D
	for <linux-mm@kvack.org>; Mon, 14 May 2012 22:43:11 -0400 (EDT)
Message-ID: <4FB1C2DD.6090301@kernel.org>
Date: Tue, 15 May 2012 11:43:41 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: make validate_mm() static
References: <1337044247-4006-1-git-send-email-yuanhan.liu@linux.intel.com>
In-Reply-To: <1337044247-4006-1-git-send-email-yuanhan.liu@linux.intel.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yuanhan Liu <yuanhan.liu@linux.intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 05/15/2012 10:10 AM, Yuanhan Liu wrote:

> validate_mm() is just used in mmap.c only, thus make it static.
> 
> Signed-off-by: Yuanhan Liu <yuanhan.liu@linux.intel.com>

Reveiwed-by: Minchan Kim <minchan@kernel.org>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
