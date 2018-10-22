Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 030BB6B0006
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 11:08:35 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id b76-v6so26944241ywb.11
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 08:08:34 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id x14-v6si463327ybk.301.2018.10.22.08.08.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Oct 2018 08:08:33 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: Re: Memory management issue in 4.18.15
Date: Mon, 22 Oct 2018 15:08:22 +0000
Message-ID: <20181022150815.GA4287@tower.DHCP.thefacebook.com>
References: <CADa=ObrwYaoNFn0x06mvv5W1F9oVccT5qjGM8qFBGNPoNuMUNw@mail.gmail.com>
 <20181022083322.GE32333@dhcp22.suse.cz>
In-Reply-To: <20181022083322.GE32333@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <691E3861403A884F9C13E463795DDAC2@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Spock <dairinin@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@surriel.com>, Johannes
 Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Shakeel Butt <shakeelb@google.com>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <alexander.levin@microsoft.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Oct 22, 2018 at 10:33:22AM +0200, Michal Hocko wrote:
> Cc som more people.
>=20
> I am wondering why 172b06c32b94 ("mm: slowly shrink slabs with a
> relatively small number of objects") has been backported to the stable
> tree when not marked that way. Put that aside it seems likely that the
> upstream kernel will have the same issue I suspect. Roman, could you
> have a look please?

Sure, already looking... Spock provided some useful details, and I think,
I know what's happening... Hope to propose a solution soon.

RE backporting: I'm slightly surprised that only one patch of the memcg
reclaim fix series has been backported. Either all or none makes much more
sense to me.

Thanks!
