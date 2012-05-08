Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 3C63E6B00E7
	for <linux-mm@kvack.org>; Tue,  8 May 2012 01:42:05 -0400 (EDT)
Received: by ggeq1 with SMTP id q1so1864214gge.14
        for <linux-mm@kvack.org>; Mon, 07 May 2012 22:42:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FA89348.6070000@parallels.com>
References: <1336070841-1071-1-git-send-email-glommer@parallels.com>
	<CABCjUKDuiN6bq6rbPjE7futyUwTPKsSFWHXCJ-OFf30tgq5WZg@mail.gmail.com>
	<4FA89348.6070000@parallels.com>
Date: Tue, 8 May 2012 08:42:04 +0300
Message-ID: <CAOJsxLHFS+B64qfhCg-9LPbggPoyvkBSnA8nZPRoV15eeRpi_w@mail.gmail.com>
Subject: Re: [RFC] slub: show dead memcg caches in a separate file
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Suleiman Souhlal <suleiman@google.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>

On Tue, May 8, 2012 at 6:30 AM, Glauber Costa <glommer@parallels.com> wrote:
> But there is another aspect: those dead caches have one thing in common,
> which is the fact that no new objects will ever be allocated on them. You
> can't tune them, or do anything with them. I believe it is misleading to
> include them in slabinfo.
>
> The fact that the caches change names - to append "dead" may also break
> tools, if that is what you are concerned about.
>
> For all the above, I think a better semantics for slabinfo is to include the
> active caches, and leave the dead ones somewhere else.

Can these "dead caches" still hold on to physical memory? If so, they
must appear in /proc/slabinfo.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
