Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 1A7386B01AD
	for <linux-mm@kvack.org>; Fri, 25 Jun 2010 10:10:41 -0400 (EDT)
Message-ID: <4C24B8DA.3000706@redhat.com>
Date: Fri, 25 Jun 2010 10:10:34 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] vmscan: zone_reclaim don't call disable_swap_token()
References: <20100625173002.8052.A69D9226@jp.fujitsu.com>
In-Reply-To: <20100625173002.8052.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 06/25/2010 04:31 AM, KOSAKI Motohiro wrote:
> Swap token don't works when zone reclaim is enabled since it was born.
> Because __zone_reclaim() always call disable_swap_token()
> unconditionally.
>
> This kill swap token feature completely. As far as I know, nobody want
> to that. Remove it.
>
> Cc: Rik van Riel<riel@redhat.com>
> Cc: Christoph Lameter<cl@linux-foundation.org>
> Signed-off-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>

You are absolutely right.

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
