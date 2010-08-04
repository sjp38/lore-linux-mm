Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 4AE0562012A
	for <linux-mm@kvack.org>; Wed,  4 Aug 2010 05:14:42 -0400 (EDT)
Received: by wyg36 with SMTP id 36so6180605wyg.14
        for <linux-mm@kvack.org>; Wed, 04 Aug 2010 02:14:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTi=1DxqLrqVbfRouOBRWg4RHFaHz438X7F1JWL6P@mail.gmail.com>
References: <AANLkTi=1DxqLrqVbfRouOBRWg4RHFaHz438X7F1JWL6P@mail.gmail.com>
From: Mulyadi Santosa <mulyadi.santosa@gmail.com>
Date: Wed, 4 Aug 2010 16:14:10 +0700
Message-ID: <AANLkTimejYX3OEk9j+L+nWKyBuf7=rJbAOvQGhxJNPxN@mail.gmail.com>
Subject: Re: question about CONFIG_BASE_SMALL
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Ryan Wang <openspace.wang@gmail.com>
Cc: kernelnewbies@nl.linux.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi...

On Wed, Aug 4, 2010 at 15:38, Ryan Wang <openspace.wang@gmail.com> wrote:
> Hi all,
>
> =A0 =A0 =A0I noticed CONFIG_BASE_SMALL in different parts
> of the kernel code, with ifdef/ifndef.
> =A0 =A0 =A0I wonder what does CONFIG_BASE_SMALL mean?
> And how can I configure it, e.g. through make menuconfig?

Reply on top of my head: IIRC it means to disable certain things...or
possibly enabling things that might reduce memory footprints.

The goal....to make Linux kernel running more suitable for embedded
system and low level specification machine...

--=20
regards,

Mulyadi Santosa
Freelance Linux trainer and consultant

blog: the-hydra.blogspot.com
training: mulyaditraining.blogspot.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
