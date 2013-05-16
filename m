Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 7E5296B0032
	for <linux-mm@kvack.org>; Thu, 16 May 2013 18:17:05 -0400 (EDT)
Received: by mail-qa0-f46.google.com with SMTP id bv4so30352qab.12
        for <linux-mm@kvack.org>; Thu, 16 May 2013 15:17:04 -0700 (PDT)
Date: Thu, 16 May 2013 15:16:58 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [patch v3 -mm 2/3] memcg: Get rid of soft-limit tree
 infrastructure
Message-ID: <20130516221658.GH7171@mtj.dyndns.org>
References: <1368431172-6844-1-git-send-email-mhocko@suse.cz>
 <1368431172-6844-3-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1368431172-6844-3-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, Balbir Singh <bsingharora@gmail.com>

On Mon, May 13, 2013 at 09:46:11AM +0200, Michal Hocko wrote:
> Now that the soft limit is integrated to the reclaim directly the whole
> soft-limit tree infrastructure is not needed anymore. Rip it out.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Reviewed-by: Tejun Heo <tj@kernel.org>

Nice cleanup, thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
