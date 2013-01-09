Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 79AE56B0062
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 03:23:12 -0500 (EST)
Date: Wed, 9 Jan 2013 16:23:10 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: fadvise doesn't work well.
Message-ID: <20130109082310.GA21379@localhost>
References: <1357718721.6568.3.camel@kernel.cn.ibm.com>
 <20130109080917.GA21056@localhost>
 <1357719508.6568.5.camel@kernel.cn.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1357719508.6568.5.camel@kernel.cn.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, hughd@google.com, riel@redhat.com, Johannes Weiner <hannes@cmpxchg.org>, mtk.manpages@gmail.com

On Wed, Jan 09, 2013 at 02:18:28AM -0600, Simon Jeons wrote:
> On Wed, 2013-01-09 at 16:09 +0800, Fengguang Wu wrote:
> > Hi Simon,
> > 
> > Try run "sync" before doing fadvise, because fadvise won't drop
> > dirty/writeback/mapped pages.
> > 
> 
> Hi Fengguang,
> 
> Thanks for your quick response. But the result is the same in
> attachment. 
> 
> > Thanks,
> > Fengguang
> > 
> > On Wed, Jan 09, 2013 at 02:05:21AM -0600, Simon Jeons wrote:
> > > In attanchment.
> > 
> > > root@kernel:~/Documents/mm/tools/linux-ftools# dd if=../../../images/ubuntu-11.04-desktop-i386.iso of=/tmpfs
> 
> The pages of ../../../images/ubuntu-11.04-desktop-i386.iso is mapped or
> unmapped?

You may check if anyone is using (hence possibly mapping) it with

        lsof | grep ubuntu-11.04-desktop-i386.iso

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
