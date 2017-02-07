Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0F4126B0033
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 15:18:52 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id y196so123600830ity.1
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 12:18:52 -0800 (PST)
Received: from mail-io0-x22e.google.com (mail-io0-x22e.google.com. [2607:f8b0:4001:c06::22e])
        by mx.google.com with ESMTPS id i21si222083itb.101.2017.02.07.12.18.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Feb 2017 12:18:51 -0800 (PST)
Received: by mail-io0-x22e.google.com with SMTP id j13so99391449iod.3
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 12:18:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALCETrUVyF7KwLk29pXDPKVehAxKfKNf_1z7fHjKLg4Y0dzKrQ@mail.gmail.com>
References: <20160114212201.GA28910@www.outflux.net> <CALYGNiNN+QYpd-FhM+4WXd=-1UYrhR7kpefbN8mpjh4gSbDO4A@mail.gmail.com>
 <CAGXu5j+cwZQfnSPQNjb=VVzZfJH8n=iZUCM+vz_a6nPku5tQ2g@mail.gmail.com>
 <20160525214935.GI14480@ZenIV.linux.org.uk> <CALCETrUVyF7KwLk29pXDPKVehAxKfKNf_1z7fHjKLg4Y0dzKrQ@mail.gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 7 Feb 2017 12:18:50 -0800
Message-ID: <CAGXu5jLfsACfz7HqZH3p5_CanbrUQWBU8HtfgsruycmEKsO38A@mail.gmail.com>
Subject: Re: [PATCH v9] fs: clear file privilege bits when mmap writing
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Jan Kara <jack@suse.cz>, yalin wang <yalin.wang2010@gmail.com>, Willy Tarreau <w@1wt.eu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Fri, Jan 27, 2017 at 7:47 PM, Andy Lutomirski <luto@kernel.org> wrote:
> On Wed, May 25, 2016 at 2:49 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
>> On Wed, May 25, 2016 at 02:36:57PM -0700, Kees Cook wrote:
>>
>>> Hm, this didn't end up getting picked up. (This jumped out at me again
>>> because i_mutex just vanished...)
>>>
>>> Al, what's the right way to update the locking in this patch?
>>
>> ->i_mutex is dealt with just by using lock_inode(inode)/unlock_inode(inode);
>> I hadn't looked at the rest of the locking in there.
>
> Ping?
>
> If this is too messy, I'm wondering if we could get away with a much
> simpler approach: clear the suid and sgid bits when the file is opened
> for write.

I think that'll break something, but I don't have any actual examples.
Regardless, I'd still like to see this hole fixed...

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
