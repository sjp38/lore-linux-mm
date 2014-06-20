Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f182.google.com (mail-ie0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id 163566B0031
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 17:19:05 -0400 (EDT)
Received: by mail-ie0-f182.google.com with SMTP id rp18so3756985iec.27
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 14:19:04 -0700 (PDT)
Received: from mail-ig0-x22f.google.com (mail-ig0-x22f.google.com [2607:f8b0:4001:c05::22f])
        by mx.google.com with ESMTPS id o10si5270446igh.51.2014.06.20.14.19.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 20 Jun 2014 14:19:04 -0700 (PDT)
Received: by mail-ig0-f175.google.com with SMTP id h3so972159igd.14
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 14:19:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140620132904.ec7eced87ff449625ad10d78@linux-foundation.org>
References: <53a3e4f6.LlTrbyV58fY2TrZa%fengguang.wu@intel.com>
	<20140620132904.ec7eced87ff449625ad10d78@linux-foundation.org>
Date: Fri, 20 Jun 2014 14:19:04 -0700
Message-ID: <CAE9FiQVrOgEcP7wQhLtZZQ3yJ+gbYSE23_UYxJ2GKEWHU=GmWg@mail.gmail.com>
Subject: Re: [mmotm:master 188/230] fs/jffs2/debug.h:69:3: note: in expansion
 of macro 'pr_debug'
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, Linux Memory Management List <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, kbuild-all@01.org

On Fri, Jun 20, 2014 at 1:29 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Fri, 20 Jun 2014 15:38:30 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:
>
>> tree:   git://git.cmpxchg.org/linux-mmotm.git master
>> head:   df25ba7db0775d87018e2cd92f26b9b087093840
>> commit: 0b3f61ac78013e35939696ddd63b9b871d11bf72 [188/230] initramfs: support initramfs that is more than 2G
>> config: make ARCH=x86_64 allmodconfig
>>
>> All warnings:
>
> Too many :(  I dropped the patch.

Will put my git tree in kernel.org, let's check if test robot can find
more warning.

Hi Fenguang,

Is rest robot going to sweep all new added branches in kernel.org git?

Thanks

Yinghai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
