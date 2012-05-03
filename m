Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 91A5B6B0083
	for <linux-mm@kvack.org>; Thu,  3 May 2012 12:22:55 -0400 (EDT)
Received: by bkwj4 with SMTP id j4so1990870bkw.36
        for <linux-mm@kvack.org>; Thu, 03 May 2012 09:22:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <x49fwbhl48d.fsf@segfault.boston.devel.redhat.com>
References: <1336054995-22988-1-git-send-email-svenkatr@ti.com>
 <1336054995-22988-7-git-send-email-svenkatr@ti.com> <x49fwbhl48d.fsf@segfault.boston.devel.redhat.com>
From: "S, Venkatraman" <svenkatr@ti.com>
Date: Thu, 3 May 2012 21:52:32 +0530
Message-ID: <CANfBPZ-V86XfnA8CXVsupvWkfnXPC7upCqAFsx8+_2Ta5zTabA@mail.gmail.com>
Subject: Re: [PATCH v2 06/16] block: treat DMPG and SWAPIN requests as special
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: linux-mmc@vger.kernel.org, cjb@laptop.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org, arnd.bergmann@linaro.org, alex.lemberg@sandisk.com, ilan.smith@sandisk.com, lporzio@micron.com, rmk+kernel@arm.linux.org.uk

On Thu, May 3, 2012 at 8:08 PM, Jeff Moyer <jmoyer@redhat.com> wrote:
> Venkatraman S <svenkatr@ti.com> writes:
>
>> From: Ilan Smith <ilan.smith@sandisk.com>
>>
>> When exp_swapin and exp_dmpg are set, treat read requests
>> marked with DMPG and SWAPIN as high priority and move to
>> the front of the queue.
>>
> [...]
>> + =A0 =A0 if (bio_swapin(bio) && blk_queue_exp_swapin(q)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 spin_lock_irq(q->queue_lock);
>> + =A0 =A0 =A0 =A0 =A0 =A0 where =3D ELEVATOR_INSERT_FLUSH;
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto get_rq;
>> + =A0 =A0 }
>> +
>> + =A0 =A0 if (bio_dmpg(bio) && blk_queue_exp_dmpg(q)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 spin_lock_irq(q->queue_lock);
>> + =A0 =A0 =A0 =A0 =A0 =A0 where =3D ELEVATOR_INSERT_FLUSH;
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto get_rq;
>
> Is ELEVATOR_INSERT_FRONT not good enough? =A0It seems wrong to use _FLUSH=
,
> here. =A0If the semantics of ELEVATOR_INSERT_FLUSH are really what is
> required, then perhaps we need to have another think about the naming of
> these flags.
>
Actually - yes, ELEVATOR_INSERT_FRONT would do as well. In the
previous version of MMC stack,
we needed the _FLUSH to trigger the write operation that was to be
preempted, to check that
it actually works.


> Cheers,
> Jeff
>
> --

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
