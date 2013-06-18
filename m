Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 262766B0034
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 12:59:06 -0400 (EDT)
Message-ID: <51C091D6.8010608@mozilla.com>
Date: Tue, 18 Jun 2013 12:59:02 -0400
From: Dhaval Giani <dgiani@mozilla.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/8] Volatile Ranges (v8?)
References: <1371010971-15647-1-git-send-email-john.stultz@linaro.org> <51BF3827.4060606@mozilla.com> <20130618041100.GA3116@bbox>
In-Reply-To: <20130618041100.GA3116@bbox>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, Andrea Arcangeli <aarcange@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 2013-06-18 12:11 AM, Minchan Kim wrote:
> Hello Dhaval,
>
> On Mon, Jun 17, 2013 at 12:24:07PM -0400, Dhaval Giani wrote:
>> Hi John,
>>
>> I have been giving your git tree a whirl, and in order to simulate a
>> limited memory environment, I was using memory cgroups.
>>
>> The program I was using to test is attached here. It is your test
>> code, with some changes (changing the syscall interface, reducing
>> the memory pressure to be generated).
>>
>> I trapped it in a memory cgroup with 1MB memory.limit_in_bytes and hit this,
>>
>> [  406.207612] ------------[ cut here ]------------
>> [  406.207621] kernel BUG at mm/vrange.c:523!
>> [  406.207626] invalid opcode: 0000 [#1] SMP
>> [  406.207631] Modules linked in:
>> [  406.207637] CPU: 0 PID: 1579 Comm: volatile-test Not tainted
> Thanks for the testing!
> Does below patch fix your problem?

Yes it does! Thank you very much for the patch.

Thanks!
Dhaval

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
