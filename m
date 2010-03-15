Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 28CA26B01AF
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 03:48:13 -0400 (EDT)
Message-ID: <4B9DE635.8030208@redhat.com>
Date: Mon, 15 Mar 2010 09:48:05 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH][RF C/T/D] Unmapped page cache control - via boot parameter
References: <20100315072214.GA18054@balbir.in.ibm.com>
In-Reply-To: <20100315072214.GA18054@balbir.in.ibm.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: KVM development list <kvm@vger.kernel.org>, Rik van Riel <riel@surriel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 03/15/2010 09:22 AM, Balbir Singh wrote:
> Selectively control Unmapped Page Cache (nospam version)
>
> From: Balbir Singh<balbir@linux.vnet.ibm.com>
>
> This patch implements unmapped page cache control via preferred
> page cache reclaim. The current patch hooks into kswapd and reclaims
> page cache if the user has requested for unmapped page control.
> This is useful in the following scenario
>
> - In a virtualized environment with cache!=none, we see
>    double caching - (one in the host and one in the guest). As
>    we try to scale guests, cache usage across the system grows.
>    The goal of this patch is to reclaim page cache when Linux is running
>    as a guest and get the host to hold the page cache and manage it.
>    There might be temporary duplication, but in the long run, memory
>    in the guests would be used for mapped pages.
>    

Well, for a guest, host page cache is a lot slower than guest page cache.

-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
