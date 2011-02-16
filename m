Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id AC6A38D0039
	for <linux-mm@kvack.org>; Wed, 16 Feb 2011 14:58:26 -0500 (EST)
Received: from mail-iw0-f169.google.com (mail-iw0-f169.google.com [209.85.214.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p1GJvuNR006947
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Wed, 16 Feb 2011 11:57:56 -0800
Received: by iwc10 with SMTP id 10so1683452iwc.14
        for <linux-mm@kvack.org>; Wed, 16 Feb 2011 11:57:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110216193700.GA6377@elte.hu>
References: <20110216185234.GA11636@tiehlicka.suse.cz> <20110216193700.GA6377@elte.hu>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 16 Feb 2011 11:50:28 -0800
Message-ID: <AANLkTinDxxbVjrUViCs=UaMD9Wg9PR7b0ShNud5zKE3w@mail.gmail.com>
Subject: Re: BUG: Bad page map in process udevd (anon_vma: (null)) in 2.6.38-rc4
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed, Feb 16, 2011 at 11:37 AM, Ingo Molnar <mingo@elte.hu> wrote:
>
> ( Cc:-ed Linus - he was analyzing a similar looking bug a few days ago on=
 lkml.
> =A0Mail repeated below. )

Yup, goodie. It does look like it might be exactly the same thing,
except now the offset seems to be 0x1e68 instead of 0x1768.

I'll compile a x86-32 kernel with that config and try to see if I can
find that offset in there..

                      Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
