Received: from shark.he.net ([66.160.160.2]) by xenotime.net for <linux-mm@kvack.org>; Thu, 16 Oct 2008 14:01:48 -0700
Date: Thu, 16 Oct 2008 14:01:48 -0700 (PDT)
From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: Re: mmotm 2008-10-16-00-52 uploaded (cgroup + mm)
In-Reply-To: <200810160758.m9G7wZmt018529@imap1.linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0810161400230.14604@shark.he.net>
References: <200810160758.m9G7wZmt018529@imap1.linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 16 Oct 2008, akpm@linux-foundation.org wrote:

> The mm-of-the-moment snapshot 2008-10-16-00-52 has been uploaded to
> 
>    http://userweb.kernel.org/~akpm/mmotm/
> 
> It contains the following patches against 2.6.27:


build-r9168.out:(.text+0x261e6): undefined reference to `lookup_page_cgroup'
build-r9168.out:memcontrol.c:(.text+0x2629f): undefined reference to `lookup_page_cgroup'
build-r9168.out:memcontrol.c:(.text+0x2671a): undefined reference to `lookup_page_cgroup'
build-r9168.out:(.text+0x268f9): undefined reference to `lookup_page_cgroup'
build-r9168.out:memcontrol.c:(.text+0x26e52): undefined reference to `page_cgroup_init'
build-r9168.out:(.text+0x26f44): undefined reference to `lookup_page_cgroup'
build-r9168.out:(.init.text+0xe42): undefined reference to `pgdat_page_cgroup_init'


.config is at http://oss.oracle.com/~rdunlap/kerneltest/configs/config-r9168

-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
