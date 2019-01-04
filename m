Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C14B18E00AE
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 03:50:34 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id 39so35031852edq.13
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 00:50:34 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id la26-v6si3696809ejb.33.2019.01.04.00.50.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Jan 2019 00:50:33 -0800 (PST)
Subject: Re: KMSAN: uninit-value in mpol_rebind_mm
References: <000000000000c06550057e4cac7c@google.com>
 <a71997c3-e8ae-a787-d5ce-3db05768b27c@suse.cz>
 <CACT4Y+bRvwxkdnyRosOujpf5-hkBwd2g0knyCQHob7p=0hC=Dw@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <52835ef5-6351-3852-d4ba-b6de285f96f5@suse.cz>
Date: Fri, 4 Jan 2019 09:50:31 +0100
MIME-Version: 1.0
In-Reply-To: <CACT4Y+bRvwxkdnyRosOujpf5-hkBwd2g0knyCQHob7p=0hC=Dw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: syzbot <syzbot+b19c2dc2c990ea657a71@syzkaller.appspotmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Potapenko <glider@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, linux@dominikbrodowski.net, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, xieyisheng1@huawei.com, zhong jiang <zhongjiang@huawei.com>

On 1/3/19 9:42 AM, Dmitry Vyukov wrote:
> On Thu, Jan 3, 2019 at 9:36 AM Vlastimil Babka <vbabka@suse.cz> wrote:
>>
>>
>> On 12/31/18 8:51 AM, syzbot wrote:
>>> Hello,
>>>
>>> syzbot found the following crash on:
>>>
>>> HEAD commit:    79fc24ff6184 kmsan: highmem: use kmsan_clear_page() in cop..
>>> git tree:       kmsan
>>> console output: https://syzkaller.appspot.com/x/log.txt?x=13c48b67400000
>>> kernel config:  https://syzkaller.appspot.com/x/.config?x=901dd030b2cc57e7
>>> dashboard link: https://syzkaller.appspot.com/bug?extid=b19c2dc2c990ea657a71
>>> compiler:       clang version 8.0.0 (trunk 349734)
>>>
>>> Unfortunately, I don't have any reproducer for this crash yet.
>>>
>>> IMPORTANT: if you fix the bug, please add the following tag to the commit:
>>> Reported-by: syzbot+b19c2dc2c990ea657a71@syzkaller.appspotmail.com
>>>
>>> ==================================================================
>>> BUG: KMSAN: uninit-value in mpol_rebind_policy mm/mempolicy.c:353 [inline]
>>> BUG: KMSAN: uninit-value in mpol_rebind_mm+0x249/0x370 mm/mempolicy.c:384
>>
>> The report doesn't seem to indicate where the uninit value resides in
>> the mempolicy object.
> 
> Yes, it doesn't and it's not trivial to do. The tool reports uses of
> unint _values_. Values don't necessary reside in memory. It can be a
> register, that come from another register that was calculated as a sum
> of two other values, which may come from a function argument, etc.

I see. BTW, the patch I sent will be picked up for testing, or does it
have to be in mmotm/linux-next first?
