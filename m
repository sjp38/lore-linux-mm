Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id C91726B0003
	for <linux-mm@kvack.org>; Fri, 18 Dec 2015 01:59:10 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id q3so35683625pav.3
        for <linux-mm@kvack.org>; Thu, 17 Dec 2015 22:59:10 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id 6si17969691pfh.141.2015.12.17.22.59.09
        for <linux-mm@kvack.org>;
        Thu, 17 Dec 2015 22:59:09 -0800 (PST)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH v3 2/2] mm: Introduce kernelcore=mirror option
Date: Fri, 18 Dec 2015 06:59:08 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F39F88DAC@ORSMSX114.amr.corp.intel.com>
References: <1449631109-14756-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <1449631177-14863-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <56679FDC.1080800@huawei.com>
 <3908561D78D1C84285E8C5FCA982C28F39F7F4CD@ORSMSX114.amr.corp.intel.com>
 <5668D1FA.4050108@huawei.com>
 <E86EADE93E2D054CBCD4E708C38D364A54299720@G01JPEXMBYT01>
 <56691819.3040105@huawei.com>
 <E86EADE93E2D054CBCD4E708C38D364A54299AA4@G01JPEXMBYT01>
 <566A9AE1.7020001@huawei.com>
 <E86EADE93E2D054CBCD4E708C38D364A5429B2DE@G01JPEXMBYT01>
 <56722258.6030800@huawei.com> <567223A7.9090407@jp.fujitsu.com>
 <56723E8B.8050201@huawei.com> <567241BE.5030806@jp.fujitsu.com>
 <3908561D78D1C84285E8C5FCA982C28F39F882E8@ORSMSX114.amr.corp.intel.com>
 <56736B7D.3040709@jp.fujitsu.com>
In-Reply-To: <56736B7D.3040709@jp.fujitsu.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Xishi Qiu <qiuxishi@huawei.com>
Cc: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "Hansen, Dave" <dave.hansen@intel.com>, "matt@codeblueprint.co.uk" <matt@codeblueprint.co.uk>

>Hmm...like this ?
>       sysctl.vm.fallback_mirror_memory =3D 0  // never fallback  # defaul=
t.
>       sysctl.vm.fallback_mirror_memory =3D 1  // the user memory may be a=
llocated from mirrored zone.
>       sysctl.vm.fallback_mirror_memory =3D 2  // usually kernel allocates=
 memory from mirrored zone before OOM.
>       sysctl.vm.fallback_mirror_memory =3D 3  // 1+2

Should option 2 say: // allow kernel to allocate from non-mirror zone to av=
oid OOM

> However I believe my customer's choice is always 0, above implementation =
can be done in a clean way.
> (adding a flag to zones (mirrored or not) and controlling fallback zoneli=
st walk.)

Modes allow us to make all of the people happy (I hope).

> BTW, we need this Taku's patch to make a progress. I think other devs sho=
uld be done in another
> development cycle. What does he need to get your Acks ?

The concept is great.   It's even "Tested-by: Tony Luck <tony.luck@intel.co=
m>".
I need to read the code more carefully before Acked-by.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
