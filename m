Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id CE4206B01AF
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 06:54:49 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o54AsjKq002730
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 4 Jun 2010 19:54:45 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 83F1F45DE4F
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 19:54:45 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6216445DE4E
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 19:54:45 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4EED01DB8050
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 19:54:45 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 036A61DB8048
	for <linux-mm@kvack.org>; Fri,  4 Jun 2010 19:54:45 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch -mm 08/18] oom: badness heuristic rewrite
In-Reply-To: <20100603161030.074d9b98.akpm@linux-foundation.org>
References: <20100602225252.F536.A69D9226@jp.fujitsu.com> <20100603161030.074d9b98.akpm@linux-foundation.org>
Message-Id: <20100604195328.72D9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Fri,  4 Jun 2010 19:54:44 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,

> > I've already explained the reason. 1) all-of-rewrite patches are 
> > always unacceptable. that's prevent our code maintainance.
> 
> No, we'll sometime completely replace implementations.  There's no hard
> rule apart from "whatever makes sense".  If wholesale replacement makes
> sense as a patch-presentation method then we'll do that.

Have you review the actual patches? And No, I don't think "complete 
replace with no test result" is adequate development way.

And, When developers post large patch set, Usually _you_ request show
demonstrate result. I haven't seen such result in this activity.

I agree OOM is invoked from various callsite (because page allocator is 
called from various),  triggered from various memory starvation and/or 
killable userland processes are also vary various. So, I don't think 
the patch author must do 100% corvarage test.

And I can say, I made some brief test case for confirming this and
I haven't seen critical fault. 

However, It doesn't give any reason to avoid code review and violate
our development process.


> > 2) no justification
> > patches are also unacceptable. you need to write more proper patch descriptaion
> > at least.
> 
> The descriptions look better than usual from a quick scan.  I haven't
> really got into them yet.
> 
> 
> And I'm going to have to get into it because of you guys' seeming
> inability to get your act together.

Inability? What do you mean inability? Almost all developers cooperate 
for making stabilized kernel. Is this effort inability? or meaningless?

Actually, the descriptions doesn't looks better really. We sometimes
ask him
 - which problem occur? how do you reproduce it?
 - which piece solve which issue?
 - how do you measure side effect?
 - how do you mesure or consider other workload user

But I got only the answer, "My patch is best. resistance is futile". that's
purely Baaaad.

At least, All of the patch author must to write the code intention. otherwise
how do we review such code? guessing intention often makes code misparse
and allow to insert bug. if the patch is enough small, it is not big problem.
we don't makes misparse so often. but if it's large, the big problem.

Again, I don't think we can't make separate the patch as individual parts
and I don't think to don't be able to write each changes intention.


> The unsubstantiated "nack"s are of no use and I shall just be ignoring
> them and making my own decisions.  If you have specific objections then
> let's hear them.  In detail, please - don't refer to previous
> conversations because that's all too confusing - there is benefit in
> starting again.

OK. I don't have any reason to confuse you. I'll fix me. My point is
really simple. The majority OOM user are in desktop. We must not ignore
them. such as

 - Any regression from desktop view are unacceptable
 - Any incompatibility of no desktop improvement are unacceptable
 - Any refusing bugfix are unacceptable
 - Any refusing reviewing are unacceptable (IOW, must get any developers ack.
   I'm ok even if they don't include me)

In other word, every heuristic change have to be explained why the patch
improve desktop or no side-effect desktop.
(ah, ok. for cpuset change is one of exception. desktop user definitely
don't use it)

I and any other reviewer only want to confirm the have have no significant
regression. All of patch authoer have to help this, I think.


> I expect I'll be looking at the oom-killer situation in depth early
> next week.  It would be useful if between now and then you can send
> any specific, detailed and actionable comments which you have.

1) fix bugs at fist before making new feature (a.k.a new bugs)
2) don't mix bugfix and new feature
3) make separate as natural and individual piece
4) keep small and reviewable patch size
5) stop ugly excuse, instead repeatedly rewrite until get anyone ack
6) don't ignore another developers bug report

Which is unactionable? I just don't understand :/
I didn't hope says the same thing twice and he repeatedly ignore
my opinion, thus, he got short answer. I didn't think this is inadequate
beucase he can google past mail.

The fact is, I and (gessing) all other developer don't get any pressure 
from our campany because enterprise vendor don't interest oom. We are 
making time by chopping our private time, for helping impvoe his patch. 
Beucase we know current oom logic doesn't fit nowadys modern desktop
environment and we surely hope to remove such harm.

However he repeatedly attach our goodwill and blame our tolerance. 
but also repeatedly said "My workload is important than other!".
Then, I got upset really.

The fact is, all of good developer never says "my workload is most
important in the world", it makes no sense and insane. I really hate
such selfish.


And No. I wouldn't hope to continue full review during the author refuse
to hear. Kidding me. Instead, I'll do cherry-picking good piece from the 
sludge at-random patches and push you them. I think that makes everybody 
happy, people get improvement, DaveR get the merge, and I'll free from 
this frustration source. Of cource, I'll refrect your review result 
if you can get reviewing time.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
