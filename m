Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id C3C9B6B000E
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 08:12:38 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id n188so8679483vkc.1
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 05:12:38 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f143sor1228719vkd.218.2018.04.10.05.12.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 10 Apr 2018 05:12:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180409181400.GO21835@dhcp22.suse.cz>
References: <20180405142749.GL6312@dhcp22.suse.cz> <20180405151359.GB28128@bombadil.infradead.org>
 <20180405153240.GO6312@dhcp22.suse.cz> <20180405161501.GD28128@bombadil.infradead.org>
 <20180405185444.GQ6312@dhcp22.suse.cz> <20180405201557.GA3666@bombadil.infradead.org>
 <20180406060953.GA8286@dhcp22.suse.cz> <20180408042709.GC32632@bombadil.infradead.org>
 <20180409073407.GD21835@dhcp22.suse.cz> <20180409155157.GC11756@bombadil.infradead.org>
 <20180409181400.GO21835@dhcp22.suse.cz>
From: =?UTF-8?B?0JTQvNC40YLRgNC40Lkg0JvQtdC+0L3RgtGM0LXQsg==?= <dm.leontiev7@gmail.com>
Date: Tue, 10 Apr 2018 15:12:37 +0300
Message-ID: <CA+JonM0HG9kWb6-0iyDQ8UMxTeR-f=+ZL89t5DvvDULDC8Sfyw@mail.gmail.com>
Subject: Re: __GFP_LOW
Content-Type: multipart/alternative; boundary="001a11440c5c2e69ba05697d7044"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

--001a11440c5c2e69ba05697d7044
Content-Type: text/plain; charset="UTF-8"

Hello

I'm not an expert in Linux, but something made me think something is broken
in linux in this discussion.

First, I've noticed the network drivers were allocating memory in interrupt
handlers. That sounds strange to me, because as far as I know, this
behaviour is discouraged and may lead to DDOS attack.

> As I understand it, kswapd
> was originally introduced because networking might do many allocations
> from interrupt context, and so was unable to do its own reclaiming

Maybe this weird behaviour should be fixed instead of fixing memory
allocator? Networking must not allocate anything, it must drop packets it
cant handle at the moment. Sorry, we totally screwed up, shit happened,
aliens are attacking, blahblahblah, but we won't allocate a byte for you.

--001a11440c5c2e69ba05697d7044
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div><div><div><div><div>Hello<br><br></div>I&#39;m not an=
 expert in Linux, but something made me think something is broken in linux =
in this discussion.<br><br></div>First,
 I&#39;ve noticed the network drivers were allocating memory in interrupt=
=20
handlers. That sounds strange to me, because as far as I know, this=20
behaviour is discouraged and may lead to DDOS attack.<br><br>&gt; As I unde=
rstand it, kswapd<br>
&gt; was originally introduced because networking might do many allocations=
<br>
&gt; from interrupt context, and so was unable to do its own reclaiming<br>=
<br></div>Maybe this weird behaviour should be fixed instead of fixing memo=
ry allocator? Networking must not allocate anything, it must drop packets i=
t cant handle at the moment. Sorry, we totally screwed up, shit happened, a=
liens are attacking, blahblahblah, but we won&#39;t allocate a byte for you=
. <br></div></div><br><br></div>

--001a11440c5c2e69ba05697d7044--
