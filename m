Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7D8426B0033
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 09:08:59 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id i17so11014496otb.2
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 06:08:59 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id k195si4583050oib.296.2017.12.19.06.08.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Dec 2017 06:08:58 -0800 (PST)
Subject: Re: BUG: bad usercopy in memdup_user
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <CAGXu5jKLBuQ8Ne6BjjPH+1SVw-Fj4ko5H04GHn-dxXYwoMEZtw@mail.gmail.com>
	<CACT4Y+a3h0hmGpfVaePX53QUQwBhN9BUyERp-5HySn74ee_Vxw@mail.gmail.com>
	<20171219083746.GR19604@eros>
	<20171219132246.GD13680@bombadil.infradead.org>
	<CACT4Y+YMLL=3SBgbMep-E3FDOn7vwYOgQ_fqG+k8NL78+Fhcjw@mail.gmail.com>
In-Reply-To: <CACT4Y+YMLL=3SBgbMep-E3FDOn7vwYOgQ_fqG+k8NL78+Fhcjw@mail.gmail.com>
Message-Id: <201712192308.HJJ05711.SHQFVFLOMFOOJt@I-love.SAKURA.ne.jp>
Date: Tue, 19 Dec 2017 23:08:14 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dvyukov@google.com, willy@infradead.org
Cc: me@tobin.cc, keescook@chromium.org, linux-mm@kvack.org, bot+719398b443fd30155f92f2a888e749026c62b427@syzkaller.appspotmail.com, dave@nullcore.net, keun-o.park@darkmatter.ae, labbott@redhat.com, linux-kernel@vger.kernel.org, mark.rutland@arm.com, mingo@kernel.org, syzkaller-bugs@googlegroups.com, will.deacon@arm.com

Dmitry Vyukov wrote:
> On Tue, Dec 19, 2017 at 2:22 PM, Matthew Wilcox <willy@infradead.org> wrote:
> >> > >> This BUG is reporting
> >> > >>
> >> > >> [   26.089789] usercopy: kernel memory overwrite attempt detected to 0000000022a5b430 (kmalloc-1024) (1024 bytes)
> >> > >>
> >> > >> line. But isn't 0000000022a5b430 strange for kmalloc(1024, GFP_KERNEL)ed kernel address?
> >> > >
> >> > > The address is hashed (see the %p threads for 4.15).
> >> >
> >> >
> >> > +Tobin, is there a way to disable hashing entirely? The only
> >> > designation of syzbot is providing crash reports to kernel developers
> >> > with as much info as possible. It's fine for it to leak whatever.
> >>
> >> We have new specifier %px to print addresses in hex if leaking info is
> >> not a worry.
> >
> > Could we have a way to know that the printed address is hashed and not just
> > a pointer getting completely scrogged?  Perhaps prefix it with ... a hash!
> > So this line would look like:
> >
> > [   26.089789] usercopy: kernel memory overwrite attempt detected to #0000000022a5b430 (kmalloc-1024) (1024 bytes)
> >
> > Or does that miss the point of hashing the address, so the attacker
> > thinks its a real address?
> 
> If we do something with this, I would suggest that we just disable
> hashing. Any of the concerns that lead to hashed pointers are not
> applicable in this context, moreover they are harmful, cause confusion
> and make it harder to debug these bugs. That perfectly can be an
> opt-in CONFIG_DEBUG_INSECURE_BLA_BLA_BLA.
> 
Why not a kernel command line option? Hashing by default.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
