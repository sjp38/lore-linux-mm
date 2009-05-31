Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 86C646B0062
	for <linux-mm@kvack.org>; Sun, 31 May 2009 02:26:46 -0400 (EDT)
Received: by fxm12 with SMTP id 12so9518153fxm.38
        for <linux-mm@kvack.org>; Sat, 30 May 2009 23:27:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090531023556.GB9033@oblivion.subreption.com>
References: <20090531015537.GA8941@oblivion.subreption.com>
	 <alpine.LFD.2.01.0905301902530.3435@localhost.localdomain>
	 <20090531023556.GB9033@oblivion.subreption.com>
Date: Sun, 31 May 2009 09:27:09 +0300
Message-ID: <84144f020905302327t36966003ufce87cf646d649a6@mail.gmail.com>
Subject: Re: [PATCH] Use kzfree in tty buffer management to enforce data
	sanitization
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: "Larry H." <research@subreption.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>
List-ID: <linux-mm.kvack.org>

Hi Larry,

On Sat, 30 May 2009, Larry H. wrote:
>>> This patch doesn't affect fastpaths.

On 19:04 Sat 30 May, Linus Torvalds wrote:
>> This patch is ugly as hell.
>>
>> You already know the size of the data to clear.
>>
>> If we actually wanted this (and I am in _no_way_ saying we do), the only
>> sane thing to do is to just do
>>
>> =A0 =A0 =A0 memset(buf->data, 0, N_TTY_BUF_SIZE);
>> =A0 =A0 =A0 if (PAGE_SIZE !=3D N_TTY_BUF_SIZE)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 kfree(...)
>> =A0 =A0 =A0 else
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_page(...)
>>

On Sun, May 31, 2009 at 5:35 AM, Larry H. <research@subreption.com> wrote:
> It wasn't me who proposed using kzfree in these places. Ask Ingo and
> Peter or refer to the entire thread about my previous patches.

Nobody suggested using kzfree() in this _specific_place_. It's obvious
that memset() is a better solution here given the current constraints
of the code as demonstrated by Linus' patch.

                                       Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
