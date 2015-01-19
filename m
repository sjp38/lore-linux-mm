Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 78F826B0032
	for <linux-mm@kvack.org>; Mon, 19 Jan 2015 12:18:17 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id y10so26228397pdj.13
        for <linux-mm@kvack.org>; Mon, 19 Jan 2015 09:18:17 -0800 (PST)
Received: from mail-pd0-x22e.google.com (mail-pd0-x22e.google.com. [2607:f8b0:400e:c02::22e])
        by mx.google.com with ESMTPS id kz17si1470311pab.60.2015.01.19.09.18.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 19 Jan 2015 09:18:15 -0800 (PST)
Received: by mail-pd0-f174.google.com with SMTP id ft15so8448060pdb.5
        for <linux-mm@kvack.org>; Mon, 19 Jan 2015 09:18:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150119170429.GA13160@jeremy-HP>
References: <CANP1eJF77=iH_tm1y0CgF6PwfhUK6WqU9S92d0xAnCt=WhZVfQ@mail.gmail.com>
	<20150115223157.GB25884@quack.suse.cz>
	<CANP1eJGRX4w56Ek4j7d2U+F7GNWp6RyOJonxKxTy0phUCpBM9g@mail.gmail.com>
	<20150116165506.GA10856@samba2>
	<CANP1eJEF33gndXeBJ0duP2_Bvuv-z6k7OLyuai7vjVdVKRYUWw@mail.gmail.com>
	<20150119071218.GA9747@jeremy-HP>
	<1421652849.2080.20.camel@HansenPartnership.com>
	<CANP1eJHYUprjvO1o6wfd197LM=Bmhi55YfdGQkPT0DKRn3=q6A@mail.gmail.com>
	<20150119170429.GA13160@jeremy-HP>
Date: Mon, 19 Jan 2015 09:18:14 -0800
Message-ID: <CACyXjPzTE0FHt5B5HL1DOLrTWqFqy_rgbFRXd1k88m8zPunbPw@mail.gmail.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] async buffered diskio read for userspace apps
From: Richard Sharpe <realrichardsharpe@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeremy Allison <jra@samba.org>
Cc: Milosz Tanski <milosz@adfin.com>, James Bottomley <James.Bottomley@hansenpartnership.com>, Jens Axboe <axboe@kernel.dk>, Volker Lendecke <Volker.Lendecke@sernet.de>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, lsf-pc@lists.linux-foundation.org

On Mon, Jan 19, 2015 at 9:04 AM, Jeremy Allison <jra@samba.org> wrote:
> On Mon, Jan 19, 2015 at 2:34 AM, James Bottomley
> <James.Bottomley@hansenpartnership.com> wrote:
>>
>> That's one of these pointless licensing complexities that annoy
>> distributions so much ... they're both open source, so there's no real
>> problem except the licence incompatibility. The usual way out of it is
>> just to dual licence the incompatible component.
>
> Just one point here - we're not able to dual license
> Samba to go back to GPLv2 anything. There are too many
> contributors to this who have contributed under v3-or-later
> licensing in order for this to be possible for us.
>
> I'm hoping adding the 'or-later' clause to fio might
> be easier.

As someone who has worked for companies that distribute Samba for
quite a while I cannot see us distributing fio. Rather, we would use
it as a performance testing tool.

That being the case, the license differences are not a problem.

Am I missing something here?

--=20
Regards,
Richard Sharpe
(=E4=BD=95=E4=BB=A5=E8=A7=A3=E6=86=82=EF=BC=9F=E5=94=AF=E6=9C=89=E6=9D=9C=
=E5=BA=B7=E3=80=82--=E6=9B=B9=E6=93=8D)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
