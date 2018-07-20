Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 198546B0269
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 18:03:41 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id d1-v6so6264216wrr.4
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 15:03:41 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id h132-v6sor582582wmd.12.2018.07.20.15.03.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Jul 2018 15:03:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180716164500.GZ17280@dhcp22.suse.cz>
References: <CADF2uSrW=Z=7NeA4qRwStoARGeT1y33QSP48Loc1u8XSdpMJOA@mail.gmail.com>
 <20180712113411.GB328@dhcp22.suse.cz> <CADF2uSqDDt3X_LHEQnc5xzHpqJ66E5gncogwR45bmZsNHxV55A@mail.gmail.com>
 <CADF2uSr-uFz+AAhcwP7ORgGgtLohayBtpDLxx9kcADDxaW8hWw@mail.gmail.com>
 <20180716162337.GY17280@dhcp22.suse.cz> <CADF2uSpEZTqD7pUp1t77GNTT+L=M3Ycir2+gsZg3kf5=y-5_-Q@mail.gmail.com>
 <20180716164500.GZ17280@dhcp22.suse.cz>
From: Marinko Catovic <marinko.catovic@gmail.com>
Date: Sat, 21 Jul 2018 00:03:38 +0200
Message-ID: <CADF2uSpkOqCU5hO9y4708TvpJ5JvkXjZ-M1o+FJr2v16AZP3Vw@mail.gmail.com>
Subject: Re: Caching/buffers become useless after some time
Content-Type: multipart/alternative; boundary="000000000000d1ee2f0571757731"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

--000000000000d1ee2f0571757731
Content-Type: text/plain; charset="UTF-8"

I let this run for 3 days now, so it is quite a lot, there you go:
https://nofile.io/f/egGyRjf0NPs/vmstat.tar.gz

There is one thing I forgot to mention: the hosts perform find and du (I
mean the commands, finding files and disk usage)
on the HDDs every night, starting from 00:20 AM up until in the morning
07:45 AM, for maintenance and stats.

During this period the buffers/caches raise again as you may see from the
logs, so find/du do fill them.
Nevertheless as the day passes both decrease again until low values are
reached.
I disabled find/du for the night on 19->20th July to compare.

I have to say that this really low usage (300MB/xGB) occured just once
after I upgraded from 4.16 to 4.17, not sure
why, where one can still see from the logs that the buffers/cache is not
using up the entire available RAM.

This low usage occured the last time on that one host when I mentioned that
I had to 2>drop_caches again in my
previous message, so this is still an issue even on the latest kernel.

The other host (the one that was not measured with the vmstat logs) has
currently 600MB/14GB, 34GB of free RAM.
Both were reset with drop_caches at the same time. From the looks of this
the really low usage will occur again
somewhat shortly, it just did not come up during measurement. However, the
RAM should be full anyway, true?





2018-07-16 18:45 GMT+02:00 Michal Hocko <mhocko@kernel.org>:

> On Mon 16-07-18 18:33:57, Marinko Catovic wrote:
> > how periodically do you want them? I assumed this some-hours and days
> > snapshots would be sufficient.
>
> Every 10s should be reasonable even for a long term monitoring.
>
> > any particular command with or without grep perhaps?
>
> while true
> do
>         cp /proc/vmstat vmstat.$(date +%s)
>         sleep 10s
> done
> --
> Michal Hocko
> SUSE Labs
>

--000000000000d1ee2f0571757731
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>I let this run for 3 days now, so it is quite a lot, =
there you go: <a href=3D"https://nofile.io/f/egGyRjf0NPs/vmstat.tar.gz">htt=
ps://nofile.io/f/egGyRjf0NPs/vmstat.tar.gz</a></div><div><br></div><div>The=
re is one thing I forgot to mention: the hosts perform find and du (I mean =
the commands, finding files and disk usage)</div><div>on the HDDs every nig=
ht, starting from 00:20 AM up until in the morning 07:45 AM, for maintenanc=
e and stats.</div><div><br></div><div>During this period the buffers/caches=
 raise again as you may see from the logs, so find/du do fill them.</div><d=
iv>Nevertheless as the day passes both decrease again until low values are =
reached.</div><div>I disabled find/du for the night on 19-&gt;20th July to =
compare.<br></div><div><br></div><div>I have to say that this really low us=
age (300MB/xGB) occured just once after I upgraded from 4.16 to 4.17, not s=
ure</div><div>why, where one can still see from the logs that the buffers/c=
ache is not using up the entire available RAM.</div><div><br></div><div>Thi=
s low usage occured the last time on that one host when I mentioned that I =
had to 2&gt;drop_caches again in my</div><div>previous message, so this is =
still an issue even on the latest kernel.</div><div><br></div><div>The othe=
r host (the one that was not measured with the vmstat logs) has currently 6=
00MB/14GB, 34GB of free RAM.</div><div>Both were reset with drop_caches at =
the same time. From the looks of this the really low usage will occur again=
</div><div>somewhat shortly, it just did not come up during measurement. Ho=
wever, the RAM should be full anyway, true?</div><div><br></div><div><br></=
div><div><br></div><div><br></div><div class=3D"gmail_extra"><br><div class=
=3D"gmail_quote">2018-07-16 18:45 GMT+02:00 Michal Hocko <span dir=3D"ltr">=
&lt;<a href=3D"mailto:mhocko@kernel.org" target=3D"_blank">mhocko@kernel.or=
g</a>&gt;</span>:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 =
0 .8ex;border-left:1px #ccc solid;padding-left:1ex"><span class=3D"">On Mon=
 16-07-18 18:33:57, Marinko Catovic wrote:<br>
&gt; how periodically do you want them? I assumed this some-hours and days<=
br>
&gt; snapshots would be sufficient.<br>
<br>
</span>Every 10s should be reasonable even for a long term monitoring.<br>
<span class=3D""><br>
&gt; any particular command with or without grep perhaps?<br>
<br>
</span>while true<br>
do<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 cp /proc/vmstat vmstat.$(date +%s)<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 sleep 10s<br>
done<br>
<div class=3D"HOEnZb"><div class=3D"h5">-- <br>
Michal Hocko<br>
SUSE Labs<br>
</div></div></blockquote></div><br></div></div>

--000000000000d1ee2f0571757731--
