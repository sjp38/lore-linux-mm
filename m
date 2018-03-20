Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6C70C6B0007
	for <linux-mm@kvack.org>; Mon, 19 Mar 2018 21:10:23 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id 140-v6so258571itg.4
        for <linux-mm@kvack.org>; Mon, 19 Mar 2018 18:10:23 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id q184si334238iod.108.2018.03.19.18.10.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 19 Mar 2018 18:10:22 -0700 (PDT)
From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: [linux-next:master] BUILD REGRESSION
 a5444cde9dc2120612e50fc5a56c975e67a041fb
References: <5ab048c0.wmRYTJi5ip8zBzJ4%fengguang.wu@intel.com>
Message-ID: <d22bd482-2f5b-8c02-4821-9f1b02122b51@infradead.org>
Date: Mon, 19 Mar 2018 18:10:13 -0700
MIME-Version: 1.0
In-Reply-To: <5ab048c0.wmRYTJi5ip8zBzJ4%fengguang.wu@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Tony Luck <tony.luck@intel.com>

On 03/19/2018 04:33 PM, kbuild test robot wrote:
> tree/branch: https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git  master
> branch HEAD: a5444cde9dc2120612e50fc5a56c975e67a041fb  Add linux-next specific files for 20180319
> 
> Regressions in current branch:
> 
> ERROR: "__sw_hweight8" [drivers/net/wireless/mediatek/mt76/mt76.ko] undefined!

Well, the driver could do:

drivers/net/wireless/mediatek/mt76/Kconfig:

+	select GENERIC_HWEIGHT

but maybe arch/ix64/Kconfig (where the build error is) could be asked to do:

config GENERIC_HWEIGHT
	def_bool y

like 23 other $arch-es do.  Aha, ia64 provides inline functions via some
a twisty maze of header files.

Tony, Fengguang, what header(s) should be used to reach __arch_hweight8()?

thanks,
-- 
~Randy
