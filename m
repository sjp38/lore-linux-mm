Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 58A306B0062
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 03:26:22 -0500 (EST)
Date: Wed, 9 Jan 2013 16:26:20 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: fadvise doesn't work well.
Message-ID: <20130109082620.GB21379@localhost>
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

> root@kernel:~/Documents/mm/tools/linux-ftools# ./linux-fadvise ../../../images/ubuntu-11.04-desktop-i386.iso DONTNEED 0,718585856
> Going to fadvise ../../../images/ubuntu-11.04-desktop-i386.iso as mode DONTNEED
> offset: 0
> length: 718583808
> Invalid mode DONTNEED
~~~~~~~~~~~~~~~~~~~~~~~

Oops, that's invalid command. Use "dontneed" rather than "DONTNEED".

fadvise is case sensitive..

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
