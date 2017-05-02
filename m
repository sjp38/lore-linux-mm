Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9613A6B02C4
	for <linux-mm@kvack.org>; Tue,  2 May 2017 10:21:09 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 7so11625455pgg.19
        for <linux-mm@kvack.org>; Tue, 02 May 2017 07:21:09 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id s10si8210486pgs.322.2017.05.02.07.21.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 May 2017 07:21:08 -0700 (PDT)
From: "Christopherson, Sean J" <sean.j.christopherson@intel.com>
Subject: RE: [PATCH 0/2] mm/memcontrol: fix reclaim bugs in mem_cgroup_iter
Date: Tue, 2 May 2017 14:20:45 +0000
Message-ID: <37306EFA9975BE469F115FDE982C075B9B704A9A@ORSMSX108.amr.corp.intel.com>
References: <1493416547-19212-1-git-send-email-sean.j.christopherson@intel.com>
 <20170502140357.GL14593@dhcp22.suse.cz>
In-Reply-To: <20170502140357.GL14593@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@kernel.org>
Cc: "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "vdavydov.dev@gmail.com" <vdavydov.dev@gmail.com>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Michal Hocko <mhocko@kernel.org> wrote:
> On Fri 28-04-17 14:55:45, Sean Christopherson wrote:
> > This patch set contains two bug fixes for mem_cgroup_iter().  The bugs
> > were found by code inspection and were confirmed via synthetic testing
> > that forcefully setup the failing conditions.
>=20
> I assume that you added some artificial sleeps to make those races more
> probable, right? Or did you manage to hit those issue solely from the
> userspace? I will have a look at those patches. It has been some time
> since I've had it cached. It is pretty subtle code so I would like to
> understand the urgency before I dive into this further.
> --=20
> Michal Hocko
> SUSE Labs

The code to prove the bugs is completely artificial, it's basically a
unit test for mem_cgroup_iter() that uses a thread barrier to all but
guarantee two threads will call mem_cgroup_iter() simultaneously.  I
haven't even attempted to hit this via the actual userspace flow.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
