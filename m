Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 656C88D0040
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 23:18:17 -0400 (EDT)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id p313IB3T021975
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 20:18:11 -0700
Received: from qyk29 (qyk29.prod.google.com [10.241.83.157])
	by kpbe11.cbf.corp.google.com with ESMTP id p313I4YN024104
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 20:18:09 -0700
Received: by qyk29 with SMTP id 29so51638qyk.10
        for <linux-mm@kvack.org>; Thu, 31 Mar 2011 20:18:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110331155931.GG12265@random.random>
References: <20110331110113.a01f7b8b.kamezawa.hiroyu@jp.fujitsu.com>
	<20110331155931.GG12265@random.random>
Date: Thu, 31 Mar 2011 20:18:04 -0700
Message-ID: <BANLkTimb+GeeiSPnX23Wfo-=1mHzNiJ=FQ@mail.gmail.com>
Subject: Re: [Lsf] [LSF][MM] rough agenda for memcg.
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, lsf@lists.linux-foundation.org, linux-mm@kvack.org

On Thu, Mar 31, 2011 at 8:59 AM, Andrea Arcangeli <aarcange@redhat.com> wro=
te:
> Hi KAMEZAWA,
>
> On Thu, Mar 31, 2011 at 11:01:13AM +0900, KAMEZAWA Hiroyuki wrote:
>> 1. Memory cgroup : Where next ? 1hour (Balbir Singh/Kamezawa)
>
> Originally it was 30min and then there was a topic "Working set
> estimation" for another 30 min. That has been converted to "what's
> next continued", so I assume that you can add the Working set
> estimation as a subtopic.

I see this session on the second day of the agenda. I think I'd like
to keep it a separate session; however I probably don't need the full
30 minutes; I should be able to give out the extra time to the virtual
machine memory sizing discussion that is slotted afterwards.

>> 2. Memcg Dirty Limit and writeback 30min(Greg Thelen)
>> 3. Memcg LRU management 30min (Ying Han, Michal Hocko)
>> 4. Page cgroup on a diet (Johannes Weiner)
>> 2.5 hours. This seems long...or short ? ;)
>
> Overall we've been seeing plenty of memcg emails, so I guess 2.5 hours
> are ok. And I wouldn't say we're not in the short side.

I am happy to see many parties interested in discussing memcg. I don't
think 2.5 hours are too much either.

One issue I would like to hear about is the way memcg is kept well
separated from the rest of the VM - as seen by the fact that only one
C file knows about the insides of struct mem_cgroup, that memcg has
been careful not to modify global reclaim, etc... I think this was
necessary early on when few people were interested in memcg, but now
that every major linux shop works on it it seems to me there is no
justification for that strong separation anymore. I'd like to see that
addressed explicitly because the concensus on that will affect what we
can do about memcg LRU management, page cgroup diet and a few other
topics.

>> =A0 IV) Diet of page_cgroup (for 30-min)
>> =A0 =A0 =A0 Maybe this can be combined with III.
>
> Looks a good plan to me, but others are more directly involved in
> memcg than me so feel free to decide! About the diet topic it was
> suggested by Johannes so I'll let him comment on it if he wants.

If the diet is successful enough, I think we could even consider
merging struct page_cgroup into struct page.

--=20
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
