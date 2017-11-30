Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3FAB76B0038
	for <linux-mm@kvack.org>; Thu, 30 Nov 2017 06:06:57 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id a13so4120573pgt.0
        for <linux-mm@kvack.org>; Thu, 30 Nov 2017 03:06:57 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id f5si2870190pgn.126.2017.11.30.03.06.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Nov 2017 03:06:55 -0800 (PST)
From: "Wang, Kemi" <kemi.wang@intel.com>
Subject: RE: [PATCH 1/2] mm: NUMA stats code cleanup and enhancement
Date: Thu, 30 Nov 2017 11:06:51 +0000
Message-ID: <25017BF213203E48912DB000DE5F5E1E6B70EA3C@SHSMSX101.ccr.corp.intel.com>
References: <1511848824-18709-1-git-send-email-kemi.wang@intel.com>
 <20171129121740.f6drkbktc43l5ib6@dhcp22.suse.cz>
 <4b840074-cb5f-3c10-d65b-916bc02fb1ee@intel.com>
 <20171130085322.tyys6xbzzvui7ogz@dhcp22.suse.cz>
 <0f039a89-5500-1bf5-c013-d39ba3bf62bd@intel.com>
 <20171130094523.vvcljyfqjpbloe5e@dhcp22.suse.cz>
In-Reply-To: <20171130094523.vvcljyfqjpbloe5e@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, David Rientjes <rientjes@google.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Dave <dave.hansen@linux.intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, "Chen, Tim C" <tim.c.chen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, "Huang, Ying" <ying.huang@intel.com>, "Lu, Aaron" <aaron.lu@intel.com>, "Li, Aubrey" <aubrey.li@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>

Of course, we should do that AFAP. Thanks for your comments :)

-----Original Message-----
From: owner-linux-mm@kvack.org [mailto:owner-linux-mm@kvack.org] On Behalf =
Of Michal Hocko
Sent: Thursday, November 30, 2017 5:45 PM
To: Wang, Kemi <kemi.wang@intel.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>; Andrew Morton <akpm@li=
nux-foundation.org>; Vlastimil Babka <vbabka@suse.cz>; Mel Gorman <mgorman@=
techsingularity.net>; Johannes Weiner <hannes@cmpxchg.org>; Christopher Lam=
eter <cl@linux.com>; YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>; Andrey Rya=
binin <aryabinin@virtuozzo.com>; Nikolay Borisov <nborisov@suse.com>; Pavel=
 Tatashin <pasha.tatashin@oracle.com>; David Rientjes <rientjes@google.com>=
; Sebastian Andrzej Siewior <bigeasy@linutronix.de>; Dave <dave.hansen@linu=
x.intel.com>; Kleen, Andi <andi.kleen@intel.com>; Chen, Tim C <tim.c.chen@i=
ntel.com>; Jesper Dangaard Brouer <brouer@redhat.com>; Huang, Ying <ying.hu=
ang@intel.com>; Lu, Aaron <aaron.lu@intel.com>; Li, Aubrey <aubrey.li@intel=
.com>; Linux MM <linux-mm@kvack.org>; Linux Kernel <linux-kernel@vger.kerne=
l.org>
Subject: Re: [PATCH 1/2] mm: NUMA stats code cleanup and enhancement

On Thu 30-11-17 17:32:08, kemi wrote:
[...]
> Your patch saves more code than mine because the node stats framework=20
> is reused for numa stats. But it has a performance regression because=20
> of the limitation of threshold size (125 at most, see=20
> calculate_normal_threshold() in vmstat.c) in inc_node_state().

But this "regression" would be visible only on those workloads which really=
 need to squeeze every single cycle out of the allocation hot path and thos=
e are supposed to disable the accounting altogether. Or is this visible on =
a wider variety of workloads.

Do not get me wrong. If we want to make per-node stats more optimal, then b=
y all means let's do that. But having 3 sets of counters is just way to muc=
h.

--
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in the body to m=
ajordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
