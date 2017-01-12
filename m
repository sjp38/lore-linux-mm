Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 25EC86B0033
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 11:34:20 -0500 (EST)
Received: by mail-vk0-f71.google.com with SMTP id t8so13266996vke.3
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 08:34:20 -0800 (PST)
Received: from mail-vk0-x22c.google.com (mail-vk0-x22c.google.com. [2607:f8b0:400c:c05::22c])
        by mx.google.com with ESMTPS id 90si2626523uan.187.2017.01.12.08.34.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jan 2017 08:34:19 -0800 (PST)
Received: by mail-vk0-x22c.google.com with SMTP id x75so15944364vke.2
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 08:34:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170111173802.GK16365@dhcp22.suse.cz>
References: <CAPJVTTimt2CeiiX868+EY2HbbWmKsG05u7QOBbuTb74f-ZrpPQ@mail.gmail.com>
 <20170111173802.GK16365@dhcp22.suse.cz>
From: Cheng-yu Lee <cylee@google.com>
Date: Fri, 13 Jan 2017 00:34:18 +0800
Message-ID: <CAPJVTTgf=gDHQr7iF1+NQtEer_dGAH2Bw0e1rKnNz9Enj7Fnaw@mail.gmail.com>
Subject: Re: shrink_inactive_list() failed to reclaim pages
Content-Type: multipart/alternative; boundary=001a114d6606f3c5fd0545e849ce
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Luigi Semenzato <semenzato@google.com>, Ben Cheng <bccheng@google.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Minchan Kim <minchan@kernel.org>

--001a114d6606f3c5fd0545e849ce
Content-Type: text/plain; charset=UTF-8

>
> > I have a x86_64 Chromebook running 3.14 kernel with 8G of memory. Using
>
> Do you see the same with the current Linus tree?
>

I haven't tried on ToT because it takes much effort to port to the specific
device.
But I've managed to try it on v4.4 .
Surprisingly the problem goes away.



> > Thus the kernel fails to reclaim those pages at line 1209
> > http://lxr.free-electrons.com/source/mm/vmscan.c#L1209
>
> I assume that you are talking about the anonymous LRU
>

Yes, I mean anonymous LRU.

--001a114d6606f3c5fd0545e849ce
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra"><div class=3D"gmail_quote"><blo=
ckquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #c=
cc solid;padding-left:1ex"><span class=3D"">&gt; I have a x86_64 Chromebook=
 running 3.14 kernel with 8G of memory. Using<br>
<br>
</span>Do you see the same with the current Linus tree?<br></blockquote><di=
v><br></div><div>I haven&#39;t tried on ToT because it takes much effort to=
 port to the specific device.</div><div>But I&#39;ve managed to try it on v=
4.4 .=C2=A0</div><div>Surprisingly the problem goes away.</div><div><br></d=
iv><div>=C2=A0</div><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0=
 .8ex;border-left:1px #ccc solid;padding-left:1ex"><span class=3D"">
&gt; Thus the kernel fails to reclaim those pages at line 1209<br>
&gt; <a href=3D"http://lxr.free-electrons.com/source/mm/vmscan.c#L1209" rel=
=3D"noreferrer" target=3D"_blank">http://lxr.free-electrons.com/<wbr>source=
/mm/vmscan.c#L1209</a><br>
<br>
</span>I assume that you are talking about the anonymous LRU<br></blockquot=
e><div><br></div><div>Yes, I mean anonymous LRU.</div></div></div></div>

--001a114d6606f3c5fd0545e849ce--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
