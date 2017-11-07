Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id A64326B0292
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 03:31:52 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id g128so1387347itb.5
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 00:31:52 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id g30sor360184iod.117.2017.11.07.00.31.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 Nov 2017 00:31:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <8352ad42-8437-4e25-29f4-c3b93c6eed18@lge.com>
References: <94eb2c05f6a018dc21055d39c05b@google.com> <20171106032941.GR21978@ZenIV.linux.org.uk>
 <CACT4Y+abiKapoG9ms6RMqNkGBJtjX_Nf5WEQiYJcJ7=XCsyD2w@mail.gmail.com>
 <20171106131544.GB4359@quack2.suse.cz> <20171106133304.GS21978@ZenIV.linux.org.uk>
 <CACT4Y+YHPOaCVO81VPuC9hDLCSx=KJmwRf7pa3b96UAowLmA2A@mail.gmail.com>
 <20171106160107.GA20227@worktop.programming.kicks-ass.net>
 <20171107005442.GA1405@X58A-UD3R> <20171107081143.GD3326@worktop> <8352ad42-8437-4e25-29f4-c3b93c6eed18@lge.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 7 Nov 2017 09:31:30 +0100
Message-ID: <CACT4Y+aTQ1j-oPG2_2gAOLCasMqT95qWOYTR1Yx4nr05M-ZnMA@mail.gmail.com>
Subject: Re: possible deadlock in generic_file_write_iter
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Al Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>, syzbot <bot+f99f3a0db9007f4f4e32db54229a240c4fe57c15@syzkaller.appspotmail.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, jlayton@redhat.com, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, npiggin@gmail.com, rgoldwyn@suse.com, ross.zwisler@linux.intel.com, syzkaller-bugs@googlegroups.com, Ingo Molnar <mingo@redhat.com>, kernel-team@lge.com

On Tue, Nov 7, 2017 at 9:30 AM, Byungchul Park <byungchul.park@lge.com> wro=
te:
> 11/7/2017 5:11 PM=EC=97=90 Peter Zijlstra =EC=9D=B4(=EA=B0=80) =EC=93=B4 =
=EA=B8=80:
>
>> On Tue, Nov 07, 2017 at 09:54:42AM +0900, Byungchul Park wrote:
>>>>
>>>> The best I could come up with is something like the below; its not
>>>> at all pretty and I could see people objecting; least of all myself fo=
r
>>>> the __complete() thing, but I ran out of creative naming juice.
>>>
>>>
>>> Patches assigning a lock_class per gendisk were already applied in tip.
>>> I believe that solves this.
>>>
>>>     e319e1fbd9d42420ab6eec0bfd75eb9ad7ca63b1
>>>     block, locking/lockdep: Assign a lock_class per gendisk used for
>>>     wait_for_completion()
>>>
>>> I think the following proposal makes kernel too hacky.
>>
>>
>> Ah, I tough this was with those included...
>
>
> Please CC me for issues wrt. crossrelease.

Hi Byungchul,

Whom are you asking? And what is crossrelease?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
