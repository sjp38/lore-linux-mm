Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2A51D6B0012
	for <linux-mm@kvack.org>; Mon, 23 May 2011 11:46:19 -0400 (EDT)
Received: by qyk2 with SMTP id 2so1137448qyk.14
        for <linux-mm@kvack.org>; Mon, 23 May 2011 08:46:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <2145175999.163861.1306145327459.JavaMail.root@zmail05.collab.prod.int.phx2.redhat.com>
References: <BANLkTimyhoVQh6KL_HQG1trD3Mykn_+vWA@mail.gmail.com>
	<2145175999.163861.1306145327459.JavaMail.root@zmail05.collab.prod.int.phx2.redhat.com>
Date: Tue, 24 May 2011 00:46:15 +0900
Message-ID: <BANLkTim5u_iBECWctoGg=RwLoxcqckScGQ@mail.gmail.com>
Subject: Re: Kernel panic - not syncing: Attempted to kill the idle task!
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qiannan Cui <qcui@redhat.com>
Cc: linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Mon, May 23, 2011 at 7:08 PM, Qiannan Cui <qcui@redhat.com> wrote:
>
>
> On Sun, May 22, 2011 at 12:37 PM, Qiannan Cui <qcui@redhat.com> wrote:
>> Hi,
>> When I updated the kernel from 2.6.32 to 2.6.39+, the server can not boo=
t the 2.6.39+ kernel successfully. The console ouput showed 'Kernel panic -=
 not syncing: Attempted to kill the idle task!' I have tried to set the ker=
nel parameter idle=3Dpoll in the grub file. But it failed to boot again due=
 to the same error. Could anyone help me to solve the problem? The full con=
sole output is attached. Thanks.
>>
>> Best Regards,
>> Cui
>>
>
>> The backtrace shows alloc_pages_exact_nid but I am not sure it is a
> culprit as I followed the patch at that time. Cced Andi.
>
>> Could you show your config?
>> Could you test with reverting [ee85c2, =C2=A0mm: add alloc_pages_exact_n=
id()]?
> Maybe it can help Andy.
>
>> Thanks.
>>
>
>
> Tested without the patch mm: add alloc_pages_exact_nid(), but kernel pani=
c were still there.

Do you know what version kernel works well between 2.6.32 and 2.6.39
in your machine?
As I look further, some culprit are 21a3c96468[memcg: allocate memory
cgroup structures in local nodes], 6cfddb26155[page_cgroup: reduce
allocation overhead for page_cgroup array for CONFIG_SPARSEMEM] if the
problem happen recently.
If kernel panic still happen, could you do git-bisect?


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
