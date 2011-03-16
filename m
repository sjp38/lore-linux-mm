Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4548C8D0039
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 02:27:07 -0400 (EDT)
Received: by gwaa12 with SMTP id a12so706860gwa.14
        for <linux-mm@kvack.org>; Tue, 15 Mar 2011 23:27:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110316042452.21452.qmail@science.horizon.com>
References: <1300244636.3128.426.camel@calx>
	<20110316042452.21452.qmail@science.horizon.com>
Date: Wed, 16 Mar 2011 08:27:05 +0200
Message-ID: <AANLkTi=eQn=G0E3XXp=MR2LErWrPJ8fZtr9RM3Q-Q=PP@mail.gmail.com>
Subject: Re: [PATCH 2/8] drivers/char/random: Split out __get_random_int
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: George Spelvin <linux@horizon.com>
Cc: mpm@selenic.com, herbert@gondor.apana.org.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, penberg@cs.helsinki.fi

On Wed, Mar 16, 2011 at 6:24 AM, George Spelvin <linux@horizon.com> wrote:
>> You should really try to put all the uncontroversial bits of a series
>> first.
>
> Is that really a more important principle than putting related changes
> together? =A0I get the idea, but thought it made more sense to put
> all the slub.c changes together.

It it is more important because we might end up merging only the
non-controversial bits - at least for now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
