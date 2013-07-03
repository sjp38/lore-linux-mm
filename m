Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id CF6966B0034
	for <linux-mm@kvack.org>; Wed,  3 Jul 2013 03:44:35 -0400 (EDT)
Received: by mail-wg0-f50.google.com with SMTP id k14so5482749wgh.5
        for <linux-mm@kvack.org>; Wed, 03 Jul 2013 00:44:34 -0700 (PDT)
MIME-Version: 1.0
Reply-To: sedat.dilek@gmail.com
In-Reply-To: <20130702223405.AF5BB5A4016@corp2gmr1-2.hot.corp.google.com>
References: <20130702223405.AF5BB5A4016@corp2gmr1-2.hot.corp.google.com>
Date: Wed, 3 Jul 2013 09:44:34 +0200
Message-ID: <CA+icZUWX761O5tAfdYfgR0_QA8zMiZOqBBjzbWVeEcZPL+M_pQ@mail.gmail.com>
Subject: Re: mmotm 2013-07-02-15-32 uploaded
From: Sedat Dilek <sedat.dilek@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, Davidlohr Bueso <davidlohr.bueso@hp.com>

On Wed, Jul 3, 2013 at 12:34 AM,  <akpm@linux-foundation.org> wrote:
> The mm-of-the-moment snapshot 2013-07-02-15-32 has been uploaded to
>
>    http://www.ozlabs.org/~akpm/mmotm/
>
> mmotm-readme.txt says
>
> README for mm-of-the-moment:
>
> http://www.ozlabs.org/~akpm/mmotm/
>
> This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> more than once a week.
>
> You will need quilt to apply these patches to the latest Linus release (3.x
> or 3.x-rcY).  The series file is in broken-out.tar.gz and is duplicated in
> http://ozlabs.org/~akpm/mmotm/series
>
> The file broken-out.tar.gz contains two datestamp files: .DATE and
> .DATE-yyyy-mm-dd-hh-mm-ss.  Both contain the string yyyy-mm-dd-hh-mm-ss,
> followed by the base kernel version against which this patch series is to
> be applied.
>
> This tree is partially included in linux-next.  To see which patches are
> included in linux-next, consult the `series' file.  Only the patches
> within the #NEXT_PATCHES_START/#NEXT_PATCHES_END markers are included in
> linux-next.
>

Hi Andrew,

1st, I would like to see a diff to previous mmotm release.
Is that possible - with the announce.
For example, I like to diff series file of mmot*m* and mmot*s*.

AFAICS, you wanted to fold the fix into the real patch?

ipcmsg-shorten-critical-region-in-msgctl_down.patch
ipcmsg-shorten-critical-region-in-msgrcv-fix-race-in-msgrcv2.patch

3rd, is the "sysv-ipc-shm-optimizations" patchset from Davidlohr included here?
( I had no closer look. )

Thanks for maintaining -mm stuff!

Regards,
- Sedat -

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
