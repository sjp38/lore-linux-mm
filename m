Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id E19B36B0036
	for <linux-mm@kvack.org>; Tue, 16 Apr 2013 03:57:08 -0400 (EDT)
Received: by mail-da0-f53.google.com with SMTP id n34so130281dal.40
        for <linux-mm@kvack.org>; Tue, 16 Apr 2013 00:57:08 -0700 (PDT)
Message-ID: <516D044B.3040300@gmail.com>
Date: Tue, 16 Apr 2013 15:56:59 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [BUG][s390x] mm: system crashed
References: <156480624.266924.1365995933797.JavaMail.root@redhat.com> <2068164110.268217.1365996520440.JavaMail.root@redhat.com> <20130415055627.GB4207@osiris> <516B9B57.6050308@redhat.com> <20130416075047.GA4184@osiris>
In-Reply-To: <20130416075047.GA4184@osiris>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Zhouping Liu <zliu@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, caiqian <caiqian@redhat.com>, Caspar Zhang <czhang@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

Hi Heiko,
On 04/16/2013 03:50 PM, Heiko Carstens wrote:
> On Mon, Apr 15, 2013 at 02:16:55PM +0800, Zhouping Liu wrote:
>> On 04/15/2013 01:56 PM, Heiko Carstens wrote:
>>> On Sun, Apr 14, 2013 at 11:28:40PM -0400, Zhouping Liu wrote:
>>>> i? 1/2  16109.346170A? Call Trace:
>>>> i? 1/2  16109.346179A? (i? 1/2  <0000000000100920>A? show_trace+0x128/0x12c)
>>>> i? 1/2  16109.346195A?  i? 1/2  <00000000001cd320>A? rcu_check_callbacks+0x458/0xccc
>>>> i? 1/2  16109.346209A?  i? 1/2  <0000000000140f2e>A? update_process_times+0x4a/0x74
>>>> i? 1/2  16109.346222A?  i? 1/2  <0000000000199452>A? tick_sched_handle.isra.12+0x5e/0x70
>>>> i? 1/2  16109.346235A?  i? 1/2  <00000000001995aa>A? tick_sched_timer+0x6a/0x98
>>>> i? 1/2  16109.346247A?  i? 1/2  <000000000015c1ea>A? __run_hrtimer+0x8e/0x200
>>>> i? 1/2  16109.346381A?  i? 1/2  <000000000015d1b2>A? hrtimer_interrupt+0x212/0x2b0
>>>> i? 1/2  16109.346385A?  i? 1/2  <00000000001040f6>A? clock_comparator_work+0x4a/0x54
>>>> i? 1/2  16109.346390A?  i? 1/2  <000000000010d658>A? do_extint+0x158/0x15c
>>>> i? 1/2  16109.346396A?  i? 1/2  <000000000062aa24>A? ext_skip+0x38/0x3c
>>>> i? 1/2  16109.346404A?  i? 1/2  <00000000001153c8>A? smp_yield_cpu+0x44/0x48
>>>> i? 1/2  16109.346412A? (i? 1/2  <000003d10051aec0>A? 0x3d10051aec0)
>>>> i? 1/2  16109.346457A?  i? 1/2  <000000000024206a>A? __page_check_address+0x16a/0x170
>>>> i? 1/2  16109.346466A?  i? 1/2  <00000000002423a2>A? page_referenced_one+0x3e/0xa0
>>>> i? 1/2  16109.346501A?  i? 1/2  <000000000024427c>A? page_referenced+0x32c/0x41c
>>>> i? 1/2  16109.346510A?  i? 1/2  <000000000021b1dc>A? shrink_page_list+0x380/0xb9c
>>>> i? 1/2  16109.346521A?  i? 1/2  <000000000021c0a6>A? shrink_inactive_list+0x1c6/0x56c
>>>> i? 1/2  16109.346532A?  i? 1/2  <000000000021c69e>A? shrink_lruvec+0x252/0x56c
>>>> i? 1/2  16109.346542A?  i? 1/2  <000000000021ca44>A? shrink_zone+0x8c/0x1bc
>>>> i? 1/2  16109.346553A?  i? 1/2  <000000000021d080>A? balance_pgdat+0x50c/0x658
>>>> i? 1/2  16109.346564A?  i? 1/2  <000000000021d318>A? kswapd+0x14c/0x470
>>>> i? 1/2  16109.346576A?  i? 1/2  <0000000000158292>A? kthread+0xda/0xe4
>>>> i? 1/2  16109.346656A?  i? 1/2  <000000000062a5de>A? kernel_thread_starter+0x6/0xc
>>>> i? 1/2  16109.346682A?  i? 1/2  <000000000062a5d8>A? kernel_thread_starter+0x0/0xc
>>>> [-- MARK -- Fri Apr 12 06:15:00 2013]
>>>> i? 1/2  16289.386061A? INFO: rcu_sched self-detected stall on CPU { 0}  (t=42010 jiffies
>>>>   g=89766 c=89765 q=10627)
>>> Did the system really crash or did you just see the rcu related warning(s)?
>> I just check it again, actually at first the system didn't really
>> crash, but the system is very slow in response.
>> and the reproducer process can't be killed, after I did some common
>> actions such as 'ls' 'vim' etc, the system
>> seemed to be really crashed, no any response.
>>
>> also in the previous testing, I can remember that the system would
>> be no any response for a long time, just only
>> repeatedly print out the such above 'Call Trace' into console.
> Ok, thanks.
> Just a couple of more questions: did you see this also on other archs, or just
> s390 (if you tried other platforms at all).
>
> If you have some time, could you please repeat your test with the kernel
> command line option " user_mode=home "?

What's the meaning of this command line? I can't find it in 
Documentation/kernel-parameters.txt/

>
> As far as I can tell there was only one s390 patch merged that was
> mmap related: 486c0a0bc80d370471b21662bf03f04fbb37cdc6 "s390/mm: Fix crst
> upgrade of mmap with MAP_FIXED".
> Even though I don't think it explains the bug you've seen it might be worth
> to try to revert it.
>
> And at last, can you share your kernel config?
>
> Thanks,
> Heiko
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
