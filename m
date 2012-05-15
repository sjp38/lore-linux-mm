Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id B7FC16B004D
	for <linux-mm@kvack.org>; Tue, 15 May 2012 13:43:54 -0400 (EDT)
Message-ID: <4FB295C5.7080008@redhat.com>
Date: Tue, 15 May 2012 13:43:33 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] swap: allow swap readahead to be merged
References: <1336996709-8304-1-git-send-email-ehrhardt@linux.vnet.ibm.com> <1336996709-8304-2-git-send-email-ehrhardt@linux.vnet.ibm.com>
In-Reply-To: <1336996709-8304-2-git-send-email-ehrhardt@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ehrhardt@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, axboe@kernel.dk

On 05/14/2012 07:58 AM, ehrhardt@linux.vnet.ibm.com wrote:
> From: Christian Ehrhardt<ehrhardt@linux.vnet.ibm.com>
>
> Swap readahead works fine, but the I/O to disk is almost always done in page
> size requests, despite the fact that readahead submits 1<<page-cluster pages
> at a time.
> On older kernels the old per device plugging behavior might have captured
> this and merged the requests, but currently all comes down to much more I/Os
> than required.
>
> On a single device this might not be an issue, but as soon as a server runs
> on shared san resources savin I/Os not only improves swapin throughput but
> also provides a lower resource utilization.

> Signed-off-by: Christian Ehrhardt<ehrhardt@linux.vnet.ibm.com>

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
