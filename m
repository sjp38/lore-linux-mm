Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id D154B6B0032
	for <linux-mm@kvack.org>; Mon, 19 Jan 2015 12:36:02 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id ft15so8518979pdb.11
        for <linux-mm@kvack.org>; Mon, 19 Jan 2015 09:36:02 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id cz4si17194813pdb.172.2015.01.19.09.36.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 19 Jan 2015 09:36:01 -0800 (PST)
Received: by mail-pa0-f44.google.com with SMTP id et14so40032029pad.3
        for <linux-mm@kvack.org>; Mon, 19 Jan 2015 09:36:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1421688414.2080.38.camel@HansenPartnership.com>
References: <CANP1eJF77=iH_tm1y0CgF6PwfhUK6WqU9S92d0xAnCt=WhZVfQ@mail.gmail.com>
	<20150115223157.GB25884@quack.suse.cz>
	<CANP1eJGRX4w56Ek4j7d2U+F7GNWp6RyOJonxKxTy0phUCpBM9g@mail.gmail.com>
	<20150116165506.GA10856@samba2>
	<CANP1eJEF33gndXeBJ0duP2_Bvuv-z6k7OLyuai7vjVdVKRYUWw@mail.gmail.com>
	<20150119071218.GA9747@jeremy-HP>
	<1421652849.2080.20.camel@HansenPartnership.com>
	<CANP1eJHYUprjvO1o6wfd197LM=Bmhi55YfdGQkPT0DKRn3=q6A@mail.gmail.com>
	<54BD234F.3060203@kernel.dk>
	<1421682581.2080.22.camel@HansenPartnership.com>
	<20150119164857.GC12308@jeremy-HP>
	<1421688414.2080.38.camel@HansenPartnership.com>
Date: Mon, 19 Jan 2015 09:36:00 -0800
Message-ID: <CACyXjPxVObLd7DJjkxu_Os2GADwPBvE29URUzRJN+em5H82PTQ@mail.gmail.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] async buffered diskio read for userspace apps
From: Richard Sharpe <realrichardsharpe@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@hansenpartnership.com>
Cc: Jeremy Allison <jra@samba.org>, Jens Axboe <axboe@kernel.dk>, Volker Lendecke <Volker.Lendecke@sernet.de>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Milosz Tanski <milosz@adfin.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, lsf-pc@lists.linux-foundation.org

On Mon, Jan 19, 2015 at 9:26 AM, James Bottomley
<James.Bottomley@hansenpartnership.com> wrote:
> On Mon, 2015-01-19 at 08:48 -0800, Jeremy Allison wrote:
>> On Mon, Jan 19, 2015 at 07:49:41AM -0800, James Bottomley wrote:
>> >
>> > For fio, it likely doesn't matter.  Most people download the repositor=
y
>> > and compile it themselves when building the tool. In that case, there'=
s
>> > no licence violation anyway (all GPL issues, including technical licen=
ce
>> > incompatibility, manifest on distribution not on use).  It is a proble=
m
>> > for the distributors, but they're well used to these type of self
>> > inflicted wounds.
>>
>> That's true, but it is setting a bear-trap for distributors.
>
> It's hardly a bear trap ... this type of annoyance is what they're used
> to.  Some even just ignore it on the grounds of no harm no foul.  The
> first thing they'll ask when they notice is for the protagonists to dual
> licence.
>
>> Might be better to keep the code repositories separate so at
>> lease people have a *chance* of noticing there's a problem
>> here.
>
> Actually, it might be better to *resolve* the problem before people
> notice ... if the combination is considered useful, of course.

Actually, I retract my earlier comment. The combination could be very
useful to some companies that ship Samba. I can see it being used by
field support to test whether there are performance problems either
from Windows (under cygwin) or from Linux.

That being the case, it would be useful to resolve the license issue
before it becomes an issue.

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
