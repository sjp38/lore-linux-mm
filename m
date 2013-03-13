Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 388FC6B0006
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 12:31:57 -0400 (EDT)
Message-ID: <5140A9F7.6010401@redhat.com>
Date: Wed, 13 Mar 2013 12:31:51 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] vmscan: minor cleanup for kswapd
References: <CAJd=RBDPPpqhHh3CJAwkC4J=tukDLErwf6juS+x3irvu3PHdbA@mail.gmail.com>
In-Reply-To: <CAJd=RBDPPpqhHh3CJAwkC4J=tukDLErwf6juS+x3irvu3PHdbA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 03/10/2013 12:05 AM, Hillf Danton wrote:
> The local variable, total_scanned, is no longer used, so clean up now.
>
> Signed-off-by: Hillf Danton <dhillf@gmail.com>

Acked-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
