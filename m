Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 363826B0072
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 10:39:42 -0500 (EST)
Received: by mail-wg0-f47.google.com with SMTP id n12so800776wgh.2
        for <linux-mm@kvack.org>; Fri, 06 Dec 2013 07:39:41 -0800 (PST)
Received: from mail-we0-x234.google.com (mail-we0-x234.google.com [2a00:1450:400c:c03::234])
        by mx.google.com with ESMTPS id ep4si36809895wjd.163.2013.12.06.07.39.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 06 Dec 2013 07:39:40 -0800 (PST)
Received: by mail-we0-f180.google.com with SMTP id t61so811604wes.39
        for <linux-mm@kvack.org>; Fri, 06 Dec 2013 07:39:39 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <A8856C6323EFE0459533E910625AB930347FDF@Exchange10.columbia.tresys.com>
References: <1386018639-18916-1-git-send-email-wroberts@tresys.com>
	<A8856C6323EFE0459533E910625AB930347FDF@Exchange10.columbia.tresys.com>
Date: Fri, 6 Dec 2013 07:39:39 -0800
Message-ID: <CAFftDdqtXvkF9wpcWv5kyeXSwR1_5FCSrhwRg9SsG5mPHfyEVw@mail.gmail.com>
Subject: Re: [PATCH] - auditing cmdline
From: William Roberts <bill.c.roberts@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: William Roberts <WRoberts@tresys.com>
Cc: "linux-audit@redhat.com" <linux-audit@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "rgb@redhat.com" <rgb@redhat.com>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "sds@tycho.nsa.gov" <sds@tycho.nsa.gov>

Sigh...I sent this back out from another emai address and got bounced
from the lists... resending. Sorry for the cruft.

On Fri, Dec 6, 2013 at 7:34 AM, William Roberts <WRoberts@tresys.com> wrote=
:
> I sent out 3 patches on 12/2/2013. I didn't get any response. I thought I=
 added the right people based on get_maintainers script.
>
> Can anyone comment on these or point me in the right direction?
>
> RGB, Can you at least ACK the audit subsystem patch " audit: Audit proc c=
mdline value"?
>
> Thank you,
> Bill
>
> -----Original Message-----
> From: owner-linux-mm@kvack.org [mailto:owner-linux-mm@kvack.org] On Behal=
f Of William Roberts
> Sent: Monday, December 02, 2013 1:11 PM
> To: linux-audit@redhat.com; linux-mm@kvack.org; linux-kernel@vger.kernel.=
org; rgb@redhat.com; viro@zeniv.linux.org.uk
> Cc: sds@tycho.nsa.gov
> Subject: [PATCH] - auditing cmdline
>
> This patch series relates to work started on the audit mailing list.
> It eventually involved touching other modules, so I am trying to pull in =
those owners as well. In a nutshell I add new utility functions for accessi=
ng a processes cmdline value as displayed in proc/<self>/cmdline, and then =
refactor procfs to use the utility functions, and then add the ability to t=
he audit subsystem to record this value.
>
> Thanks for any feedback and help.
>
> [PATCH 1/3] mm: Create utility functions for accessing a tasks
> [PATCH 2/3] proc: Update get proc_pid_cmdline() to use mm.h helpers
> [PATCH 3/3] audit: Audit proc cmdline value
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in the body to=
 majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>



--=20
Respectfully,

William C Roberts

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
