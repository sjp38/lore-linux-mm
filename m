Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f200.google.com (mail-ob0-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id B4AEB6B0253
	for <linux-mm@kvack.org>; Sat,  9 Jul 2016 12:18:13 -0400 (EDT)
Received: by mail-ob0-f200.google.com with SMTP id d2so49081835obp.1
        for <linux-mm@kvack.org>; Sat, 09 Jul 2016 09:18:13 -0700 (PDT)
Received: from mail-oi0-x229.google.com (mail-oi0-x229.google.com. [2607:f8b0:4003:c06::229])
        by mx.google.com with ESMTPS id j21si1397988oib.246.2016.07.09.09.18.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Jul 2016 09:18:12 -0700 (PDT)
Received: by mail-oi0-x229.google.com with SMTP id r2so97332379oih.2
        for <linux-mm@kvack.org>; Sat, 09 Jul 2016 09:18:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201607091726.eUyprWPm%fengguang.wu@intel.com>
References: <6114f72a15d5e52984ea546ba977737221351636.1468051282.git.janani.rvchndrn@gmail.com>
 <201607091726.eUyprWPm%fengguang.wu@intel.com>
From: Janani Ravichandran <janani.rvchndrn@gmail.com>
Date: Sat, 9 Jul 2016 21:48:12 +0530
Message-ID: <CANnt6X=d2MHixU_iFKPYCMiU0xSHrQeUyVkOfHAX+kWbefEfsg@mail.gmail.com>
Subject: Re: [PATCH 3/3] Add name fields in shrinker tracepoint definitions
Content-Type: multipart/alternative; boundary=001a113521ba07cca3053736443d
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@surriel.com>, akpm@linux-foundation.org, Johannes Weiner <hannes@cmpxchg.org>, vdavydov@virtuozzo.com, mhocko@suse.com, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, bywxiaobai@163.com

--001a113521ba07cca3053736443d
Content-Type: text/plain; charset=UTF-8

On Sat, Jul 9, 2016 at 3:15 PM, kbuild test robot <lkp@intel.com> wrote:

> Hi,
>
> [auto build test WARNING on staging/staging-testing]
> [also build test WARNING on v4.7-rc6 next-20160708]
> [if your patch is applied to the wrong git tree, please drop us a note to
> help improve the system]
>
> url:
> https://github.com/0day-ci/linux/commits/Janani-Ravichandran/Add-names-of-shrinkers-and-have-tracepoints-display-them/20160709-170759
> config: i386-defconfig (attached as .config)
> compiler: gcc-6 (Debian 6.1.1-1) 6.1.1 20160430
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=i386
>
> All warnings (new ones prefixed by >>):
>
>    In file included from include/trace/define_trace.h:95:0,
>                     from include/trace/events/vmscan.h:395,
>                     from mm/vmscan.c:60:
>    include/trace/events/vmscan.h: In function
> 'trace_event_raw_event_mm_shrink_slab_start':
> >> include/trace/events/vmscan.h:206:17: warning: assignment discards
> 'const' qualifier from pointer target type [-Wdiscarded-qualifiers]
>       __entry->name = shr->name;
>


These warnings will be fixed and also, the missing signed-off by line will
be
added in v2 after hearing comments from other developers.

Janani.

>
>

--001a113521ba07cca3053736443d
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><div class=3D"gmail_extra"><br><div class=3D"gmail_quo=
te">On Sat, Jul 9, 2016 at 3:15 PM, kbuild test robot <span dir=3D"ltr">&lt=
;<a href=3D"mailto:lkp@intel.com" target=3D"_blank">lkp@intel.com</a>&gt;</=
span> wrote:<br><blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8e=
x;border-left:1px #ccc solid;padding-left:1ex">Hi,<br>
<br>
[auto build test WARNING on staging/staging-testing]<br>
[also build test WARNING on v4.7-rc6 next-20160708]<br>
[if your patch is applied to the wrong git tree, please drop us a note to h=
elp improve the system]<br>
<br>
url:=C2=A0 =C2=A0 <a href=3D"https://github.com/0day-ci/linux/commits/Janan=
i-Ravichandran/Add-names-of-shrinkers-and-have-tracepoints-display-them/201=
60709-170759" rel=3D"noreferrer" target=3D"_blank">https://github.com/0day-=
ci/linux/commits/Janani-Ravichandran/Add-names-of-shrinkers-and-have-tracep=
oints-display-them/20160709-170759</a><br>
config: i386-defconfig (attached as .config)<br>
compiler: gcc-6 (Debian 6.1.1-1) 6.1.1 20160430<br>
reproduce:<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 # save the attached .config to linux build tree=
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 make ARCH=3Di386<br>
<br>
All warnings (new ones prefixed by &gt;&gt;):<br>
<br>
=C2=A0 =C2=A0In file included from include/trace/define_trace.h:95:0,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 from =
include/trace/events/vmscan.h:395,<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 from =
mm/vmscan.c:60:<br>
=C2=A0 =C2=A0include/trace/events/vmscan.h: In function &#39;trace_event_ra=
w_event_mm_shrink_slab_start&#39;:<br>
&gt;&gt; include/trace/events/vmscan.h:206:17: warning: assignment discards=
 &#39;const&#39; qualifier from pointer target type [-Wdiscarded-qualifiers=
]<br>
<span class=3D"">=C2=A0 =C2=A0 =C2=A0 __entry-&gt;name =3D shr-&gt;name;<br=
>
</span>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 </blockquote><div><br></di=
v><div>These warnings will be fixed and also, the missing signed-off by lin=
e will be=C2=A0</div><div>added in v2 after hearing comments from other dev=
elopers.</div><div><br></div><div>Janani.=C2=A0</div><blockquote class=3D"g=
mail_quote" style=3D"margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-l=
eft:1ex"><br></blockquote></div><br></div></div>

--001a113521ba07cca3053736443d--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
