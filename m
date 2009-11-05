Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id F37CD6B0044
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 17:18:24 -0500 (EST)
Received: by pzk34 with SMTP id 34so292265pzk.11
        for <linux-mm@kvack.org>; Thu, 05 Nov 2009 14:18:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <loom.20091105T213323-393@post.gmane.org>
References: <20091030063216.GA30712@gamma.logic.tuwien.ac.at>
	 <20091102005218.8352.A69D9226@jp.fujitsu.com>
	 <20091102135640.93de7c2a.minchan.kim@barrios-desktop>
	 <28c262360911012300h4535118ewd65238c746b91a52@mail.gmail.com>
	 <20091102155543.E60E.A69D9226@jp.fujitsu.com>
	 <20091102140216.02567ff8.kamezawa.hiroyu@jp.fujitsu.com>
	 <20091102141917.GJ2116@gamma.logic.tuwien.ac.at>
	 <28c262360911020640k3f9dfcdct2cac6cc1d193144d@mail.gmail.com>
	 <20091105132109.GA12676@gamma.logic.tuwien.ac.at>
	 <loom.20091105T213323-393@post.gmane.org>
Date: Fri, 6 Nov 2009 07:18:23 +0900
Message-ID: <28c262360911051418r1aefbff6oa54a63d887c0ea48@mail.gmail.com>
Subject: Re: OOM killer, page fault
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Norbert Preining <preining@logic.at>, Jody Belka <jody+lkml@jj79.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 6, 2009 at 5:37 AM, Jody Belka <jody+lkml@jj79.org> wrote:
> Norbert Preining <preining <at> logic.at> writes:
>> Don't ask me why, please, and I don't have a serial/net console so that
>> I can tell you more, but the booting hangs badly at:
>
> <snip>
>
>>
>> > diff --git a/mm/memory.c b/mm/memory.c
>> > index 7e91b5f..47e4b15 100644
>> > --- a/mm/memory.c
>> > +++ b/mm/memory.c
>> > @@ -2713,7 +2713,11 @@ static int __do_fault(struct mm_struct *mm,
>> > struct vm_area_struct *vma,
>> > =A0 =A0 =A0 =A0vmf.page =3D NULL;
>> >
>> > =A0 =A0 =A0 =A0ret =3D vma->vm_ops->fault(vma, &vmf);
>> > - =A0 =A0 =A0 if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))
>> > + =A0 =A0 =A0 if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE))) =
{
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_DEBUG "vma->vm_ops->fault : =
0x%lx\n",
>> > vma->vm_ops->fault);
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 WARN_ON(1);
>> > +
>> > + =A0 =A0 =A0 }
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return ret;
>> >
>> > =A0 =A0 =A0 =A0if (unlikely(PageHWPoison(vmf.page))) {
>>
>
> Erm, could it not be due to the "return ret;" line being moved outside of=
 the
> if(), so that it always executes?

Right. Sorry it's my fault.
I become  blind.
'return ret' should be inclueded in debug code.

>
>
> J
>
> ps, sending this through gmane, don't know if it'll keep cc's or not, so
> apologies if not. please cc me on any replies
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
