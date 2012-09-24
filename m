Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 7FF976B002B
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 08:41:30 -0400 (EDT)
References: <1347977530-29755-1-git-send-email-glommer@parallels.com> <1347977530-29755-6-git-send-email-glommer@parallels.com> <20120921181458.GG7264@google.com> <506015E7.8030900@parallels.com>
Mime-Version: 1.0 (1.0)
In-Reply-To: <506015E7.8030900@parallels.com>
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Message-Id: <00000139f84bdedc-aae672a6-2908-4cb8-8ed3-8fedf67a21af-000000@email.amazonses.com>
From: Christoph <cl@linux.com>
Subject: Re: [PATCH v3 05/16] consider a memcg parameter in kmem_create_cache
Date: Mon, 24 Sep 2012 12:41:26 +0000
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Tejun Heo <tj@kernel.org>, "<linux-kernel@vger.kernel.org>" <linux-kernel@vger.kernel.org>, "<cgroups@vger.kernel.org>" <cgroups@vger.kernel.org>, "<kamezawa.hiroyu@jp.fujitsu.com>" <kamezawa.hiroyu@jp.fujitsu.com>, "<devel@openvz.org>" <devel@openvz.org>, "<linux-mm@kvack.org>" <linux-mm@kvack.org>, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>


On Sep 24, 2012, at 3:12, Glauber Costa <glommer@parallels.com> wrote:

> On 09/21/2012 10:14 PM, Tejun Heo wrote:
>=20
> The new caches will appear under /proc/slabinfo with the rest, with a
> string appended that identifies the group.

There are f.e. meminfo files in the per node directories in sysfs. It would m=
ake sense to have a slabinfo file there (if you want to keep that around). T=
hen the format would be the same.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
