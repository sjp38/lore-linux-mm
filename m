Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4C4086B0003
	for <linux-mm@kvack.org>; Thu,  1 Nov 2018 23:16:40 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id t10-v6so551049plh.14
        for <linux-mm@kvack.org>; Thu, 01 Nov 2018 20:16:40 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id d66-v6si33454809pfc.250.2018.11.01.20.16.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Nov 2018 20:16:39 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: Re: Will the recent memory leak fixes be backported to longterm
 kernels?
Date: Fri, 2 Nov 2018 03:16:08 +0000
Message-ID: <20181102031600.GA15013@castle.DHCP.thefacebook.com>
References: <PU1P153MB0169CB6382E0F047579D111DBFCF0@PU1P153MB0169.APCP153.PROD.OUTLOOK.COM>
 <20181102005816.GA10297@tower.DHCP.thefacebook.com>
 <PU1P153MB0169FE681EF81BCE81B005A1BFCF0@PU1P153MB0169.APCP153.PROD.OUTLOOK.COM>
In-Reply-To: <PU1P153MB0169FE681EF81BCE81B005A1BFCF0@PU1P153MB0169.APCP153.PROD.OUTLOOK.COM>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <8D6DDE4B74DB614E97CF0C7E6120702F@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dexuan Cui <decui@microsoft.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>, Shakeel
 Butt <shakeelb@google.com>, Michal Hocko <mhocko@kernel.org>, Johannes
 Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Rik van Riel <riel@surriel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Matthew Wilcox <willy@infradead.org>, "Stable@vger.kernel.org" <Stable@vger.kernel.org>

On Fri, Nov 02, 2018 at 02:45:42AM +0000, Dexuan Cui wrote:
> > From: Roman Gushchin <guro@fb.com>
> > Sent: Thursday, November 1, 2018 17:58
> >=20
> > On Fri, Nov 02, 2018 at 12:16:02AM +0000, Dexuan Cui wrote:
> > Hello, Dexuan!
> >=20
> > A couple of issues has been revealed recently, here are fixes
> > (hashes are from the next tree):
> >=20
> > 5f4b04528b5f mm: don't reclaim inodes with many attached pages
> > 5a03b371ad6a mm: handle no memcg case in memcg_kmem_charge()
> > properly
> >=20
> > These two patches should be added to the serie.
>=20
> Thanks for the new info!
> =20
> > Re stable backporting, I'd really wait for some time. Memory reclaim is=
 a
> > quite complex and fragile area, so even if patches are correct by thems=
elves,
> > they can easily cause a regression by revealing some other issues (as i=
t was
> > with the inode reclaim case).
>=20
> I totally agree. I'm now just wondering if there is any temporary workaro=
und,
> even if that means we have to run the kernel with some features disabled =
or
> with a suboptimal performance?

I don't think there is any, except not using memory cgroups at all.
Limiting the amount of cgroups which are created and destroyed helps too:
a faulty service running under systemd can be especially painful.

Thanks!
