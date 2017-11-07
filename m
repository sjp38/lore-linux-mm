Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id E1C38680F85
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 15:11:31 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id a192so440547pge.1
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 12:11:31 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u131si1959442pgc.272.2017.11.07.12.11.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Nov 2017 12:11:30 -0800 (PST)
Date: Tue, 7 Nov 2017 12:11:28 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mmotm:master 226/244] ERROR: "__aeabi_uldivmod"
 [drivers/net/ethernet/intel/i40e/i40e.ko] undefined!
Message-Id: <20171107121128.5d92d3b9c3ed5f254ec57f85@linux-foundation.org>
In-Reply-To: <201711072208.DrJFXgC6%fengguang.wu@intel.com>
References: <201711072208.DrJFXgC6%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Amritha Nambiar <amritha.nambiar@intel.com>, Kiran Patil <kiran.patil@intel.com>, Anjali Singhai Jain <anjali.singhai@intel.com>, Jingjing Wu <jingjing.wu@intel.com>, Jeff Kirsher <jeffrey.t.kirsher@intel.com>

On Tue, 7 Nov 2017 22:25:11 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> Hi Andrew,
> 
> First bad commit (maybe != root cause):
> 
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   8c953f23aaffa1931eb463adbe10f0303ef977b1
> commit: 25ac8251382c3b2de9de3a861f8b74bfa565316d [226/244] linux-next-rejects
> config: arm-allmodconfig (attached as .config)
> compiler: arm-linux-gnueabi-gcc (Debian 6.1.1-9) 6.1.1 20160705
> reproduce:
>         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         git checkout 25ac8251382c3b2de9de3a861f8b74bfa565316d
>         # save the attached .config to linux build tree
>         make.cross ARCH=arm 
> 
> All errors (new ones prefixed by >>):
> 
> >> ERROR: "__aeabi_uldivmod" [drivers/net/ethernet/intel/i40e/i40e.ko] undefined!
> 

(cc everyone@intel)

At a guess I'd say that something in drivers/net/ethernet/intel/i40e/
is now trying to do a 64-bit divide or mod operation.  But I don't seem to
be able to reproduce this with arm or i386.  Maybe it was fixed today.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
