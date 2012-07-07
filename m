Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 1CFBD6B0074
	for <linux-mm@kvack.org>; Sat,  7 Jul 2012 09:45:40 -0400 (EDT)
Date: Sat, 7 Jul 2012 21:45:28 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH 1/7] memcg: update cgroup memory document
Message-ID: <20120707134528.GA23648@localhost>
References: <1340880885-5427-1-git-send-email-handai.szj@taobao.com>
 <1340881055-5511-1-git-send-email-handai.szj@taobao.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1340881055-5511-1-git-send-email-handai.szj@taobao.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, gthelen@google.com, yinghan@google.com, akpm@linux-foundation.org, mhocko@suse.cz, linux-kernel@vger.kernel.org, Sha Zhengju <handai.szj@taobao.com>

> +dirty		- # of bytes that are waiting to get written back to the disk.
> +writeback	- # of bytes that are actively being written back to the disk.

This should be a bit more clear to the user:

dirty - # of bytes of file cache that are not in sync with the disk copy
writeback - # of bytes of file cache that are queued for syncing to disk

Thanks,
Fengguang

>  inactive_anon	- # of bytes of anonymous memory and swap cache memory on
>  		LRU list.
>  active_anon	- # of bytes of anonymous and swap cache memory on active

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
