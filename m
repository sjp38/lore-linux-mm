Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C69A96B0003
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 12:33:59 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id c20-v6so3450488wmb.9
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 09:33:59 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id g10-v6sor2338124wrc.41.2018.07.16.09.33.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Jul 2018 09:33:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180716162337.GY17280@dhcp22.suse.cz>
References: <CADF2uSrW=Z=7NeA4qRwStoARGeT1y33QSP48Loc1u8XSdpMJOA@mail.gmail.com>
 <20180712113411.GB328@dhcp22.suse.cz> <CADF2uSqDDt3X_LHEQnc5xzHpqJ66E5gncogwR45bmZsNHxV55A@mail.gmail.com>
 <CADF2uSr-uFz+AAhcwP7ORgGgtLohayBtpDLxx9kcADDxaW8hWw@mail.gmail.com> <20180716162337.GY17280@dhcp22.suse.cz>
From: Marinko Catovic <marinko.catovic@gmail.com>
Date: Mon, 16 Jul 2018 18:33:57 +0200
Message-ID: <CADF2uSpEZTqD7pUp1t77GNTT+L=M3Ycir2+gsZg3kf5=y-5_-Q@mail.gmail.com>
Subject: Re: Caching/buffers become useless after some time
Content-Type: multipart/alternative; boundary="0000000000006864fb0571206524"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

--0000000000006864fb0571206524
Content-Type: text/plain; charset="UTF-8"

how periodically do you want them? I assumed this some-hours and days
snapshots would be sufficient.
any particular command with or without grep perhaps?

I just had to drop caches, right before your response, the performance was
simply too bad.

this is for your information, how it was right after dropping and 0+5+25
minutes later

https://pastebin.com/LcjKgQkg .. this is what it looks like just after
sync; echo 2 > /proc/sys/vm/drop_caches
https://pastebin.com/ZCeFCKrb .. 5 minutes later, when performance is
starting to get better again
https://pastebin.com/8hij8Lid .. 20 minutes after that, you can expect this
to consume all the available ram within 1-2 hours


2018-07-16 18:23 GMT+02:00 Michal Hocko <mhocko@kernel.org>:

> On Mon 16-07-18 17:53:42, Marinko Catovic wrote:
> > I can provide further data now, monitoring vmstat:
> >
> > https://pastebin.com/j0dMGBe4 .. 1 day later, 600MB/13GB in use, 35GB
> free
> > https://pastebin.com/N011kYyd .. 1 day later, 300MB/10GB in use, 40GB
> free,
> > performance becomes even worse
> >
> > the issue raises up again, I would have to drop caches by now to restore
> > normal usage for another day or two.
> >
> > Afaik there should be no reason at all to not have the buffers/cache fill
> > up the entire memory, isn't that true?
> > There is to my knowledge almost no O_DIRECT involved, also as mentioned
> > before: when dropping caches
> > the buffers/cache usage would eat up all RAM within the hour as usual for
> > 1-2 days until it starts to go crazy again.
> >
> > As mentioned, the usage oscillates up and down instead of up until all
> RAM
> > is consumed.
> >
> > Please tell me if there is anything else I can do to help investigate
> this.
>
> Do you have periodic /proc/vmstat snapshots I have asked before?
> --
> Michal Hocko
> SUSE Labs
>

--0000000000006864fb0571206524
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>how periodically do you want them? I assumed this som=
e-hours and days snapshots would be sufficient.</div><div></div><div>any pa=
rticular command with or without grep perhaps?<br></div><div class=3D"gmail=
_extra"><br></div><div class=3D"gmail_extra">I just had to drop caches, rig=
ht before your response, the performance was simply too bad.</div><div clas=
s=3D"gmail_extra"><br></div><div>this is for your information, how it was r=
ight after dropping and 0+5+25 minutes later</div><div><br></div><div><a hr=
ef=3D"https://pastebin.com/LcjKgQkg">https://pastebin.com/LcjKgQkg</a> .. t=
his is what it looks like just after sync; echo 2 &gt; /proc/sys/vm/drop_ca=
ches<br><a href=3D"https://pastebin.com/ZCeFCKrb">https://pastebin.com/ZCeF=
CKrb</a> .. 5 minutes later, when performance is starting to get better aga=
in</div><div><a href=3D"https://pastebin.com/8hij8Lid">https://pastebin.com=
/8hij8Lid</a> .. 20 minutes after that, you can expect this to consume all =
the available ram within 1-2 hours<br><br></div><div><div class=3D"gmail_ex=
tra"><br><div class=3D"gmail_quote">2018-07-16 18:23 GMT+02:00 Michal Hocko=
 <span dir=3D"ltr">&lt;<a href=3D"mailto:mhocko@kernel.org" target=3D"_blan=
k">mhocko@kernel.org</a>&gt;</span>:<br><blockquote class=3D"gmail_quote" s=
tyle=3D"margin:0px 0px 0px 0.8ex;border-left:1px solid rgb(204,204,204);pad=
ding-left:1ex"><span class=3D"gmail-">On Mon 16-07-18 17:53:42, Marinko Cat=
ovic wrote:<br>
&gt; I can provide further data now, monitoring vmstat:<br>
&gt; <br>
&gt; <a href=3D"https://pastebin.com/j0dMGBe4" rel=3D"noreferrer" target=3D=
"_blank">https://pastebin.com/j0dMGBe4</a> .. 1 day later, 600MB/13GB in us=
e, 35GB free<br>
&gt; <a href=3D"https://pastebin.com/N011kYyd" rel=3D"noreferrer" target=3D=
"_blank">https://pastebin.com/N011kYyd</a> .. 1 day later, 300MB/10GB in us=
e, 40GB free,<br>
&gt; performance becomes even worse<br>
&gt; <br>
&gt; the issue raises up again, I would have to drop caches by now to resto=
re<br>
&gt; normal usage for another day or two.<br>
&gt; <br>
&gt; Afaik there should be no reason at all to not have the buffers/cache f=
ill<br>
&gt; up the entire memory, isn&#39;t that true?<br>
&gt; There is to my knowledge almost no O_DIRECT involved, also as mentione=
d<br>
&gt; before: when dropping caches<br>
&gt; the buffers/cache usage would eat up all RAM within the hour as usual =
for<br>
&gt; 1-2 days until it starts to go crazy again.<br>
&gt; <br>
&gt; As mentioned, the usage oscillates up and down instead of up until all=
 RAM<br>
&gt; is consumed.<br>
&gt; <br>
&gt; Please tell me if there is anything else I can do to help investigate =
this.<br>
<br>
</span>Do you have periodic /proc/vmstat snapshots I have asked before?<br>
<div class=3D"gmail-HOEnZb"><div class=3D"gmail-h5">-- <br>
Michal Hocko<br>
SUSE Labs<br>
</div></div></blockquote></div><br></div></div></div>

--0000000000006864fb0571206524--
