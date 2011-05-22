Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id E27E46B0011
	for <linux-mm@kvack.org>; Sun, 22 May 2011 19:43:49 -0400 (EDT)
Received: by qyk30 with SMTP id 30so3735794qyk.14
        for <linux-mm@kvack.org>; Sun, 22 May 2011 16:43:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1439534018.155162.1306035460906.JavaMail.root@zmail05.collab.prod.int.phx2.redhat.com>
References: <1158989060.155090.1306033067946.JavaMail.root@zmail05.collab.prod.int.phx2.redhat.com>
	<1439534018.155162.1306035460906.JavaMail.root@zmail05.collab.prod.int.phx2.redhat.com>
Date: Mon, 23 May 2011 08:43:49 +0900
Message-ID: <BANLkTimyhoVQh6KL_HQG1trD3Mykn_+vWA@mail.gmail.com>
Subject: Re: Kernel panic - not syncing: Attempted to kill the idle task!
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qiannan Cui <qcui@redhat.com>
Cc: linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>

On Sun, May 22, 2011 at 12:37 PM, Qiannan Cui <qcui@redhat.com> wrote:
> Hi,
> When I updated the kernel from 2.6.32 to 2.6.39+, the server can not boot=
 the 2.6.39+ kernel successfully. The console ouput showed 'Kernel panic - =
not syncing: Attempted to kill the idle task!' I have tried to set the kern=
el parameter idle=3Dpoll in the grub file. But it failed to boot again due =
to the same error. Could anyone help me to solve the problem? The full cons=
ole output is attached. Thanks.
>
> Best Regards,
> Cui
>

The backtrace shows alloc_pages_exact_nid but I am not sure it is a
culprit as I followed the patch at that time. Cced Andi.

Could you show your config?
Could you test with reverting [ee85c2,  mm: add alloc_pages_exact_nid()]?
Maybe it can help Andy.

Thanks.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
