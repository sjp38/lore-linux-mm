Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 48D176B0032
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 19:13:47 -0400 (EDT)
Received: by mail-lb0-f175.google.com with SMTP id r10so3052477lbi.20
        for <linux-mm@kvack.org>; Mon, 17 Jun 2013 16:13:45 -0700 (PDT)
Date: Tue, 18 Jun 2013 03:13:40 +0400
From: Glauber Costa <glommer@gmail.com>
Subject: Re: [PATCH v2 0/2] slightly rework memcg cache id determination
Message-ID: <20130617231339.GA3306@localhost.localdomain>
References: <1371233076-936-1-git-send-email-glommer@openvz.org>
 <20130617133049.GC5018@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130617133049.GC5018@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm <linux-mm@kvack.org>, cgroups <cgroups@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Glauber Costa <glommer@openvz.org>

On Mon, Jun 17, 2013 at 03:30:49PM +0200, Michal Hocko wrote:
> On Fri 14-06-13 14:04:34, Glauber Costa wrote:
> > Michal,
> > 
> > Let me know if this is more acceptable to you. I didn't take your suggestion of
> > having an id and idx functions, because I think this could potentially be even
> > more confusing: in the sense that people would need to wonder a bit what is the
> > difference between them.
> 
> Any clean up is better than nothing. I still think that split up and
> making the 2 functions explicit would be better but I do not think this
> is really that important. 
> 
Being all the same to you, I prefer like this. At least while the users are self
contained and live inside memcg core. This is because I believe having two functions
can be a bit confusing, and while not *totally* confusing, the array-like users
are relatively few.

 
> OK. If you had an _idx variant then you wouldn't need to add that
> VM_BUG_ON at every single place where you use it as an index and do not
> risk that future calls would forget about VM_BUG_ON.
> 
> > For the other cases, I have consolidated a bit the usage pattern around
> > memcg_cache_id.  Now the tests are all pretty standardized.
> 
> OK, Great!
>  
Thanks Michal! Please take a look at the individual patches if you can.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
