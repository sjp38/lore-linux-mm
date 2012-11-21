Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 047316B00A8
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 08:48:43 -0500 (EST)
From: <leonid.moiseichuk@nokia.com>
Subject: RE: [RFC v3 0/3] vmpressure_fd: Linux VM pressure notifications
Date: Wed, 21 Nov 2012 13:48:14 +0000
Message-ID: <84FF21A720B0874AA94B46D76DB982690469CC31@008-AM1MPN1-002.mgdnok.nokia.com>
References: <20121115073420.GA19036@lizard.sbx05977.paloaca.wayport.net>
 <alpine.DEB.2.00.1211142351420.4410@chino.kir.corp.google.com>
 <20121115085224.GA4635@lizard>
 <alpine.DEB.2.00.1211151303510.27188@chino.kir.corp.google.com>
 <50A60873.3000607@parallels.com>
 <alpine.DEB.2.00.1211161157390.2788@chino.kir.corp.google.com>
 <50A6AC48.6080102@parallels.com>
 <alpine.DEB.2.00.1211161349420.17853@chino.kir.corp.google.com>
 <50AA3ABF.4090803@parallels.com>
 <alpine.DEB.2.00.1211200950120.4200@chino.kir.corp.google.com>
 <20121121093056.GA31882@shutemov.name>
 <84FF21A720B0874AA94B46D76DB982690469CC00@008-AM1MPN1-002.mgdnok.nokia.com>
 <50ACC104.5060006@parallels.com>
In-Reply-To: <50ACC104.5060006@parallels.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: glommer@parallels.com
Cc: kirill@shutemov.name, rientjes@google.com, anton.vorontsov@linaro.org, penberg@kernel.org, mgorman@suse.de, kosaki.motohiro@gmail.com, minchan@kernel.org, b.zolnierkie@samsung.com, john.stultz@linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com, linux-man@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, hannes@cmpxchg.org, tj@kernel.org


-----Original Message-----
From: ext Glauber Costa [mailto:glommer@parallels.com]=20
Sent: 21 November, 2012 13:55
....
So I'll say it again: if this is always global, there is no reason any
cgroup needs to be involved. If this turns out to be per-process, as
Anton suggested in a recent e-mail, I don't see any reason to have
cgroups involved as well.
-----

Per-process memory tracking has no much sense: process should consume all a=
vailable memory but work fast. Also this approach required knowledge about =
process deps to take into account dependencies e.g. in dbus or Xorg. If you=
 need to know how much memory process consumed in particular moment you can=
 use /proc/self/smaps, that is easier.

Best Wishes,
Leonid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
