Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 4A5F36B0035
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 22:08:25 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id r10so6177116pdi.24
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 19:08:24 -0800 (PST)
Received: from m59-178.qiye.163.com (m59-178.qiye.163.com. [123.58.178.59])
        by mx.google.com with ESMTP id im7si10510534pbd.221.2013.12.16.19.08.22
        for <linux-mm@kvack.org>;
        Mon, 16 Dec 2013 19:08:23 -0800 (PST)
Message-ID: <52AFC020.10403@ubuntukylin.com>
Date: Tue, 17 Dec 2013 11:08:16 +0800
From: Li Wang <liwang@ubuntukylin.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/5] VFS: Directory level cache cleaning
References: <cover.1387205337.git.liwang@ubuntukylin.com> <CAM_iQpUSX1yX9SMvUnbwZ7UkaBMUheOEiZNaSb4m8gWBQzzGDQ@mail.gmail.com>
In-Reply-To: <CAM_iQpUSX1yX9SMvUnbwZ7UkaBMUheOEiZNaSb4m8gWBQzzGDQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Sage Weil <sage@inktank.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Yunchuan Wen <yunchuanwen@ubuntukylin.com>

As far as we know, fadvise(DONTNEED) does not support metadata
cache cleaning. We think that is desirable under massive small files
situations. Another thing is that do people accept the behavior
of feeding a directory fd to fadvise will recusively clean all
page caches of files inside that directory?

On 2013/12/17 1:45, Cong Wang wrote:
> On Mon, Dec 16, 2013 at 7:00 AM, Li Wang <liwang@ubuntukylin.com> wrote:
>> This patch extend the 'drop_caches' interface to
>> support directory level cache cleaning and has a complete
>> backward compatibility. '{1,2,3}' keeps the same semantics
>> as before. Besides, "{1,2,3}:DIRECTORY_PATH_NAME" is allowed
>> to recursively clean the caches under DIRECTORY_PATH_NAME.
>> For example, 'echo 1:/home/foo/jpg > /proc/sys/vm/drop_caches'
>> will clean the page caches of the files inside 'home/foo/jpg'.
>>
>
> This interface is ugly...
>
> And we already have a file-level drop cache, that is,
> fadvise(DONTNEED). Can you extend it if it can't
> handle a directory fd?
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
