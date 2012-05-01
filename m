Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 012336B0081
	for <linux-mm@kvack.org>; Tue,  1 May 2012 13:57:11 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so2922742ghr.14
        for <linux-mm@kvack.org>; Tue, 01 May 2012 10:57:11 -0700 (PDT)
MIME-Version: 1.0
Reply-To: mtk.manpages@gmail.com
In-Reply-To: <CAHGf_=qqiast+6XzGnq+LRdFXoWG9h2MkofmjS1h5OeNPRyWfw@mail.gmail.com>
References: <1335778207-6511-1-git-send-email-jack@suse.cz> <CAHGf_=qqiast+6XzGnq+LRdFXoWG9h2MkofmjS1h5OeNPRyWfw@mail.gmail.com>
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Date: Wed, 2 May 2012 05:56:50 +1200
Message-ID: <CAKgNAkjAOGM+mZLkXGiDFYsnMCpJsxx=Nd5pZfx-_f4B1jvh+A@mail.gmail.com>
Subject: Re: [PATCH] Describe race of direct read and fork for unaligned buffers
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, linux-man@vger.kernel.org, linux-mm@kvack.org, mgorman@suse.de, Jeff Moyer <jmoyer@redhat.com>

On Wed, May 2, 2012 at 4:15 AM, KOSAKI Motohiro
<kosaki.motohiro@gmail.com> wrote:
>> +suffices. However, if the user buffer is not page aligned and direct re=
ad
>
> One more thing. direct write also makes data corruption. Think
> following scenario,

In the light of all of the comments, can someone revise the man-pages
patch that Jan sent?

Thanks,

Michael


> 1) P1-T1 uses DIO write (and starting dma)
> 2) P1-T2 call fork() and makes P2
> 3) P1-T3 write to the dio target page. and then, cow break occur and
> original dio target
> =A0 =A0pages is now owned by P2.
> 4) P2 write the dio target page. It now does NOT make cow break. and
> now we break
> =A0 =A0dio target page data.
> 5) DMA transfer write invalid data to disk.
>
> The detail is described in your refer URLs.
>
>
>> +runs in parallel with a
>> +.BR fork (2)
>> +of the reader process, it may happen that the read data is split betwee=
n
>> +pages owned by the original process and its child. Thus effectively rea=
d
>> +data is corrupted.
>> =A0.LP
>> =A0The
>> =A0.B O_DIRECT



--=20
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface"; http://man7.org/tlpi/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
