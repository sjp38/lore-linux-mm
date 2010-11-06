Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A8F356B0096
	for <linux-mm@kvack.org>; Sat,  6 Nov 2010 13:31:14 -0400 (EDT)
Received: by iwn9 with SMTP id 9so4104667iwn.14
        for <linux-mm@kvack.org>; Sat, 06 Nov 2010 10:31:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTin9m65JVKRuStZ1-qhU5_1AY-GcbBRC0TodsfYC@mail.gmail.com>
References: <1288973333-7891-1-git-send-email-minchan.kim@gmail.com>
	<20101106010357.GD23393@cmpxchg.org>
	<AANLkTin9m65JVKRuStZ1-qhU5_1AY-GcbBRC0TodsfYC@mail.gmail.com>
Date: Sun, 7 Nov 2010 02:31:13 +0900
Message-ID: <AANLkTin8UMMszcz+C9iGJ62T+mARmnQ-LEu4p1VdqKjC@mail.gmail.com>
Subject: Re: [PATCH] memcg: use do_div to divide s64 in 32 bit machine.
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: hannes@cmpxchg.org, Andrew Morton <akpm@linux-foundation.org>, Dave Young <hidave.darkstar@gmail.com>, Andrea Righi <arighi@develer.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Wu Fengguang <fengguang.wu@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, Nov 7, 2010 at 2:19 AM, Greg Thelen <gthelen@google.com> wrote:
> On Fri, Nov 5, 2010 at 6:03 PM, =A0<hannes@cmpxchg.org> wrote:
>> On Sat, Nov 06, 2010 at 01:08:53AM +0900, Minchan Kim wrote:
>>> Use do_div to divide s64 value. Otherwise, build would be failed
>>> like Dave Young reported.
>>
>> I thought about that too, but then I asked myself why you would want
>> to represent a number of pages as signed 64bit type, even on 32 bit?
>
> I think the reason that 64 byte type is used for page count in
> memcontrol.c is because the low level res_counter primitives operate
> on 64 bit counters, even on 32 bit machines.
>
>> Isn't the much better fix to get the types right instead?
>>
>
> I agree that consistent types between mem_cgroup_dirty_info() and
> global_dirty_info() is important. =A0There seems to be a lot of usage of
> s64 for page counts in memcontrol.c, which I think is due to the
> res_counter types. =A0I think these s64 be switched to unsigned long
> rather to be consistent with the rest of mm code. =A0It looks like this
> will be a clean patch, except for the lowest level where
> res_counter_read_u64() is used, where some casting may be needed.
>
> I'll post a patch for that change.
>

Agree. I don't mind it.
Thanks, Hannes and Greg.



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
