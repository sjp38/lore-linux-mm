Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id DF4426B0034
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 12:34:36 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id rl6so8084593pac.1
        for <linux-mm@kvack.org>; Fri, 21 Jun 2013 09:34:36 -0700 (PDT)
Date: Fri, 21 Jun 2013 09:34:32 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v5] Soft limit rework
Message-ID: <20130621163432.GB31218@htj.dyndns.org>
References: <1371557387-22434-1-git-send-email-mhocko@suse.cz>
 <20130620111206.GA14809@suse.de>
 <20130621140627.GI12424@dhcp22.suse.cz>
 <20130621140938.GJ12424@dhcp22.suse.cz>
 <20130621150430.GL12424@dhcp22.suse.cz>
 <20130621150906.GM12424@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130621150906.GM12424@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, Glauber Costa <glommer@gmail.com>

On Fri, Jun 21, 2013 at 05:09:06PM +0200, Michal Hocko wrote:
> And I am total idiot. The machine was not booted with mem=1G so the
> figures are completely useless.
> 
> It is soooo Friday. I will start everything again on Monday with a clean
> head.
> 
> Sorry about all the noise.

Oh, don't be.  It was the most fun thread of the whole week.  Enjoy
the weekend. :)

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
