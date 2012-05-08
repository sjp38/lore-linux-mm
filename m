Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 0D1CA6B0044
	for <linux-mm@kvack.org>; Tue,  8 May 2012 19:10:15 -0400 (EDT)
Received: by obbwd18 with SMTP id wd18so14324946obb.14
        for <linux-mm@kvack.org>; Tue, 08 May 2012 16:10:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHGf_=p4py5m1Pe1xon=9FcEEyf6AxW+Pc9Yy9gCvNtbXM_40A@mail.gmail.com>
References: <CAHGf_=qdE3yNw=htuRssfav2pECO1Q0+gWMRTuNROd_3tVrd6Q@mail.gmail.com>
	<CAHGf_=ojhwPUWJR0r+jVgjNd5h_sRrppzJntSpHzxyv+OuBueg@mail.gmail.com>
	<x49ehr4lyw1.fsf@segfault.boston.devel.redhat.com>
	<CAHGf_=rzcfo3OnwT-YsW2iZLchHs3eBKncobvbhTm7B5PE=L-w@mail.gmail.com>
	<x491un3nc7a.fsf@segfault.boston.devel.redhat.com>
	<CAPa8GCCgLUt1EDAy7-O-mo0qir6Bf5Pi3Va1EsQ3ZW5UU=+37g@mail.gmail.com>
	<20120502081705.GB16976@quack.suse.cz>
	<CAPa8GCCnvvaj0Do7sdrdfsvbcAf0zBe3ssXn45gMfDKCcvJWxA@mail.gmail.com>
	<20120502091837.GC16976@quack.suse.cz>
	<CAHGf_=qfuRZzb91ELEcArNaNHsfO4BBMPO8a-QRBzFNaT2ev_w@mail.gmail.com>
	<20120502192325.GA18339@quack.suse.cz>
	<CAHGf_=oOx1qPFEboQeuaeMKtveM2==BSDG=xdfRHz+gFx1GAfw@mail.gmail.com>
	<CAKgNAkjybL_hmVfONUHtCbBe_VxQHNHOrmWQErGWDUqHiczkFg@mail.gmail.com>
	<CAHGf_=p4py5m1Pe1xon=9FcEEyf6AxW+Pc9Yy9gCvNtbXM_40A@mail.gmail.com>
Date: Wed, 9 May 2012 09:10:15 +1000
Message-ID: <CAPa8GCCh-RrjsQKzh9+Sxx-joRZw4qkpxR9n4svo+QopxAj_XQ@mail.gmail.com>
Subject: Re: [PATCH] Describe race of direct read and fork for unaligned buffers
From: Nick Piggin <npiggin@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: mtk.manpages@gmail.com, Jan Kara <jack@suse.cz>, Jeff Moyer <jmoyer@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-man@vger.kernel.org, linux-mm@kvack.org, mgorman@suse.de, Andrea Arcangeli <aarcange@redhat.com>, Woodman <lwoodman@redhat.com>

On 6 May 2012 01:29, KOSAKI Motohiro <kosaki.motohiro@gmail.com> wrote:
>> So, am I correct to assume that right text to add to the page is as belo=
w?
>>
>> Nick, can you clarify what you mean by "quiesced"?
>
> finished?

Yes exactly. That might be a simpler word. Thanks!

>
>>
>> [[
>> O_DIRECT IOs should never be run concurrently with fork(2) system call,
>> when the memory buffer is anonymous memory, or comes from mmap(2)
>> with MAP_PRIVATE.
>>
>> Any such IOs, whether submitted with asynchronous IO interface or from
>> another thread in the process, should be quiesced before fork(2) is call=
ed.
>> Failure to do so can result in data corruption and undefined behavior in
>> parent and child processes.
>>
>> This restriction does not apply when the memory buffer for the O_DIRECT
>> IOs comes from mmap(2) with MAP_SHARED or from shmat(2).
>> Nor does this restriction apply when the memory buffer has been advised
>> as MADV_DONTFORK with madvise(2), ensuring that it will not be available
>> to the child after fork(2).
>> ]]
>
> I don't have good English and I can't make editorial check. But at least,
> I don't find any technical incorrect explanation here.
>
> =C2=A0Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
