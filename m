Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id A8D746B026D
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 03:37:53 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id b82so761595wmd.5
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 00:37:53 -0800 (PST)
Received: from out3-smtp.messagingengine.com (out3-smtp.messagingengine.com. [66.111.4.27])
        by mx.google.com with ESMTPS id g32si4744713edb.218.2017.12.19.00.37.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Dec 2017 00:37:52 -0800 (PST)
Date: Tue, 19 Dec 2017 19:37:46 +1100
From: "Tobin C. Harding" <me@tobin.cc>
Subject: Re: BUG: bad usercopy in memdup_user
Message-ID: <20171219083746.GR19604@eros>
References: <001a113e9ca8a3affd05609d7ccf@google.com>
 <6a50d160-56d0-29f9-cfed-6c9202140b43@I-love.SAKURA.ne.jp>
 <CAGXu5jKLBuQ8Ne6BjjPH+1SVw-Fj4ko5H04GHn-dxXYwoMEZtw@mail.gmail.com>
 <CACT4Y+a3h0hmGpfVaePX53QUQwBhN9BUyERp-5HySn74ee_Vxw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+a3h0hmGpfVaePX53QUQwBhN9BUyERp-5HySn74ee_Vxw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Kees Cook <keescook@chromium.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Linux-MM <linux-mm@kvack.org>, syzbot <bot+719398b443fd30155f92f2a888e749026c62b427@syzkaller.appspotmail.com>, David Windsor <dave@nullcore.net>, keun-o.park@darkmatter.ae, Laura Abbott <labbott@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Mark Rutland <mark.rutland@arm.com>, Ingo Molnar <mingo@kernel.org>, syzkaller-bugs@googlegroups.com, Will Deacon <will.deacon@arm.com>

On Tue, Dec 19, 2017 at 09:12:58AM +0100, Dmitry Vyukov wrote:
> On Tue, Dec 19, 2017 at 1:57 AM, Kees Cook <keescook@chromium.org> wrote:
> > On Mon, Dec 18, 2017 at 6:22 AM, Tetsuo Handa
> > <penguin-kernel@i-love.sakura.ne.jp> wrote:
> >> On 2017/12/18 22:40, syzbot wrote:
> >>> Hello,
> >>>
> >>> syzkaller hit the following crash on 6084b576dca2e898f5c101baef151f7bfdbb606d
> >>> git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/master
> >>> compiler: gcc (GCC) 7.1.1 20170620
> >>> .config is attached
> >>> Raw console output is attached.
> >>>
> >>> Unfortunately, I don't have any reproducer for this bug yet.
> >>>
> >>>
> >>
> >> This BUG is reporting
> >>
> >> [   26.089789] usercopy: kernel memory overwrite attempt detected to 0000000022a5b430 (kmalloc-1024) (1024 bytes)
> >>
> >> line. But isn't 0000000022a5b430 strange for kmalloc(1024, GFP_KERNEL)ed kernel address?
> >
> > The address is hashed (see the %p threads for 4.15).
> 
> 
> +Tobin, is there a way to disable hashing entirely? The only
> designation of syzbot is providing crash reports to kernel developers
> with as much info as possible. It's fine for it to leak whatever.

We have new specifier %px to print addresses in hex if leaking info is
not a worry.

Hope this helps,
Tobin.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
