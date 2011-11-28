Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 9C0826B002D
	for <linux-mm@kvack.org>; Sun, 27 Nov 2011 19:45:07 -0500 (EST)
Received: by lamb11 with SMTP id b11so576699lam.14
        for <linux-mm@kvack.org>; Sun, 27 Nov 2011 16:45:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1322062951-1756-4-git-send-email-hannes@cmpxchg.org>
References: <1322062951-1756-1-git-send-email-hannes@cmpxchg.org>
	<1322062951-1756-4-git-send-email-hannes@cmpxchg.org>
Date: Mon, 28 Nov 2011 06:15:05 +0530
Message-ID: <CAKTCnzkaWAnpbz+o3G=-mO1qUYKVjXaJwcCDYYt0SCspJdbe3g@mail.gmail.com>
Subject: Re: [patch 3/8] mm: memcg: clean up fault accounting
From: Balbir Singh <bsingharora@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Nov 23, 2011 at 9:12 PM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
> From: Johannes Weiner <jweiner@redhat.com>
>
> The fault accounting functions have a single, memcg-internal user, so
> they don't need to be global. =A0In fact, their one-line bodies can be
> directly folded into the caller. =A0And since faults happen one at a
> time, use this_cpu_inc() directly instead of this_cpu_add(foo, 1).
>

Acked-by: Balbir Singh <bsingharora@gmail.com>

Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
