Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4CD726B01E3
	for <linux-mm@kvack.org>; Sat, 15 May 2010 18:45:20 -0400 (EDT)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id o4FMjFeU003863
	for <linux-mm@kvack.org>; Sat, 15 May 2010 15:45:15 -0700
Received: from qyk2 (qyk2.prod.google.com [10.241.83.130])
	by kpbe16.cbf.corp.google.com with ESMTP id o4FMjADf007755
	for <linux-mm@kvack.org>; Sat, 15 May 2010 15:45:10 -0700
Received: by qyk2 with SMTP id 2so4852572qyk.20
        for <linux-mm@kvack.org>; Sat, 15 May 2010 15:45:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTil4zgqBtBAp--P8VdynpbohxVosQ-qFiQQ_c5Bb@mail.gmail.com>
References: <1273869997-12720-1-git-send-email-gthelen@google.com>
	<alpine.DEB.2.00.1005141626250.20193@router.home> <AANLkTil4zgqBtBAp--P8VdynpbohxVosQ-qFiQQ_c5Bb@mail.gmail.com>
From: Greg Thelen <gthelen@google.com>
Date: Sat, 15 May 2010 15:44:50 -0700
Message-ID: <AANLkTink6jV2RNoIaym4HcIx-mU1yIKURWahw8waNMQW@mail.gmail.com>
Subject: Re: [PATCH] mm: Consider the entire user address space during node
	migration
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Mel Gorman <mel@csn.ul.ie>, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, balbir@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, May 15, 2010 at 7:31 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>
> Hi
>
> Mysteriously, I haven't receive original post.
> So now I'm guessing you acked following patch.
>
> http://lkml.org/lkml/2010/5/14/393
>
> but I don't think it is correct.
>
> > - =A0 =A0 check_range(mm, mm->mmap->vm_start, TASK_SIZE, &nmask,
> > + =A0 =A0 check_range(mm, mm->mmap->vm_start, TASK_SIZE_MAX, &nmask,
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 flags | MPOL_MF_DISCONTIG_O=
K, &pagelist);
>
> Because TASK_SIZE_MAX is defined on x86 only. Why can we ignore other pla=
tform?
> Please put following line anywhere.
>
> #define TASK_SIZE_MAX TASK_SIZE

I just send out patch v2, which uses mm->task_size rather than
TASK_SIZE_MAX.  Some non-x86 architectures do not define
TASK_SIZE_MAX, but do make TASK_SIZE depend on the current task.  So I
feel it would be better to refer to the mm struct to obtain the needed
address space limit information rather than TASK_SIZE[_MAX], which can
depend on current.

--
Greg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
