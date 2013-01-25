Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 991416B0005
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 18:37:36 -0500 (EST)
Message-ID: <51031738.4060102@oracle.com>
Date: Fri, 25 Jan 2013 18:37:28 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: boot warnings due to swap: make each swap partition have one
 address_space
References: <5101FFF5.6030503@oracle.com> <20130125042512.GA32017@kernel.org>
In-Reply-To: <20130125042512.GA32017@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shli@fusionio.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 01/24/2013 11:25 PM, Shaohua Li wrote:
> On Thu, Jan 24, 2013 at 10:45:57PM -0500, Sasha Levin wrote:
>> Hi folks,
>>
>> Commit "swap: make each swap partition have one address_space" is triggering
>> a series of warnings on boot:
>>
>> [    3.446071] ------------[ cut here ]------------
>> [    3.446664] WARNING: at lib/debugobjects.c:261 debug_print_object+0x8e/0xb0()
>> [    3.447715] ODEBUG: init active (active state 0) object type: percpu_counter hint:           (null)
>> [    3.450360] Modules linked in:
>> [    3.451593] Pid: 1, comm: swapper/0 Tainted: G        W    3.8.0-rc4-next-20130124-sasha-00004-g838a1b4 #266
>> [    3.454508] Call Trace:
>> [    3.455248]  [<ffffffff8110d1bc>] warn_slowpath_common+0x8c/0xc0
>> [    3.455248]  [<ffffffff8110d291>] warn_slowpath_fmt+0x41/0x50
>> [    3.455248]  [<ffffffff81a2bb5e>] debug_print_object+0x8e/0xb0
>> [    3.455248]  [<ffffffff81a2c26b>] __debug_object_init+0x20b/0x290
>> [    3.455248]  [<ffffffff81a2c305>] debug_object_init+0x15/0x20
>> [    3.455248]  [<ffffffff81a3fbed>] __percpu_counter_init+0x6d/0xe0
>> [    3.455248]  [<ffffffff81231bdc>] bdi_init+0x1ac/0x270
>> [    3.455248]  [<ffffffff8618f20b>] swap_setup+0x3b/0x87
>> [    3.455248]  [<ffffffff8618f257>] ? swap_setup+0x87/0x87
>> [    3.455248]  [<ffffffff8618f268>] kswapd_init+0x11/0x7c
>> [    3.455248]  [<ffffffff810020ca>] do_one_initcall+0x8a/0x180
>> [    3.455248]  [<ffffffff86168cfd>] do_basic_setup+0x96/0xb4
>> [    3.455248]  [<ffffffff861685ae>] ? loglevel+0x31/0x31
>> [    3.455248]  [<ffffffff861885cd>] ? sched_init_smp+0x150/0x157
>> [    3.455248]  [<ffffffff86168ded>] kernel_init_freeable+0xd2/0x14c
>> [    3.455248]  [<ffffffff83cade10>] ? rest_init+0x140/0x140
>> [    3.455248]  [<ffffffff83cade19>] kernel_init+0x9/0xf0
>> [    3.455248]  [<ffffffff83d5727c>] ret_from_fork+0x7c/0xb0
>> [    3.455248]  [<ffffffff83cade10>] ? rest_init+0x140/0x140
>> [    3.455248] ---[ end trace 0b176d5c0f21bffb ]---
>>
>> I haven't looked deeper into it yet, and will do so tomorrow, unless this
>> spew is obvious to anyone.
> 
> Does this one help?

[snip]

Yup, it did. Thanks!


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
