Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 89BF66B00F7
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 18:40:47 -0500 (EST)
Received: by qauh8 with SMTP id h8so8783787qau.14
        for <linux-mm@kvack.org>; Tue, 21 Feb 2012 15:40:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1329824079-14449-5-git-send-email-glommer@parallels.com>
References: <1329824079-14449-1-git-send-email-glommer@parallels.com>
	<1329824079-14449-5-git-send-email-glommer@parallels.com>
Date: Tue, 21 Feb 2012 15:40:46 -0800
Message-ID: <CABCjUKBQZZ1fjKMAt5LdxzkVEhj3Ro9nxySH2rM8=N8Hk=OQzQ@mail.gmail.com>
Subject: Re: [PATCH 4/7] chained slab caches: move pages to a different cache
 when a cache is destroyed.
From: Suleiman Souhlal <suleiman@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, devel@openvz.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Greg Thelen <gthelen@google.com>, Johannes Weiner <jweiner@redhat.com>, Michal Hocko <mhocko@suse.cz>, Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>, Paul Turner <pjt@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

On Tue, Feb 21, 2012 at 3:34 AM, Glauber Costa <glommer@parallels.com> wrote:
> In the context of tracking kernel memory objects to a cgroup, the
> following problem appears: we may need to destroy a cgroup, but
> this does not guarantee that all objects inside the cache are dead.
> This can't be guaranteed even if we shrink the cache beforehand.
>
> The simple option is to simply leave the cache around. However,
> intensive workloads may have generated a lot of objects and thus
> the dead cache will live in memory for a long while.

Why is this a problem?

Leaving the cache around while there are still active objects in it
would certainly be a lot simpler to understand and implement.

-- Suleiman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
