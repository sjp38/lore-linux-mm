Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id DAB436B0031
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 12:45:24 -0500 (EST)
Received: by mail-qc0-f180.google.com with SMTP id w7so3988428qcr.11
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 09:45:24 -0800 (PST)
Received: from mail-oa0-x22d.google.com (mail-oa0-x22d.google.com [2607:f8b0:4003:c02::22d])
        by mx.google.com with ESMTPS id t7si12144909qar.43.2013.12.16.09.45.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 16 Dec 2013 09:45:23 -0800 (PST)
Received: by mail-oa0-f45.google.com with SMTP id o6so5352555oag.18
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 09:45:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <cover.1387205337.git.liwang@ubuntukylin.com>
References: <cover.1387205337.git.liwang@ubuntukylin.com>
Date: Mon, 16 Dec 2013 09:45:22 -0800
Message-ID: <CAM_iQpUSX1yX9SMvUnbwZ7UkaBMUheOEiZNaSb4m8gWBQzzGDQ@mail.gmail.com>
Subject: Re: [PATCH 0/5] VFS: Directory level cache cleaning
From: Cong Wang <xiyou.wangcong@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Wang <liwang@ubuntukylin.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Sage Weil <sage@inktank.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Yunchuan Wen <yunchuanwen@ubuntukylin.com>

On Mon, Dec 16, 2013 at 7:00 AM, Li Wang <liwang@ubuntukylin.com> wrote:
> This patch extend the 'drop_caches' interface to
> support directory level cache cleaning and has a complete
> backward compatibility. '{1,2,3}' keeps the same semantics
> as before. Besides, "{1,2,3}:DIRECTORY_PATH_NAME" is allowed
> to recursively clean the caches under DIRECTORY_PATH_NAME.
> For example, 'echo 1:/home/foo/jpg > /proc/sys/vm/drop_caches'
> will clean the page caches of the files inside 'home/foo/jpg'.
>

This interface is ugly...

And we already have a file-level drop cache, that is,
fadvise(DONTNEED). Can you extend it if it can't
handle a directory fd?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
