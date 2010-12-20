Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D64626B009C
	for <linux-mm@kvack.org>; Sun, 19 Dec 2010 20:48:10 -0500 (EST)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id oBK1m7k8003935
	for <linux-mm@kvack.org>; Sun, 19 Dec 2010 17:48:07 -0800
Received: from qwg5 (qwg5.prod.google.com [10.241.194.133])
	by hpaq12.eem.corp.google.com with ESMTP id oBK1m6s9029445
	for <linux-mm@kvack.org>; Sun, 19 Dec 2010 17:48:06 -0800
Received: by qwg5 with SMTP id 5so2299173qwg.20
        for <linux-mm@kvack.org>; Sun, 19 Dec 2010 17:48:06 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <131961.1292667059@localhost>
References: <201012162329.oBGNTdPY006808@imap1.linux-foundation.org>
	<131961.1292667059@localhost>
Date: Sun, 19 Dec 2010 17:48:05 -0800
Message-ID: <AANLkTik4ffEzb_zzEN7Y+fksSkr+6HZs5Szd4VupH4+-@mail.gmail.com>
Subject: Re: mmotm 2010-12-16 - breaks mlockall() call
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Valdis.Kletnieks@vt.edu
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Dec 18, 2010 at 2:10 AM,  <Valdis.Kletnieks@vt.edu> wrote:
> On Thu, 16 Dec 2010 14:56:39 PST, akpm@linux-foundation.org said:
>> The mm-of-the-moment snapshot 2010-12-16-14-56 has been uploaded to
>>
>> =A0 =A0http://userweb.kernel.org/~akpm/mmotm/
>
> The patch mlock-only-hold-mmap_sem-in-shared-mode-when-faulting-in-pages.=
patch
> causes this chunk of code from cryptsetup-luks to fail during the initram=
fs:
>
> =A0 =A0 =A0 =A0if (mlockall(MCL_CURRENT | MCL_FUTURE)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0log_err(ctx, _("WARNING!!!=
 Possibly insecure memory. Are you root?\n"));
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0_memlock_count--;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> Bisection fingered this patch, which was added after -rc4-mmotm1202, whic=
h
> boots without tripping this log_err() call. =A0I haven't tried building a
> -rc6-mmotm1216 with this patch reverted, because reverting it causes appl=
y
> errors for subsequent patches.
>
> Ideas?

I had a quick look, but didn't figure out much so far.

Could you send me your initramfs image and .config file so I can
reproduce the issue locally ?

Thanks,

--=20
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
