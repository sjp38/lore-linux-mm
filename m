Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id CB6E16B026D
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 04:08:20 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id z25so12267772pgu.18
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 01:08:20 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h188sor3811041pgc.376.2017.12.19.01.08.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Dec 2017 01:08:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171219090418.GS19604@eros>
References: <001a113e9ca8a3affd05609d7ccf@google.com> <6a50d160-56d0-29f9-cfed-6c9202140b43@I-love.SAKURA.ne.jp>
 <CAGXu5jKLBuQ8Ne6BjjPH+1SVw-Fj4ko5H04GHn-dxXYwoMEZtw@mail.gmail.com>
 <CACT4Y+a3h0hmGpfVaePX53QUQwBhN9BUyERp-5HySn74ee_Vxw@mail.gmail.com>
 <20171219083746.GR19604@eros> <CACT4Y+b0+RtVFzrJO=qnqwHoXi6WHXxXOUtHQCdWp7MFR1o90w@mail.gmail.com>
 <20171219090418.GS19604@eros>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 19 Dec 2017 10:07:58 +0100
Message-ID: <CACT4Y+aDiYaFT4MOE8q2unUi0Scp7Gfvo+DFMNNUpmYhoG_+uQ@mail.gmail.com>
Subject: Re: BUG: bad usercopy in memdup_user
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Tobin C. Harding" <me@tobin.cc>
Cc: Kees Cook <keescook@chromium.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Linux-MM <linux-mm@kvack.org>, syzbot <bot+719398b443fd30155f92f2a888e749026c62b427@syzkaller.appspotmail.com>, David Windsor <dave@nullcore.net>, keun-o.park@darkmatter.ae, Laura Abbott <labbott@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Mark Rutland <mark.rutland@arm.com>, Ingo Molnar <mingo@kernel.org>, syzkaller-bugs@googlegroups.com, Will Deacon <will.deacon@arm.com>

On Tue, Dec 19, 2017 at 10:04 AM, Tobin C. Harding <me@tobin.cc> wrote:
>> >> > <penguin-kernel@i-love.sakura.ne.jp> wrote:
>> >> >> On 2017/12/18 22:40, syzbot wrote:
>> >> >>> Hello,
>> >> >>>
>> >> >>> syzkaller hit the following crash on 6084b576dca2e898f5c101baef151f7bfdbb606d
>> >> >>> git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/master
>> >> >>> compiler: gcc (GCC) 7.1.1 20170620
>> >> >>> .config is attached
>> >> >>> Raw console output is attached.
>> >> >>>
>> >> >>> Unfortunately, I don't have any reproducer for this bug yet.
>> >> >>>
>> >> >>>
>> >> >>
>> >> >> This BUG is reporting
>> >> >>
>> >> >> [   26.089789] usercopy: kernel memory overwrite attempt detected to 0000000022a5b430 (kmalloc-1024) (1024 bytes)
>> >> >>
>> >> >> line. But isn't 0000000022a5b430 strange for kmalloc(1024, GFP_KERNEL)ed kernel address?
>> >> >
>> >> > The address is hashed (see the %p threads for 4.15).
>> >>
>> >>
>> >> +Tobin, is there a way to disable hashing entirely? The only
>> >> designation of syzbot is providing crash reports to kernel developers
>> >> with as much info as possible. It's fine for it to leak whatever.
>> >
>> > We have new specifier %px to print addresses in hex if leaking info is
>> > not a worry.
>>
>> This is not a per-printf-site thing. It's per-machine thing.
>
> There is no way to disable the hashing currently built into the system.

Ack.
Any kind of continuous testing systems would be a use case for this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
