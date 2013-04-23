Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id F0C466B0002
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 15:13:44 -0400 (EDT)
Received: by mail-we0-f171.google.com with SMTP id i48so949681wef.30
        for <linux-mm@kvack.org>; Tue, 23 Apr 2013 12:13:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1366705329-9426-2-git-send-email-glommer@openvz.org>
References: <1366705329-9426-1-git-send-email-glommer@openvz.org>
	<1366705329-9426-2-git-send-email-glommer@openvz.org>
Date: Tue, 23 Apr 2013 22:13:42 +0300
Message-ID: <CAOJsxLHHvcHZHTKO9WTOOJvNW21NgNsUkreQnzwk3Wp=6XCgPg@mail.gmail.com>
Subject: Re: [PATCH 1/2] vmpressure: in-kernel notifications
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "<cgroups@vger.kernel.org>" <cgroups@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Anton Vorontsov <anton.vorontsov@linaro.org>, John Stultz <john.stultz@linaro.org>, Joonsoo Kim <js1304@gmail.com>, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Tue, Apr 23, 2013 at 11:22 AM, Glauber Costa <glommer@openvz.org> wrote:
> From: Glauber Costa <glommer@parallels.com>
>
> During the past weeks, it became clear to us that the shrinker interface
> we have right now works very well for some particular types of users,
> but not that well for others. The later are usually people interested in
> one-shot notifications, that were forced to adapt themselves to the
> count+scan behavior of shrinkers. To do so, they had no choice than to
> greatly abuse the shrinker interface producing little monsters all over.
>
> During LSF/MM, one of the proposals that popped out during our session
> was to reuse Anton Voronstsov's vmpressure for this. They are designed
> for userspace consumption, but also provide a well-stablished,
> cgroup-aware entry point for notifications.
>
> This patch extends that to also support in-kernel users. Events that
> should be generated for in-kernel consumption will be marked as such,
> and for those, we will call a registered function instead of triggering
> an eventfd notification.
>
> Please note that due to my lack of understanding of each shrinker user,
> I will stay away from converting the actual users, you are all welcome
> to do so.
>
> Signed-off-by: Glauber Costa <glommer@openvz.org>

Looks good to me.

Acked-by: Pekka Enberg <penberg@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
