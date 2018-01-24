Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id EB401800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 16:11:40 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id r196so5358441itc.4
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 13:11:40 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s68sor610793ioi.98.2018.01.24.13.11.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jan 2018 13:11:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CACT4Y+apdswWOB1XW6HsG+AUowVhozhO1ZeHDeCRBCkY8gkYfg@mail.gmail.com>
References: <001a1144d6e854b3c90562668d74@google.com> <20180124174723.25289-1-joelaf@google.com>
 <CACT4Y+apdswWOB1XW6HsG+AUowVhozhO1ZeHDeCRBCkY8gkYfg@mail.gmail.com>
From: Joel Fernandes <joelaf@google.com>
Date: Wed, 24 Jan 2018 13:11:38 -0800
Message-ID: <CAJWu+oo1g3oAuDQAbmB+vyX4tX+7y24Wj5LqXGnt9eFFRsFdUw@mail.gmail.com>
Subject: Re: possible deadlock in shmem_file_llseek
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: LKML <linux-kernel@vger.kernel.org>, syzbot <syzbot+8ec30bb7bf1a981a2012@syzkaller.appspotmail.com>, Hugh Dickins <hughd@google.com>, Linux-MM <linux-mm@kvack.org>, syzkaller-bugs@googlegroups.com

On Wed, Jan 24, 2018 at 10:40 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Wed, Jan 24, 2018 at 6:47 PM, Joel Fernandes <joelaf@google.com> wrote:
>>
>> #syz test: https://github.com/joelagnel/linux.git test-ashmem
>
>
> Oops, this email somehow ended up without Content-Type header, which
> was unexpected on syzbot side. Now should be fixed with:
> https://github.com/google/syzkaller/commit/866f1102f786c19a67e3857f891eaf5107550663
>
> Let's try again:
>
> #syz test: https://github.com/joelagnel/linux.git test-ashmem

Hehe glad I could trigger the syzcaller side bug ;D I actually edited
the email in plain text to be more git send-email friendly... sorry
I'm old fashioned but in this case it worked out for the better ;)

- Joel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
