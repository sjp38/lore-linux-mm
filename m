Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 4D7C36B0062
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 03:09:31 -0500 (EST)
Date: Wed, 9 Jan 2013 16:09:17 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: fadvise doesn't work well.
Message-ID: <20130109080917.GA21056@localhost>
References: <1357718721.6568.3.camel@kernel.cn.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1357718721.6568.3.camel@kernel.cn.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, hughd@google.com, riel@redhat.com, Johannes Weiner <hannes@cmpxchg.org>, mtk.manpages@gmail.com

Hi Simon,

Try run "sync" before doing fadvise, because fadvise won't drop
dirty/writeback/mapped pages.

Thanks,
Fengguang

On Wed, Jan 09, 2013 at 02:05:21AM -0600, Simon Jeons wrote:
> In attanchment.

> root@kernel:~/Documents/mm/tools/linux-ftools# dd if=../../../images/ubuntu-11.04-desktop-i386.iso of=/tmpfs
> 1403484+0 records in
> 1403484+0 records out
> 718583808 bytes (719 MB) copied, 19.5054 s, 36.8 MB/s
> root@kernel:~/Documents/mm/tools/linux-ftools# ./linux-fincore -s ../../../images/ubuntu-11.04-desktop-i386.iso 
> filename                                                                                       size        total_pages    min_cached page       cached_pages        cached_size        cached_perc
> --------                                                                                       ----        -----------    ---------------       ------------        -----------        -----------
> ../../../images/ubuntu-11.04-desktop-i386.iso                                             718583808             175436                  0             175436          718585856             100.00
> ---
> total cached size: 718585856
> root@kernel:~/Documents/mm/tools/linux-ftools# ./linux-fadvise ../../../images/ubuntu-11.04-desktop-i386.iso DONTNEED 0,718585856
> Going to fadvise ../../../images/ubuntu-11.04-desktop-i386.iso as mode DONTNEED
> offset: 0
> length: 718583808
> Invalid mode DONTNEED
> root@kernel:~/Documents/mm/tools/linux-ftools# ./linux-fincore -s ../../../images/ubuntu-11.04-desktop-i386.iso 
> filename                                                                                       size        total_pages    min_cached page       cached_pages        cached_size        cached_perc
> --------                                                                                       ----        -----------    ---------------       ------------        -----------        -----------
> ../../../images/ubuntu-11.04-desktop-i386.iso                                             718583808             175436                  0             175436          718585856             100.00
> ---
> total cached size: 718585856
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
