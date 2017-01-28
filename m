Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 29E176B0038
	for <linux-mm@kvack.org>; Fri, 27 Jan 2017 22:48:11 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id y143so374425787pfb.6
        for <linux-mm@kvack.org>; Fri, 27 Jan 2017 19:48:11 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id z62si3394762pgb.391.2017.01.27.19.48.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jan 2017 19:48:10 -0800 (PST)
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 4B684204DE
	for <linux-mm@kvack.org>; Sat, 28 Jan 2017 03:48:09 +0000 (UTC)
Received: from mail-ua0-f175.google.com (mail-ua0-f175.google.com [209.85.217.175])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id B0696204AD
	for <linux-mm@kvack.org>; Sat, 28 Jan 2017 03:48:06 +0000 (UTC)
Received: by mail-ua0-f175.google.com with SMTP id i68so218213725uad.0
        for <linux-mm@kvack.org>; Fri, 27 Jan 2017 19:48:06 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160525214935.GI14480@ZenIV.linux.org.uk>
References: <20160114212201.GA28910@www.outflux.net> <CALYGNiNN+QYpd-FhM+4WXd=-1UYrhR7kpefbN8mpjh4gSbDO4A@mail.gmail.com>
 <CAGXu5j+cwZQfnSPQNjb=VVzZfJH8n=iZUCM+vz_a6nPku5tQ2g@mail.gmail.com> <20160525214935.GI14480@ZenIV.linux.org.uk>
From: Andy Lutomirski <luto@kernel.org>
Date: Fri, 27 Jan 2017 19:47:45 -0800
Message-ID: <CALCETrUVyF7KwLk29pXDPKVehAxKfKNf_1z7fHjKLg4Y0dzKrQ@mail.gmail.com>
Subject: Re: [PATCH v9] fs: clear file privilege bits when mmap writing
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Jan Kara <jack@suse.cz>, yalin wang <yalin.wang2010@gmail.com>, Willy Tarreau <w@1wt.eu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, May 25, 2016 at 2:49 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> On Wed, May 25, 2016 at 02:36:57PM -0700, Kees Cook wrote:
>
>> Hm, this didn't end up getting picked up. (This jumped out at me again
>> because i_mutex just vanished...)
>>
>> Al, what's the right way to update the locking in this patch?
>
> ->i_mutex is dealt with just by using lock_inode(inode)/unlock_inode(inode);
> I hadn't looked at the rest of the locking in there.

Ping?

If this is too messy, I'm wondering if we could get away with a much
simpler approach: clear the suid and sgid bits when the file is opened
for write.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
