Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 5B3AE8D0040
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 10:26:50 -0400 (EDT)
Date: Wed, 23 Mar 2011 15:26:45 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: cgroup: real meaning of memory.usage_in_bytes
Message-ID: <20110323142645.GB15474@tiehlicka.suse.cz>
References: <20110318152532.GB18450@tiehlicka.suse.cz>
 <20110321093419.GA26047@tiehlicka.suse.cz>
 <AANLkTimkcYcZVifaq4pH4exkWUVNXpwXA=9oyeAn_EqR@mail.gmail.com>
 <20110322073514.GB12940@tiehlicka.suse.cz>
 <AANLkTi=2t_tL=Vt4athAyQ1tDhLDGpqtmu-iAOjdbPBJ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTi=2t_tL=Vt4athAyQ1tDhLDGpqtmu-iAOjdbPBJ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 22-03-11 10:06:27, Ying Han wrote:
> On Tue, Mar 22, 2011 at 12:35 AM, Michal Hocko <mhocko@suse.cz> wrote:
> > On Mon 21-03-11 10:22:41, Ying Han wrote:
> > [...]
> >>
> >> Michal,
> >>
> >> Can you help to post the test result after applying the patch?
> >
> > The result of the LTP test is:
> > TEST 4: MEMORY CONTROLLER TESTING
> > RUNNING SETUP.....
> > WARN:/dev/memctl already exist..overwriting
> > Cleanup called
> > TEST STARTED: Please avoid using system while this test executes
> > memory usage from memory.usage_in_bytes= 62955520
> > memory usage from memory.stat= 62955520
> > TINFO ? Memory Resource Controller: stat check test passes first run
> > Test continues to run the second step.
> > memory usage from memory.usage_in_bytes= 78643200
> > memory usage from memory.stat=78643200
> > TPASS ? Memory Resource Controller: stat check test PASSED
> > Memory Resource Controller test executed successfully.
> > Cleanup called
[...]
> Thanks Michal for fixing it up. Regardless of the performance
> overhead, the change make sense to me.

As you can see in the other email in this thread the patch is not 100%
correct because it doesn't consider batched uncharges which are stored
in the task_struct. Make it 100% correct would be harder and probably
not worth the overhead. Daisuke Nishimura is working on the
documentation update patch which will most likely describe that
usage_in_bytes is not exactly rss+cache and that nobody should rely on
it.

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
