Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010asp103.postini.com [74.125.245.223])
	by kanga.kvack.org (Postfix) with SMTP id D30F56B0068
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 13:26:00 -0400 (EDT)
Received: by yenr5 with SMTP id r5so7423077yen.14
        for <linux-mm@kvack.org>; Tue, 31 Jul 2012 09:30:38 -0700 (PDT)
Date: Tue, 31 Jul 2012 18:30:31 +0200
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [PATCH 00/10] memcg kmem limitation - slab.
Message-ID: <20120731163027.GE17078@somewhere.redhat.com>
References: <1343227101-14217-1-git-send-email-glommer@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1343227101-14217-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, devel@openvz.org, cgroups@vger.kernel.org

On Wed, Jul 25, 2012 at 06:38:11PM +0400, Glauber Costa wrote:
> Hi,
> 
> This is the slab part of the kmem limitation mechanism in its last form.  I
> would like to have comments on it to see if we can agree in its form. I
> consider it mature, since it doesn't change much in essence over the last
> forms. However, I would still prefer to defer merging it and merge the
> stack-only patchset first (even if inside the same merge window). That patchset
> contains most of the infrastructure needed here, and merging them separately
> would not only reduce the complexity for reviewers, but allow us a chance to
> have independent testing on them both. I would also likely benefit from some
> extra testing, to make sure the recent changes didn't introduce anything bad.

What is the status of the stack-only limitation patchset BTW? Does anybody oppose
to its merging?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
