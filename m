Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3A51B6B0082
	for <linux-mm@kvack.org>; Mon, 18 Jul 2011 19:32:05 -0400 (EDT)
Received: by qwa26 with SMTP id 26so2519406qwa.14
        for <linux-mm@kvack.org>; Mon, 18 Jul 2011 16:32:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110718161819.506fe97c.akpm@linux-foundation.org>
References: <CAGtzr3fm2=UJFRo2xSYhst0P4jCMT-EPjyPi3=icCrMtW0ij8w@mail.gmail.com>
	<CAEwNFnB8VXkTiMzJewtd7rSZ8keqkboNz-BBjw_UudquvsrK1A@mail.gmail.com>
	<alpine.DEB.2.00.1107081021040.29346@ubuntu>
	<CAEwNFnCsjRkauM5XvOqh1hLNOT3Hwu2m9pPqO+mCHq7rKLu0Gg@mail.gmail.com>
	<alpine.DEB.2.00.1107111550430.29346@ubuntu>
	<CAEwNFnCfsGn1qZbgXNNETFtZAzOSvxpJDcftNcuuSBDXUnxtmA@mail.gmail.com>
	<alpine.DEB.2.00.1107142044110.29346@ubuntu>
	<CAEwNFnDwjWDF7Z4AUZg9rAHN6=n9nZ5tZe5U8USn7TpVCNsM6A@mail.gmail.com>
	<20110718161819.506fe97c.akpm@linux-foundation.org>
Date: Tue, 19 Jul 2011 08:32:02 +0900
Message-ID: <CAEwNFnBCOc=FBbAb3kbnLvv=n_+cmo_LwRAN5YG5HrSQs2oCZA@mail.gmail.com>
Subject: Re: NULL poniter dereference in isolate_lru_pages 2.6.39.1
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Chris Pearson <pearson.christopher.j@gmail.com>, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, stable <stable@kernel.org>

On Tue, Jul 19, 2011 at 8:18 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Tue, 19 Jul 2011 07:48:11 +0900 Minchan Kim <minchan.kim@gmail.com> wr=
ote:
>
>> Thanks for the test, Chris.
>> Andrew.
>> We should push this into -stable.
>
> That's
>
> commit d179e84ba5da1d0024087d1759a2938817a00f3f
> Author: =C2=A0 =C2=A0 Andrea Arcangeli <aarcange@redhat.com>
> AuthorDate: Wed Jun 15 15:08:51 2011 -0700
> Commit: =C2=A0 =C2=A0 Linus Torvalds <torvalds@linux-foundation.org>
> CommitDate: Wed Jun 15 20:04:02 2011 -0700
>
> =C2=A0 =C2=A0mm: vmscan: do not use page_count without a page pin
>

Yeb!


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
