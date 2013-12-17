Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id CD6F96B0037
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 04:32:06 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id hz1so4210040pad.12
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 01:32:06 -0800 (PST)
Received: from m59-178.qiye.163.com (m59-178.qiye.163.com. [123.58.178.59])
        by mx.google.com with ESMTP id eq2si11215260pbb.82.2013.12.17.01.32.02
        for <linux-mm@kvack.org>;
        Tue, 17 Dec 2013 01:32:03 -0800 (PST)
Message-ID: <52B019F5.7020505@ubuntukylin.com>
Date: Tue, 17 Dec 2013 17:31:33 +0800
From: Li Wang <liwang@ubuntukylin.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/5] VFS: Directory level cache cleaning
References: <cover.1387205337.git.liwang@ubuntukylin.com> <CAM_iQpUSX1yX9SMvUnbwZ7UkaBMUheOEiZNaSb4m8gWBQzzGDQ@mail.gmail.com> <52AFC020.10403@ubuntukylin.com> <20131217035847.GA10392@parisc-linux.org> <52AFFBE3.8020507@ubuntukylin.com> <52B01594.80001@huawei.com>
In-Reply-To: <52B01594.80001@huawei.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Matthew Wilcox <matthew@wil.cx>, Cong Wang <xiyou.wangcong@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Sage Weil <sage@inktank.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Yunchuan Wen <yunchuanwen@ubuntukylin.com>

This extension is just add-on extension. The original debugging
capability is still there, and more flexible debugging is now allowed.

On 2013/12/17 17:12, Li Zefan wrote:
> On 2013/12/17 15:23, Li Wang wrote:
>> If we do wanna equip fadvise() with directory level page cache cleaning,
>> this could be solved by invoking (inode_permission() || capable(CAP_SYS_ADMIN)) before manipulating the page cache of that inode.
>> We think the current extension to 'drop_caches' has a complete back
>> compatibility, the old semantics keep unchanged, and with add-on
>> features to do finer granularity cache cleaning should be also
>> desirable.
>>
>
> I don't think you can extend the drop_caches interface this way. It should
> be used for debuging only.
>
> commit 9d0243bca345d5ce25d3f4b74b7facb3a6df1232
> Author: Andrew Morton <akpm@osdl.org>
> Date:   Sun Jan 8 01:00:39 2006 -0800
>
>      [PATCH] drop-pagecache
>
>      Add /proc/sys/vm/drop_caches.  When written to, this will cause the kernel to
>      discard as much pagecache and/or reclaimable slab objects as it can.  THis
>      operation requires root permissions.
>
>      ...
>
>      This is a debugging feature: useful for getting consistent results between
>      filesystem benchmarks.  We could possibly put it under a config option, but
>      it's less than 300 bytes.
>
> Also see http://lkml.org/lkml/2013/7/26/230
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
