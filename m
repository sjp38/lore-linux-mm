Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 688A66B0033
	for <linux-mm@kvack.org>; Mon, 30 Oct 2017 05:28:51 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id j3so13043279pga.5
        for <linux-mm@kvack.org>; Mon, 30 Oct 2017 02:28:51 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id m12si9626625pgr.313.2017.10.30.02.28.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Oct 2017 02:28:50 -0700 (PDT)
Date: Mon, 30 Oct 2017 10:28:42 +0100
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [pgtable_trans_huge_withdraw] BUG: unable to handle kernel NULL
 pointer dereference at 0000000000000020
Message-ID: <20171030092842.a2zq5gza4tufyku2@wfg-t540p.sh.intel.com>
References: <CA+55aFxSJGeN=2X-uX-on1Uq2Nb8+v1aiMDz5H1+tKW_N5Q+6g@mail.gmail.com>
 <20171029225155.qcum5i75awrt5tzm@wfg-t540p.sh.intel.com>
 <20171029233701.4pjqaesnrjqshmzn@wfg-t540p.sh.intel.com>
 <20171030091940.mcljomnaqvrhvwjx@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20171030091940.mcljomnaqvrhvwjx@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vineet Gupta <Vineet.Gupta1@synopsys.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Dan Williams <dan.j.williams@intel.com>, Geliang Tang <geliangtang@163.com>

Hi Kirill,

On Mon, Oct 30, 2017 at 12:19:40PM +0300, Kirill A. Shutemov wrote:
>On Mon, Oct 30, 2017 at 12:37:01AM +0100, Fengguang Wu wrote:
>> CC MM people.
>>
>> On Sun, Oct 29, 2017 at 11:51:55PM +0100, Fengguang Wu wrote:
>> > Hi Linus,
>> >
>> > Up to now we see the below boot error/warnings when testing v4.14-rc6.
>> >
>> > They hit the RC release mainly due to various imperfections in 0day's
>> > auto bisection. So I manually list them here and CC the likely easy to
>> > debug ones to the corresponding maintainers in the followup emails.
>> >
>> > boot_successes: 4700
>> > boot_failures: 247
>> >
>> > BUG:kernel_hang_in_test_stage: 152
>> > BUG:kernel_reboot-without-warning_in_test_stage: 10
>> > BUG:sleeping_function_called_from_invalid_context_at_kernel/locking/mutex.c: 1
>> > BUG:sleeping_function_called_from_invalid_context_at_kernel/locking/rwsem.c: 3
>> > BUG:sleeping_function_called_from_invalid_context_at_mm/page_alloc.c: 21
>> > BUG:soft_lockup-CPU##stuck_for#s: 1
>> > BUG:unable_to_handle_kernel: 13
>>
>> Here is the call trace:
>>
>> [  956.669197] [  956.670421] stress-ng: fail:  [27945] stress-ng-numa:
>> get_mempolicy: errno=22 (Invalid argument)
>
>Can you also share how you run stress-ng? Is it reproducible?

The command line is

        stress-ng --class cpu --sequential $(nproc) --timeout 1 --times --verify --metrics-brief

The test box is

        model: Broadwell-EP
        nr_cpu: 88
        memory: 128G

It shows up 4 times in 6 test runs:

/result/stress-ng/60s-cpu-performance/lkp-bdw-ep6/debian-x86_64-2016-08-31.cgz/x86_64-rhel-7.2/gcc-6/bb176f67090ca54869fc1262c913aa69d2ede070/matrix.json

  "dmesg.BUG:unable_to_handle_kernel": [
    0,
    1,
    1,
    1,
    0,
    1
  ],
 
Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
