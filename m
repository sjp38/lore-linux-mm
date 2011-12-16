Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 3AAC46B004D
	for <linux-mm@kvack.org>; Fri, 16 Dec 2011 08:30:53 -0500 (EST)
Date: Fri, 16 Dec 2011 14:30:49 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v9 1/9] Basic kernel memory functionality for the Memory
 Controller
Message-ID: <20111216133049.GI3122@tiehlicka.suse.cz>
References: <1323676029-5890-1-git-send-email-glommer@parallels.com>
 <1323676029-5890-2-git-send-email-glommer@parallels.com>
 <20111214170447.GB4856@tiehlicka.suse.cz>
 <4EE9E81E.2090700@parallels.com>
 <20111216123233.GF3122@tiehlicka.suse.cz>
 <4EEB417B.8000508@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4EEB417B.8000508@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org, eric.dumazet@gmail.com, cgroups@vger.kernel.org, Johannes Weiner <jweiner@redhat.com>

On Fri 16-12-11 17:02:51, Glauber Costa wrote:
> On 12/16/2011 04:32 PM, Michal Hocko wrote:
[...]
> >So why do we need kmem accounting when tcp (the only user at the moment)
> >doesn't use it?
> 
> Well, a bit historical. I needed a basic placeholder for it, since
> it tcp is officially kmem. As the time passed, I took most of the
> stuff out of this patch to leave just the basics I would need for
> tcp.
> Turns out I ended up focusing on the rest, and some of the stuff was
> left here.
> 
> At one point I merged tcp data into kmem, but then reverted this
> behavior. the kmem counter stayed.
> 
> I agree deferring the whole behavior would be better.
> 
> >>In summary, we still never do non-independent accounting. When we
> >>start doing it for the other caches, We will have to add a test at
> >>charge time as well.
> >
> >So we shouldn't do it as a part of this patchset because the further
> >usage is not clear and I think there will be some real issues with
> >user+kmem accounting (e.g. a proper memcg-oom implementation).
> >Can you just drop this patch?
> 
> Yes, but the whole set is in the net tree already. 

Isn't it only in some for-next branch? Can that one be updated?

> (All other patches are tcp-related but this) Would you mind if I'd
> send a follow up patch removing the kmem files, and leaving just the
> registration functions and basic documentation? (And sorry for that as
> well in advance)

Yes a followup patch would work as well.

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
