Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D696F6B0003
	for <linux-mm@kvack.org>; Fri,  6 Jul 2018 18:55:19 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id t10-v6so7891865pfh.0
        for <linux-mm@kvack.org>; Fri, 06 Jul 2018 15:55:19 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id r12-v6si8169467pgv.285.2018.07.06.15.55.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jul 2018 15:55:17 -0700 (PDT)
Date: Fri, 6 Jul 2018 15:55:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] fs, elf: Make sure to page align bss in
 load_elf_library
Message-Id: <20180706155515.f86d8394f8aae8bb841e2572@linux-foundation.org>
In-Reply-To: <CAGXu5jL4O_qwwAHmW1C8q77Jv1fe_1JCq6iFxC73VySBkvHSQw@mail.gmail.com>
References: <20180705145539.9627-1-osalvador@techadventures.net>
	<CAGXu5jL4O_qwwAHmW1C8q77Jv1fe_1JCq6iFxC73VySBkvHSQw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: osalvador@techadventures.net, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Nicolas Pitre <nicolas.pitre@linaro.org>, Oscar Salvador <osalvador@suse.de>

On Thu, 5 Jul 2018 08:44:18 -0700 Kees Cook <keescook@chromium.org> wrote:

> On Thu, Jul 5, 2018 at 7:55 AM,  <osalvador@techadventures.net> wrote:
> > From: Oscar Salvador <osalvador@suse.de>
> >
> > The current code does not make sure to page align bss before calling
> > vm_brk(), and this can lead to a VM_BUG_ON() in __mm_populate()
> > due to the requested lenght not being correctly aligned.
> >
> > Let us make sure to align it properly.
> >
> > Signed-off-by: Oscar Salvador <osalvador@suse.de>
> > Tested-by: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
> > Reported-by: syzbot+5dcb560fe12aa5091c06@syzkaller.appspotmail.com
> 
> Wow. CONFIG_USELIB? I'm surprised distros are still using this. 32-bit
> only, and libc5 and earlier only.

Presumably doesn't happen much, but people who *are* enabling this will
want the fix, so I added the cc:stable.
