Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A865F6B010E
	for <linux-mm@kvack.org>; Wed, 13 May 2009 10:46:56 -0400 (EDT)
Message-ID: <4A0ADD88.9080705@redhat.com>
Date: Wed, 13 May 2009 10:47:36 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] zone_reclaim_mode is always 0 by default
References: <20090513120155.5879.A69D9226@jp.fujitsu.com> <20090513120729.5885.A69D9226@jp.fujitsu.com>
In-Reply-To: <20090513120729.5885.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
> Subject: [PATCH] zone_reclaim_mode is always 0 by default
> 
> Current linux policy is, if the machine has large remote node distance,
>  zone_reclaim_mode is enabled by default because we've be able to assume to 
> large distance mean large server until recently.
> 
> Unfrotunately, recent modern x86 CPU (e.g. Core i7, Opeteron) have P2P transport
> memory controller. IOW it's NUMA from software view.
> 
> Some Core i7 machine has large remote node distance and zone_reclaim don't
> fit desktop and small file server. it cause performance degression.
> 
> Thus, zone_reclaim == 0 is better by default. sorry, HPC gusy. 
> you need to turn zone_reclaim_mode on manually now.

I'll believe that it causes a performance regression with the
old zone_reclaim behaviour, however the way you tweaked
zone_reclaim should make it behave a lot better, no?

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
