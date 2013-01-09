Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id BACF06B0070
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 03:18:29 -0500 (EST)
Received: by mail-ia0-f169.google.com with SMTP id u20so1229412iag.14
        for <linux-mm@kvack.org>; Wed, 09 Jan 2013 00:18:29 -0800 (PST)
Message-ID: <1357719508.6568.5.camel@kernel.cn.ibm.com>
Subject: Re: fadvise doesn't work well.
From: Simon Jeons <simon.jeons@gmail.com>
Date: Wed, 09 Jan 2013 02:18:28 -0600
In-Reply-To: <20130109080917.GA21056@localhost>
References: <1357718721.6568.3.camel@kernel.cn.ibm.com>
	 <20130109080917.GA21056@localhost>
Content-Type: multipart/mixed; boundary="=-iilhlb0ZRWDKAoQjnskV"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, hughd@google.com, riel@redhat.com, Johannes Weiner <hannes@cmpxchg.org>, mtk.manpages@gmail.com


--=-iilhlb0ZRWDKAoQjnskV
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

On Wed, 2013-01-09 at 16:09 +0800, Fengguang Wu wrote:
> Hi Simon,
> 
> Try run "sync" before doing fadvise, because fadvise won't drop
> dirty/writeback/mapped pages.
> 

Hi Fengguang,

Thanks for your quick response. But the result is the same in
attachment. 

> Thanks,
> Fengguang
> 
> On Wed, Jan 09, 2013 at 02:05:21AM -0600, Simon Jeons wrote:
> > In attanchment.
> 
> > root@kernel:~/Documents/mm/tools/linux-ftools# dd if=../../../images/ubuntu-11.04-desktop-i386.iso of=/tmpfs

The pages of ../../../images/ubuntu-11.04-desktop-i386.iso is mapped or
unmapped?

> > 1403484+0 records in
> > 1403484+0 records out
> > 718583808 bytes (719 MB) copied, 19.5054 s, 36.8 MB/s
> > root@kernel:~/Documents/mm/tools/linux-ftools# ./linux-fincore -s ../../../images/ubuntu-11.04-desktop-i386.iso 
> > filename                                                                                       size        total_pages    min_cached page       cached_pages        cached_size        cached_perc
> > --------                                                                                       ----        -----------    ---------------       ------------        -----------        -----------
> > ../../../images/ubuntu-11.04-desktop-i386.iso                                             718583808             175436                  0             175436          718585856             100.00
> > ---
> > total cached size: 718585856
> > root@kernel:~/Documents/mm/tools/linux-ftools# ./linux-fadvise ../../../images/ubuntu-11.04-desktop-i386.iso DONTNEED 0,718585856
> > Going to fadvise ../../../images/ubuntu-11.04-desktop-i386.iso as mode DONTNEED
> > offset: 0
> > length: 718583808
> > Invalid mode DONTNEED
> > root@kernel:~/Documents/mm/tools/linux-ftools# ./linux-fincore -s ../../../images/ubuntu-11.04-desktop-i386.iso 
> > filename                                                                                       size        total_pages    min_cached page       cached_pages        cached_size        cached_perc
> > --------                                                                                       ----        -----------    ---------------       ------------        -----------        -----------
> > ../../../images/ubuntu-11.04-desktop-i386.iso                                             718583808             175436                  0             175436          718585856             100.00
> > ---
> > total cached size: 718585856
> > 
> 


--=-iilhlb0ZRWDKAoQjnskV
Content-Disposition: attachment; filename="11"
Content-Type: text/plain; name="11"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

root@kernel:~/Documents/mm/tools/linux-ftools# dd if=../../../images/ubuntu-11.04-desktop-i386.iso of=/tmpfs
1403484+0 records in
1403484+0 records out
718583808 bytes (719 MB) copied, 35.5144 s, 20.2 MB/s
root@hacker:~/Documents/mm/tools/linux-ftools# ./linux-fincore -s ../../../images/ubuntu-11.04-desktop-i386.iso
filename                                                                                       size        total_pages    min_cached page       cached_pages        cached_size        cached_perc
--------                                                                                       ----        -----------    ---------------       ------------        -----------        -----------
../../../images/ubuntu-11.04-desktop-i386.iso                                             718583808             175436                  0             175436          718585856             100.00
---
total cached size: 718585856
root@kernel:~/Documents/mm/tools/linux-ftools# sync
root@kernel:~/Documents/mm/tools/linux-ftools# ./linux-fincore -s ../../../images/ubuntu-11.04-desktop-i386.iso
filename                                                                                       size        total_pages    min_cached page       cached_pages        cached_size        cached_perc
--------                                                                                       ----        -----------    ---------------       ------------        -----------        -----------
../../../images/ubuntu-11.04-desktop-i386.iso                                             718583808             175436                  0             175436          718585856             100.00
---
total cached size: 718585856
root@kernel:~/Documents/mm/tools/linux-ftools# ./linux-fadvise ../../../images/ubuntu-11.04-desktop-i386.iso DONTNEED 0,718585856
Going to fadvise ../../../images/ubuntu-11.04-desktop-i386.iso as mode DONTNEED
offset: 0
length: 718583808
Invalid mode DONTNEED
root@kernel:~/Documents/mm/tools/linux-ftools# ./linux-fincore -s ../../../images/ubuntu-11.04-desktop-i386.iso
filename                                                                                       size        total_pages    min_cached page       cached_pages        cached_size        cached_perc
--------                                                                                       ----        -----------    ---------------       ------------        -----------        -----------
../../../images/ubuntu-11.04-desktop-i386.iso                                             718583808             175436                  0             175436          718585856             100.00
---
total cached size: 718585856


--=-iilhlb0ZRWDKAoQjnskV--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
