Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 51F2B6B4D2D
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 08:29:55 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id e17so20885094wrw.13
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 05:29:55 -0800 (PST)
Received: from eu-smtp-delivery-151.mimecast.com (eu-smtp-delivery-151.mimecast.com. [146.101.78.151])
        by mx.google.com with ESMTPS id b127si2357894wmg.4.2018.11.28.05.29.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Nov 2018 05:29:53 -0800 (PST)
From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 3/3] lockdep: Use line-buffered printk() for lockdep
 messages.
Date: Wed, 28 Nov 2018 13:29:52 +0000
Message-ID: <d630011ed50140b082e15ddc05d0c640@AcuMS.aculab.com>
References: <1541165517-3557-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
        <1541165517-3557-3-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
        <20181107151900.gxmdvx42qeanpoah@pathway.suse.cz>
        <20181108044510.GC2343@jagdpanzerIV>
        <9648a384-853c-942e-6a8d-80432d943aae@i-love.sakura.ne.jp>
        <20181109061204.GC599@jagdpanzerIV>
        <07dcbcb8-c5a7-8188-b641-c110ade1c5da@i-love.sakura.ne.jp>
        <20181109154326.apqkbsojmbg26o3b@pathway.suse.cz>
        <deb8d78b-0593-2b8e-1c7a-9203aa77005f@i-love.sakura.ne.jp>
        <20181123124647.jmewvgrqdpra7wbm@pathway.suse.cz>
 <20181123105634.4956c255@vmware.local.home>
In-Reply-To: <20181123105634.4956c255@vmware.local.home>
Content-Language: en-US
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Steven Rostedt' <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dmitriy Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>

From: Steven Rostedt
> > Steven told me on Plumbers conference that even few initial
> > characters saved him a day few times.
>=20
> Yes, and that has happened more than once. I would reboot and retest
> code that is crashing, and due to a triple fault, the machine would
> reboot because of some race, and the little output I get from the
> console would help tremendously.
>=20
> Remember, debugging the kernel is a lot like forensics, especially when
> it's from a customer's site. You look at all the evidence that you can
> get, and sometimes it's just 10 characters in the output that gives you
> an idea of where things went wrong. I'm really not liking the buffering
> idea because of this.

Yep, it is a real PITA that syslogd (or linux equiv) stops messages being
written to the console by the kernel (which used to be synchronous) and
instead writes them out from userspace.
By that time it has all died.

Sometimes you want a printk() that writes the data to the serial port
before returning.

I also spent a week trying to work out why a customer kernel was
locking up - only to finally find out that the distro they were
using set 'panic on opps' - making it almost impossible to find
out what was happening.

=09David

-
Registered Address Lakeside, Bramley Road, Mount Farm, Milton Keynes, MK1 1=
PT, UK
Registration No: 1397386 (Wales)
