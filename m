Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 86C046B0273
	for <linux-mm@kvack.org>; Fri, 15 Sep 2017 22:10:11 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 188so7514755pgb.3
        for <linux-mm@kvack.org>; Fri, 15 Sep 2017 19:10:11 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id y3si1585930pln.504.2017.09.15.19.10.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Sep 2017 19:10:10 -0700 (PDT)
From: "Wang, Kemi" <kemi.wang@intel.com>
Subject: RE: [PATCH 1/3] mm, sysctl: make VM stats configurable
Date: Sat, 16 Sep 2017 02:10:05 +0000
Message-ID: <25017BF213203E48912DB000DE5F5E1E6B3EAE9E@SHSMSX101.ccr.corp.intel.com>
References: <1505467406-9945-1-git-send-email-kemi.wang@intel.com>
 <1505467406-9945-2-git-send-email-kemi.wang@intel.com>
 <20170915114952.czb7nbsioqguxxk3@dhcp22.suse.cz>
In-Reply-To: <20170915114952.czb7nbsioqguxxk3@dhcp22.suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Luis R . Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, Hillf Danton <hillf.zj@alibaba-inc.com>, Dave <dave.hansen@linux.intel.com>, "Chen, Tim C" <tim.c.chen@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, "Huang, Ying" <ying.huang@intel.com>, "Lu, Aaron" <aaron.lu@intel.com>, Proc sysctl <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux
 Kernel <linux-kernel@vger.kernel.org>

-----Original Message-----
From: Michal Hocko [mailto:mhocko@kernel.org]=20
Sent: Friday, September 15, 2017 7:50 PM
To: Wang, Kemi <kemi.wang@intel.com>
Cc: Luis R . Rodriguez <mcgrof@kernel.org>; Kees Cook <keescook@chromium.or=
g>; Andrew Morton <akpm@linux-foundation.org>; Jonathan Corbet <corbet@lwn.=
net>; Mel Gorman <mgorman@techsingularity.net>; Johannes Weiner <hannes@cmp=
xchg.org>; Christopher Lameter <cl@linux.com>; Sebastian Andrzej Siewior <b=
igeasy@linutronix.de>; Vlastimil Babka <vbabka@suse.cz>; Hillf Danton <hill=
f.zj@alibaba-inc.com>; Dave <dave.hansen@linux.intel.com>; Chen, Tim C <tim=
.c.chen@intel.com>; Kleen, Andi <andi.kleen@intel.com>; Jesper Dangaard Bro=
uer <brouer@redhat.com>; Huang, Ying <ying.huang@intel.com>; Lu, Aaron <aar=
on.lu@intel.com>; Proc sysctl <linux-fsdevel@vger.kernel.org>; Linux MM <li=
nux-mm@kvack.org>; Linux Kernel <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 1/3] mm, sysctl: make VM stats configurable

On Fri 15-09-17 17:23:24, Kemi Wang wrote:
> This patch adds a tunable interface that allows VM stats configurable, as
> suggested by Dave Hansen and Ying Huang.
>=20
> When performance becomes a bottleneck and you can tolerate some possible
> tool breakage and some decreased counter precision (e.g. numa counter), y=
ou
> can do:
> 	echo [C|c]oarse > /proc/sys/vm/vmstat_mode
>=20
> When performance is not a bottleneck and you want all tooling to work, yo=
u
> can do:
> 	echo [S|s]trict > /proc/sys/vm/vmstat_mode
>=20
> We recommend automatic detection of virtual memory statistics by system,
> this is also system default configuration, you can do:
> 	echo [A|a]uto > /proc/sys/vm/vmstat_mode
>=20
> The next patch handles numa statistics distinctively based-on different V=
M
> stats mode.

I would just merge this with the second patch so that it is clear how
those modes are implemented. I am also wondering why cannot we have a
much simpler interface and implementation to enable/disable numa stats
(btw. sysctl_vm_numa_stats would be more descriptive IMHO).

The motivation is that we propose a general tunable  interface for VM stats=
.
This would be more scalable, since we don't have to add an individual
Interface for each type of counter that can be configurable.
In the second patch, NUMA stats, as an example, can benefit for that.

If you still hold your idea, I don't mind to merge them together.
--=20
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
