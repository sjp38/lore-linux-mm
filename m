Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 52A3E6B026C
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 05:42:49 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id 143so5508819itf.1
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 02:42:49 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a46sor4706513itj.102.2017.11.06.02.42.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Nov 2017 02:42:47 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <s5hy3njlmhe.wl-tiwai@suse.de>
References: <94eb2c19df188b1926055cf13c21@google.com> <CACT4Y+ZDVP7mJHaOpq9N5oewE0WwCCWgrtWX08DFdBJN4sBRhQ@mail.gmail.com>
 <s5hshdxay1t.wl-tiwai@suse.de> <20171102090951.drjf7wc2urcmtla5@node.shutemov.name>
 <s5hy3njlmhe.wl-tiwai@suse.de>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 6 Nov 2017 11:42:26 +0100
Message-ID: <CACT4Y+bGBRrnu_rb9zZG1jWb8Zz4vx=ObmT-2K6bZGAQryA9Mg@mail.gmail.com>
Subject: Re: [alsa-devel] BUG: soft lockup
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Takashi Iwai <tiwai@suse.de>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, syzbot <bot+63583aefef5457348dcfa06b87d4fd1378b26b09@syzkaller.appspotmail.com>, aaron.lu@intel.com, alsa-devel@alsa-project.org, Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <peterz@infradead.org>, ying.huang@intel.com, syzkaller-bugs@googlegroups.com, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, shli@fb.com, David Rientjes <rientjes@google.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Morton <akpm@linux-foundation.org>, zi.yan@cs.rutgers.edu, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Mon, Nov 6, 2017 at 11:39 AM, Takashi Iwai <tiwai@suse.de> wrote:
> On Thu, 02 Nov 2017 10:09:51 +0100,
> Kirill A. Shutemov wrote:
>>
>> On Thu, Nov 02, 2017 at 09:23:58AM +0100, Takashi Iwai wrote:
>> >
>> > Currently the least ALSA timer interrupt period is limited to 1ms.
>> > Does it still too much?
>> >
>> > Can the reproducer triggers it reliably?  If yes, could you forward
>> > it, too (and config as well), so that I'll try to dig down more exact
>> > code paths?
>>
>> All of that is part of original report:
>>
>> http://lkml.kernel.org/r/94eb2c19df188b1926055cf13c21@google.com
>>
>> marc.info hasn't stored repro.c for some reasone. Attached.
>>
>> I've just check it reproduces reliably for me in KVM.
>>
>> I also checked that it's not specific to THP -- still trigirable with huge
>> pages disabled.
>
> I guess this is the same issue Jerome forwarded recently, and it was
> fixed by limiting the amount of ALSA timer instances.  I queued the
> fix in sound git tree for-linus branch, commit
> 9b7d869ee5a77ed4a462372bb89af622e705bfb8
>     ALSA: timer: Limit max instances per timer
>
> It'll be likely included in 4.14 final.

Thanks

Let's also tell the bot what fixes this:

#syz fix: ALSA: timer: Limit max instances per timer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
