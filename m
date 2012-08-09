Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 36A856B005A
	for <linux-mm@kvack.org>; Wed,  8 Aug 2012 21:40:20 -0400 (EDT)
Message-ID: <502314FD.7090701@redhat.com>
Date: Wed, 08 Aug 2012 21:40:13 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 3/3] mm: add vm event counters for balloon pages compaction
References: <cover.1344463786.git.aquini@redhat.com> <768e09520a249fd78f706cd8ae53d511f9db0aaa.1344463786.git.aquini@redhat.com>
In-Reply-To: <768e09520a249fd78f706cd8ae53d511f9db0aaa.1344463786.git.aquini@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>

On 08/08/2012 06:53 PM, Rafael Aquini wrote:
> This patch is only for testing report purposes and shall be dropped in case of
> the rest of this patchset getting accepted for merging.

I wonder if it would make sense to just keep these statistics, so
if a change breaks balloon migration in the future, we'll be able
to see it...

> Signed-off-by: Rafael Aquini<aquini@redhat.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
