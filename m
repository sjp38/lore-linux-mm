Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 8DA6D6B13F1
	for <linux-mm@kvack.org>; Tue, 31 Jan 2012 12:17:06 -0500 (EST)
Received: by ggnu2 with SMTP id u2so223823ggn.14
        for <linux-mm@kvack.org>; Tue, 31 Jan 2012 09:17:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <op.v8wlzbc53l0zgt@mpn-glaptop>
References: <1327568457-27734-1-git-send-email-m.szyprowski@samsung.com>
	<201201261531.40551.arnd@arndb.de>
	<20120127162624.40cba14e.akpm@linux-foundation.org>
	<20120130132512.GO25268@csn.ul.ie>
	<op.v8wlzbc53l0zgt@mpn-glaptop>
Date: Tue, 31 Jan 2012 18:17:05 +0100
Message-ID: <CA+M3ks7h1t6DbPSAhPN6LJ5Dw84hSukfWG16avh2eZL+o4caJg@mail.gmail.com>
Subject: Re: [PATCHv19 00/15] Contiguous Memory Allocator
From: Benjamin Gaignard <benjamin.gaignard@linaro.org>
Content-Type: multipart/alternative; boundary=e89a8f3ba6b1d587c304b7d62100
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>

--e89a8f3ba6b1d587c304b7d62100
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hi Marek,

I have rebase Linaro CMA test driver to be compatible with CMA v19, it now
use dma-mapping API instead of v17 CMA API.
A kernel for snowball with CMA v19 and test driver is available here:
http://git.linaro.org/gitweb?p=3Dpeople/bgaignard/linux-snowball-test-cma-v=
19.git;a=3Dsummary

>From this kernel build, I have execute CMA lava (the linaro automatic test
tool) test, the same than we are running since v16, the test is OK.
With previous versions of CMA some the test has found issues when the
memory was filled with reclaimables pages, but with v19 this issue is no
more present.
Test logs are here:
https://validation.linaro.org/lava-server/scheduler/job/10841

so you can add:
Tested-by: Benjamin Gaignard <benjamin.gaignard@linaro.org>

Regards,
Benjamin

Benjamin Gaignard

Multimedia Working Group

Linaro.org <http://www.linaro.org/>* **=E2=94=82 *Open source software for =
ARM SoCs

**

Follow *Linaro: *Facebook <http://www.facebook.com/pages/Linaro> |
Twitter<http://twitter.com/#!/linaroorg>
 | Blog <http://www.linaro.org/linaro-blog/>

--e89a8f3ba6b1d587c304b7d62100
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hi Marek,<div><br></div><div>I have rebase Linaro CMA test driver to be com=
patible with CMA v19, it now use dma-mapping API instead of v17 CMA API.<br=
>A kernel for snowball with CMA v19 and test driver is available here:=C2=
=A0</div>
<div><a href=3D"http://git.linaro.org/gitweb?p=3Dpeople/bgaignard/linux-sno=
wball-test-cma-v19.git;a=3Dsummary">http://git.linaro.org/gitweb?p=3Dpeople=
/bgaignard/linux-snowball-test-cma-v19.git;a=3Dsummary</a></div><div><br></=
div><div>
>From this kernel build, I have execute CMA lava (the linaro automatic test =
tool) test, the same than we are running since v16, the test is OK.</div><d=
iv>With previous versions of CMA some the test has found issues when the me=
mory was filled with reclaimables pages, but with v19 this issue is no more=
 present.</div>
<div>Test logs are here: =C2=A0<a href=3D"https://validation.linaro.org/lav=
a-server/scheduler/job/10841">https://validation.linaro.org/lava-server/sch=
eduler/job/10841</a></div><div><br></div><meta http-equiv=3D"content-type" =
content=3D"text/html; charset=3Dutf-8"><div>
so you can add:</div><div>Tested-by: Benjamin Gaignard &lt;<a href=3D"mailt=
o:benjamin.gaignard@linaro.org">benjamin.gaignard@linaro.org</a>&gt;</div><=
div><br><div class=3D"gmail_quote">Regards,</div><div class=3D"gmail_quote"=
>Benjamin</div>
<div class=3D"gmail_quote"><br></div><span style=3D"border-collapse:collaps=
e;font-family:arial,sans-serif;font-size:13px"><p style=3D"margin-top:0px;m=
argin-right:0px;margin-bottom:0px;margin-left:0px">Benjamin Gaignard=C2=A0<=
/p><p style=3D"margin-top:0px;margin-right:0px;margin-bottom:0px;margin-lef=
t:0px">
Multimedia Working Group</p><p style=3D"margin-top:0px;margin-right:0px;mar=
gin-bottom:0px;margin-left:0px"><span lang=3D"EN-US" style=3D"font-size:10p=
t;color:rgb(0,176,80)"><span style=3D"color:rgb(0,68,252)"><a href=3D"http:=
//www.linaro.org/" style=3D"color:rgb(0,0,204)" target=3D"_blank">Linaro.or=
g</a></span><b>=C2=A0</b></span><b><span lang=3D"EN-US" style=3D"font-size:=
10pt">=E2=94=82=C2=A0</span></b><span lang=3D"EN-US" style=3D"font-size:10p=
t">Open source software for ARM SoCs</span></p>
<p style=3D"margin-top:0px;margin-right:0px;margin-bottom:0px;margin-left:0=
px"><u></u></p><p style=3D"margin-top:0px;margin-right:0px;margin-bottom:0p=
x;margin-left:0px"><span lang=3D"EN-US" style=3D"font-size:10pt">Follow=C2=
=A0<b>Linaro:=C2=A0</b></span><span style=3D"font-size:10pt;color:rgb(0,68,=
252)"><a href=3D"http://www.facebook.com/pages/Linaro" style=3D"color:rgb(0=
,0,204)" target=3D"_blank"><span style=3D"color:blue">Facebook</span></a></=
span><span style=3D"font-size:10pt">=C2=A0|=C2=A0<span style=3D"color:rgb(0=
,68,252)"><a href=3D"http://twitter.com/#!/linaroorg" style=3D"color:rgb(0,=
0,204)" target=3D"_blank"><span style=3D"color:blue">Twitter</span></a></sp=
an>=C2=A0|=C2=A0<span style=3D"color:rgb(0,68,252)"><a href=3D"http://www.l=
inaro.org/linaro-blog/" style=3D"color:rgb(0,0,204)" target=3D"_blank"><spa=
n style=3D"color:blue">Blog</span></a></span></span></p>
</span><br>
</div>

--e89a8f3ba6b1d587c304b7d62100--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
