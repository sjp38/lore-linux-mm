Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id BC92F6B004D
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 05:32:37 -0500 (EST)
Received: by pxi5 with SMTP id 5so1837357pxi.12
        for <linux-mm@kvack.org>; Tue, 17 Nov 2009 02:32:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091117102903.7cb45ff3@lxorguk.ukuu.org.uk>
References: <20091117161551.3DD4.A69D9226@jp.fujitsu.com>
	 <20091117161711.3DDA.A69D9226@jp.fujitsu.com>
	 <20091117102903.7cb45ff3@lxorguk.ukuu.org.uk>
Date: Tue, 17 Nov 2009 19:32:36 +0900
Message-ID: <28c262360911170232i307144cnb4ddea2a5389bd8e@mail.gmail.com>
Subject: Re: [PATCH 2/7] mmc: Don't use PF_MEMALLOC
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mmc@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Nov 17, 2009 at 7:29 PM, Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
> On Tue, 17 Nov 2009 16:17:50 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
>
>> Non MM subsystem must not use PF_MEMALLOC. Memory reclaim need few
>> memory, anyone must not prevent it. Otherwise the system cause
>> mysterious hang-up and/or OOM Killer invokation.
>
> So now what happens if we are paging and all our memory is tied up for
> writeback to a device or CIFS etc which can no longer allocate the memory
> to complete the write out so the MM can reclaim ?
>
> Am I missing something or is this patch set not addressing the case where
> the writeback thread needs to inherit PF_MEMALLOC somehow (at least for
> the I/O in question and those blocking it)
>

I agree.
At least, drivers for writeout is proper for using PF_MEMALLOC, I think.


> Alan
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =C2=A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
