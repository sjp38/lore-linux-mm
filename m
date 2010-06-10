Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 46AB76B01AF
	for <linux-mm@kvack.org>; Thu, 10 Jun 2010 12:55:30 -0400 (EDT)
Received: by pzk36 with SMTP id 36so83465pzk.32
        for <linux-mm@kvack.org>; Thu, 10 Jun 2010 09:57:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTik6xP9vVEyW4QG-4RfZu-iEuHcl2pBV_-mfHP4y@mail.gmail.com>
References: <AANLkTik6xP9vVEyW4QG-4RfZu-iEuHcl2pBV_-mfHP4y@mail.gmail.com>
From: Mulyadi Santosa <mulyadi.santosa@gmail.com>
Date: Thu, 10 Jun 2010 23:56:30 +0700
Message-ID: <AANLkTinXqriwgslQwjmjYaGjiyVK4oh1HZcTwxgWCZkh@mail.gmail.com>
Subject: Re: oom killer and long-waiting processes
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Ryan Wang <openspace.wang@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernelnewbies@nl.linux.org
List-ID: <linux-mm.kvack.org>

Hi

On Thu, Jun 10, 2010 at 14:17, Ryan Wang <openspace.wang@gmail.com> wrote:
> Hi all,
>
> =A0 =A0 =A0 =A0I have one question about oom killer:
> If many processes dealing with network communications,
> but due to bad network traffic, the processes have to wait
> for a very long time. And meanwhile they may consume
> some memeory separately for computation. The number
> of such processes may be large.


Please refer to my article here :
http://linuxdevcenter.com/pub/a/linux/2006/11/30/linux-out-of-memory.html

Right now, I can not recall entirely about the rules, but IIRC the
processes that do I/O get lower "score". But that doesn't mean it
won't be killed if free memory amount is really low...

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
