Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 77FDC900194
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 14:06:38 -0400 (EDT)
Received: by wyg36 with SMTP id 36so999109wyg.14
        for <linux-mm@kvack.org>; Wed, 22 Jun 2011 11:06:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110622110034.89ee399c.akpm@linux-foundation.org>
References: <1308741534-6846-1-git-send-email-sassmann@kpanic.de>
	<20110622110034.89ee399c.akpm@linux-foundation.org>
Date: Wed, 22 Jun 2011 14:06:34 -0400
Message-ID: <BANLkTimPMnuoBRT9897hc-qBttyRZn46+A@mail.gmail.com>
Subject: Re: [PATCH v2 0/3] support for broken memory modules (BadRAM)
From: Josh Boyer <jwboyer@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Stefan Assmann <sassmann@kpanic.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tony.luck@intel.com, andi@firstfloor.org, mingo@elte.hu, hpa@zytor.com, rick@vanrein.org, rdunlap@xenotime.net, Nancy Yuen <yuenn@google.com>, Michael Ditto <mditto@google.com>

On Wed, Jun 22, 2011 at 2:00 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:>
> I have a couple of thoughts here:
>
> - If this patchset is merged and a major user such as google is
> =A0unable to use it and has to continue to carry a separate patch then
> =A0that's a regrettable situation for the upstream kernel.
>
> - Google's is, afaik, the largest use case we know of: zillions of
> =A0machines for a number of years. =A0And this real-world experience tell=
s
> =A0us that the badram patchset has shortcomings. =A0Shortcomings which we
> =A0can expect other users to experience.
>
> So. =A0What are your thoughts on these issues?

Has Google submitted patches for their implementation?

josh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
