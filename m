Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 163A76B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 12:16:52 -0400 (EDT)
Received: by obhx4 with SMTP id x4so2141743obh.14
        for <linux-mm@kvack.org>; Wed, 27 Jun 2012 09:16:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FE9755B.1040905@parallels.com>
References: <1340633728-12785-1-git-send-email-glommer@parallels.com>
	<1340633728-12785-3-git-send-email-glommer@parallels.com>
	<CABCjUKD0h089StLF8BwVRU-St70Ai9PTw-cjis40_aLLG3MAQQ@mail.gmail.com>
	<4FE9755B.1040905@parallels.com>
Date: Wed, 27 Jun 2012 09:16:51 -0700
Message-ID: <CABCjUKBJ9UewM=LePC89ZUdk4u4rnZXBNH43yN6qZhT8zcfieQ@mail.gmail.com>
Subject: Re: [PATCH 02/11] memcg: Reclaim when more than one page needed.
From: Suleiman Souhlal <suleiman@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>

On Tue, Jun 26, 2012 at 1:39 AM, Glauber Costa <glommer@parallels.com> wrote:
> Yeah, forgot to update the changelog =(
>
> But much more importantly, are you still happy with those changes?

Yes, I am OK with those changes.

Thanks,
-- Suleiman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
