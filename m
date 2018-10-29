Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id E86EF6B04AB
	for <linux-mm@kvack.org>; Mon, 29 Oct 2018 17:49:52 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id b5-v6so8220691oic.5
        for <linux-mm@kvack.org>; Mon, 29 Oct 2018 14:49:52 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id c21si9793163otf.125.2018.10.29.14.49.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Oct 2018 14:49:52 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: Re: memcg oops:
 memcg_kmem_charge_memcg()->try_charge()->page_counter_try_charge()->BOOM
Date: Mon, 29 Oct 2018 21:49:16 +0000
Message-ID: <20181029214913.GB13325@tower.DHCP.thefacebook.com>
References: <1540792855.22373.34.camel@gmx.de>
 <20181029132035.GI32673@dhcp22.suse.cz> <1540830938.10478.4.camel@gmx.de>
 <20181029185412.GA15760@tower.DHCP.thefacebook.com>
 <1540846014.4434.10.camel@gmx.de>
In-Reply-To: <1540846014.4434.10.camel@gmx.de>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <990D357981488C4FACC61A95FF6457E0@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Galbraith <efault@gmx.de>
Cc: Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Mon, Oct 29, 2018 at 09:46:54PM +0100, Mike Galbraith wrote:
> On Mon, 2018-10-29 at 18:54 +0000, Roman Gushchin wrote:
> >=20
> > Hi Mike!
> >=20
> > Thank you for the report!
> >=20
> > Do you see it reliable every time you boot up the machine?
>=20
> Yeah.
>=20
> > How do you run kvm?
>=20
> My VMs are full SW/data clones of my i7-4790/openSUSE <release> box.
>=20
> >  Is there something special about your cgroup setup?
>=20
> No, I generally have no use for cgroups.
>=20
> > I've made several attempts to reproduce the issue, but haven't got anyt=
hing
> > so far. I've used your config, and played with different cgroups setups=
.
>=20
> Ah, I have cgroup_disable=3Dmemory on the command line, which turns out
> to be why your box doesn't explode, while mine does.

Yeah, here it is. I'll send the fix in few minutes. Please,
test it on your setup. Your tested-by will be appreciated.

Thanks!
