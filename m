Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 1342E6B0034
	for <linux-mm@kvack.org>; Sat, 14 Sep 2013 11:55:24 -0400 (EDT)
Message-ID: <523486E4.3000206@redhat.com>
Date: Sat, 14 Sep 2013 11:55:16 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH] mm: numa: adjust hinting fault record if page is
 migrated
References: <20130914115335.3AA33428001@webmail.sinamail.sina.com.cn>
In-Reply-To: <20130914115335.3AA33428001@webmail.sinamail.sina.com.cn>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dhillf@sina.com
Cc: Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Hillf Danton <dhillf@gmail.com>

On 09/14/2013 07:53 AM, Hillf Danton wrote:
> After page A on source node is migrated to page B on target node, hinting
> fault is recorded on the target node for B. On the source node there is
> another record for A, since a two-stage filter is used when migrating pages.
> 
> Page A is no longer used after migration, so we have to erase its record.

What kind of performance changes have you observed with this patch?

What benchmarks have you run, and on what kind of systems?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
