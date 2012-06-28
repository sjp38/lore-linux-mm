Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 40D946B005A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 16:19:55 -0400 (EDT)
Message-ID: <4FECBC50.2060705@sandia.gov>
Date: Thu, 28 Jun 2012 14:19:28 -0600
From: "Jim Schutt" <jaschut@sandia.gov>
MIME-Version: 1.0
Subject: Re: [PATCH -mm v2] mm: have order > 0 compaction start off
 where it left
References: <20120628135520.0c48b066@annuminas.surriel.com>
In-Reply-To: <20120628135520.0c48b066@annuminas.surriel.com>
Content-Type: text/plain;
 charset=utf-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com

On 06/28/2012 11:55 AM, Rik van Riel wrote:

> ---
> v2: implement Mel's suggestions, handling wrap-around etc
>

So far I've run a total of ~28 TB of data over seventy minutes
or so through 12 machines running this version of the patch;
still no hint of trouble, still great performance.

Tested-by: Jim Schutt <jaschut@sandia.gov>

Thanks!

-- Jim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
