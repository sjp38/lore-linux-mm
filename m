Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 27EA38E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 12:33:29 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id i11so1305947iog.2
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 09:33:29 -0800 (PST)
Received: from GCC01-CY1-obe.outbound.protection.outlook.com (mail-eopbgr830119.outbound.protection.outlook.com. [40.107.83.119])
        by mx.google.com with ESMTPS id j6si12408351iob.152.2018.12.21.09.33.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 21 Dec 2018 09:33:28 -0800 (PST)
From: Burt Holzman <burt@fnal.gov>
Subject: Re: OOM notification for cgroupsv1 broken in 4.19
Date: Fri, 21 Dec 2018 17:33:17 +0000
Message-ID: <96D4815C-420F-41B7-B1E9-A741E7523596@services.fnal.gov>
References: <5ba5ba06-554c-d1ec-0967-b1d3486d0699@fnal.gov>
 <20181221153302.GB6410@dhcp22.suse.cz>
In-Reply-To: <20181221153302.GB6410@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <88DDE5C2B16A1143858F3E612DFFCF79@namprd09.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "vdavydov.dev@gmail.com" <vdavydov.dev@gmail.com>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>


> On Dec 21, 2018, at 9:33 AM, Michal Hocko <mhocko@kernel.org> wrote:
>=20
> On Fri 21-12-18 14:49:38, Burt Holzman wrote:
>> Hi,
>>=20
>> This patch: 29ef680ae7c21110af8e6416d84d8a72fc147b14
>> [PATCH] memcg, oom: move out_of_memory back to the charge path
>>=20
>> has broken the eventfd notification for cgroups-v1. This is because=20
>> mem_cgroup_oom_notify() is called only in mem_cgroup_oom_synchronize and=
=20
>> not with the new, additional call to mem_cgroup_out_of_memory in the=20
>> charge path.
>=20
> Yes, you are right and this is a clear regression. Does the following
> patch fixes the issue for you? I am not super happy about the code
> duplication but I wasn't able to separate this out from
> mem_cgroup_oom_synchronize because that one has to handle the oom_killer
> disabled case which is not the case in the charge path because we simply
> back off and hand over to mem_cgroup_oom_synchronize in that case.

Hi Michal,

Thanks for the quick response & patch. I can confirm that with this patch t=
he notification is working for my sample test case.

- B
