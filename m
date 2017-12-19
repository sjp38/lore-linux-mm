Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 988106B025F
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 17:10:03 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id v21so9961186iob.0
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 14:10:03 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [205.233.59.134])
        by mx.google.com with ESMTPS id i1si1906434ite.159.2017.12.19.14.10.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Dec 2017 14:10:02 -0800 (PST)
Subject: Re: BUG: bad usercopy in memdup_user
References: <001a113e9ca8a3affd05609d7ccf@google.com>
 <6a50d160-56d0-29f9-cfed-6c9202140b43@I-love.SAKURA.ne.jp>
 <CAGXu5jKLBuQ8Ne6BjjPH+1SVw-Fj4ko5H04GHn-dxXYwoMEZtw@mail.gmail.com>
 <CACT4Y+a3h0hmGpfVaePX53QUQwBhN9BUyERp-5HySn74ee_Vxw@mail.gmail.com>
 <20171219083746.GR19604@eros> <20171219132246.GD13680@bombadil.infradead.org>
 <CA+55aFwvMMg0Kt8z+tkgPREbX--Of0R5nr_wS4B64kFxiVVKmw@mail.gmail.com>
 <20171219214849.GU21978@ZenIV.linux.org.uk>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <f03d0baa-6a4a-0b67-056b-f2d0acb7befe@infradead.org>
Date: Tue, 19 Dec 2017 14:09:45 -0800
MIME-Version: 1.0
In-Reply-To: <20171219214849.GU21978@ZenIV.linux.org.uk>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>, "Tobin C. Harding" <me@tobin.cc>, Dmitry Vyukov <dvyukov@google.com>, Kees Cook <keescook@chromium.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Linux-MM <linux-mm@kvack.org>, syzbot <bot+719398b443fd30155f92f2a888e749026c62b427@syzkaller.appspotmail.com>, David Windsor <dave@nullcore.net>, keun-o.park@darkmatter.ae, Laura Abbott <labbott@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Mark Rutland <mark.rutland@arm.com>, Ingo Molnar <mingo@kernel.org>, syzkaller-bugs@googlegroups.com, Will Deacon <will.deacon@arm.com>

On 12/19/2017 01:48 PM, Al Viro wrote:
> On Tue, Dec 19, 2017 at 01:36:46PM -0800, Linus Torvalds wrote:
> 
>> I suspect that an "offset and size within the kernel object" value
>> might make sense.  But what does the _pointer_ tell you?
> 
> Well, for example seeing a 0xfffffffffffffff4 where a pointer to object
> must have been is a pretty strong hint to start looking for a way for
> that ERR_PTR(-ENOMEM) having ended up there...  Something like
> 0x6e69622f7273752f is almost certainly a misplaced "/usr/bin", i.e. a

possibly poison values also?

> pathname overwriting whatever it ends up in, etc.  And yes, I have run
> into both of those in real life.
> 
> Debugging the situation when crap value has ended up in place of a
> pointer is certainly a case where you do want to see what exactly has
> ended up in there...


-- 
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
