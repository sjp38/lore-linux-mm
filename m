Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 6B80C6B004D
	for <linux-mm@kvack.org>; Tue,  7 Aug 2012 15:38:35 -0400 (EDT)
Date: Tue, 7 Aug 2012 15:28:07 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH 0/4] promote zcache from staging
Message-ID: <20120807192807.GA2089@phenom.dumpdata.com>
References: <1343413117-1989-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <b95aec06-5a10-4f83-bdfd-e7f6adabd9df@default>
 <20120727205932.GA12650@localhost.localdomain>
 <d4656ba5-d6d1-4c36-a6c8-f6ecd193b31d@default>
 <5016DE4E.5050300@linux.vnet.ibm.com>
 <f47a6d86-785f-498c-8ee5-0d2df1b2616c@default>
 <20120731155843.GP4789@phenom.dumpdata.com>
 <20120731161916.GA4941@kroah.com>
 <20120731175142.GE29533@phenom.dumpdata.com>
 <20120806003816.GA11375@bbox>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="rwEMma7ioTxnRzrJ"
Content-Disposition: inline
In-Reply-To: <20120806003816.GA11375@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, devel@driverdev.osuosl.org, Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Konrad Rzeszutek Wilk <konrad@darnok.org>, Andrew Morton <akpm@linux-foundation.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>


--rwEMma7ioTxnRzrJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Aug 06, 2012 at 09:38:16AM +0900, Minchan Kim wrote:
> Hi Konrad,
> 
> On Tue, Jul 31, 2012 at 01:51:42PM -0400, Konrad Rzeszutek Wilk wrote:
> > On Tue, Jul 31, 2012 at 09:19:16AM -0700, Greg Kroah-Hartman wrote:
> > > On Tue, Jul 31, 2012 at 11:58:43AM -0400, Konrad Rzeszutek Wilk wrote:
> > > > So in my head I feel that it is Ok to:
> > > > 1) address the concerns that zcache has before it is unstaged
> > > > 2) rip out the two-engine system with a one-engine system
> > > >    (and see how well it behaves)
> > > > 3) sysfs->debugfs as needed
> > > > 4) other things as needed
> > > > 
> > > > I think we are getting hung-up what Greg said about adding features
> > > > and the two-engine->one engine could be understood as that.
> > > > While I think that is part of a staging effort to clean up the
> > > > existing issues. Lets see what Greg thinks.
> > > 
> > > Greg has no idea, except I want to see the needed fixups happen before
> > > new features get added.  Add the new features _after_ it is out of
> > > staging.
> > 
> > I think we (that is me, Seth, Minchan, Dan) need to talk to have a good
> > understanding of what each of us thinks are fixups.
> > 
> > Would Monday Aug 6th at 1pm EST on irc.freenode.net channel #zcache work
> > for people?
> 
> 1pm EST is 2am KST(Korea Standard Time) so it's not good for me. :)
> I know it's hard to adjust my time for yours so let you talk without
> me. Instead, I will write it down my requirement. It's very simple and
> trivial.

OK, Thank you.

We had a lengthy chat (full chat log attached). The summary was that
we all want to promote zcache (for various reasons), but we are hang up
whether we are OK unstaging it wherein it lowers the I/Os but potentially
not giving large performance increase (when doing 'make -jN') or that we
want both of those characteristics in. Little history: v3.3 had
swap readahead patches that made the amount of pages going in swap dramatically
decrease - as such the performance of zcache is not anymore amazing, but ok.

Seth and Robert (and I surmise Minchan too) are very interested in zcache
as its lowers the amount of I/Os but performance is secondary. Dan is interested
in having less I/Os and providing a performance boost with the such workloads as
'make -jN' - in short less I/Os and better performance. Dan would like both
before unstaging.

The action items that came out are:
 - Seth posted some benchmarks - he is going to rerun them with v3.5
   to see how it behaves in terms of performance (make -jN benchmark).
 - Robert is going to take a swing at Minchan refactor and adding comments, etc
   (But after we get over the hump of agreeing on the next step).
 - Konrad to rummage in his mbox to find any other technical objections
   that were raised on zcache earlier to make sure to address them.
 - Once Seth is finished Konrad is going to take another swing
   at driving this discussion - either via email, IRC or conference call.


--rwEMma7ioTxnRzrJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="zcache-Aug6.log"

Aug 06 11:38:41 *	Now talking on #zcache
Aug 06 11:38:41 *	cameron.freenode.net sets mode +n #zcache
Aug 06 11:38:41 *	cameron.freenode.net sets mode +s #zcache
Aug 06 12:38:15 *	sjennings (~sjennings@2001:470:1f0f:87d:e46c:7cd1:4974:640b) has joined #zcache
Aug 06 12:49:12 *	rcj (~rcjenn@32.97.110.59) has joined #zcache
Aug 06 12:50:26 *	djm1 (~djm1021@inet-hqmc03-o.oracle.com) has joined #zcache
Aug 06 12:50:29 <rcj>	Good morning Konrad, thanks for suggesting this.
Aug 06 12:50:32 *	darnok (~konrad@209-6-85-33.c3-0.smr-ubr2.sbo-smr.ma.cable.rcn.com) has joined #zcache
Aug 06 12:50:47 <djm1>	hi all, first time user for freenode so I had to register, sorry to be late
Aug 06 12:50:53 <djm1>	(this is Dan Magenheimer)
Aug 06 12:51:17 <darnok>	djm1, I think you can be just an unregister user?
Aug 06 12:51:36 <konrad>	rcj, Sure thinkg
Aug 06 12:51:51 *	darnok goes away now that the proper Konrad is in place
Aug 06 12:52:08 <djm1>	konrad/darnok: ok, we can deal with that later, for now, "call me djm1"
Aug 06 12:52:22 <konrad>	Sure. So I think we are all here right? Minchan couldn't make it
Aug 06 12:52:38 <sjennings>	i don't know of anyone else that was planning to come
**** ENDING LOGGING AT Mon Aug  6 12:52:39 2012

**** BEGIN LOGGING AT Mon Aug  6 12:52:39 2012

Aug 06 12:52:46 <rcj>	Sounds good
Aug 06 12:52:59 *	konrad nods.
Aug 06 12:53:18 <konrad>	Let me first start by saying thank you for being able to make it.
Aug 06 12:53:42 <konrad>	Sometimes it takes a whole bunch of iterations to setup a call but this worked out fine.
Aug 06 12:53:46 *	darnok has quit (Read error: Operation timed out)
Aug 06 12:54:10 <konrad>	And also for the interest in zcache/tmem/frontswap/cleanpage/future ideas.
Aug 06 12:55:11 <konrad>	I think we all want all the pieces completely out of staging (irregardlesss of how internally each company uses the technologies - we have been shipping it with our kernel - UEK2)
Aug 06 12:55:55 <rcj>	We do want it out of staging, for us we can't use it until it's out so it's a bit more critical in that way.
Aug 06 12:55:55 <konrad>	But for right now the zcache is on the plate since that can be used in numerous ways.
Aug 06 12:56:09 *	djm1 makes minor correction... we are shipping frontswap and cleancache and the xen shim in UEK2, not zcache
Aug 06 12:56:21 <konrad>	djm1, Ah thats right. 
Aug 06 12:56:33 *	konrad puts on his bigger TODO list to address that.
Aug 06 12:57:07 <djm1>	rcj: right, we can't use it while its in staging either
Aug 06 12:57:27 <djm1>	UEK2 did jump the gun on frontswap though
Aug 06 12:57:48 <konrad>	rcj, With the 'can't use it' is it more of a .. support type question? Meaning that once it gets its equal to the being almost bug-free?
Aug 06 12:58:19 <djm1>	I think "officially" anything in staging results in a tainted kernel, though I don't know how that applies to distros
Aug 06 12:58:32 <rcj>	Trying to parse that last sentence konrad 
Aug 06 12:58:35 <konrad>	rcj, I am trying here to figure out if the "unstaging" part that is critical to you is in terms of code quality or some other criteria.
Aug 06 12:59:31 *	sashal (~sasha@95-89-78-76-dynip.superkabel.de) has joined #zcache
Aug 06 12:59:33 <konrad>	rcj, As that leads directly to what is the upmost important in zcache for you guys
Aug 06 12:59:41 <sjennings>	the distros we work with only accept mainline drivers/code, not staging
Aug 06 12:59:42 <rcj>	konrad, quality is a different discussion.  Quality has to be there.
Aug 06 12:59:50 <konrad>	Hey Sasha. Let me paste to you on a side-channel what we said so far.
Aug 06 12:59:58 <sashal>	konrad, thanks
Aug 06 13:00:20 <konrad>	sashal, Hopefully your client won't ban me for pasting too fast.
Aug 06 13:00:32 <djm1>	sashal: welcome!
Aug 06 13:00:38 *	djm1 is dan.magenheimer
Aug 06 13:01:05 <sjennings>	my interest is using frontswap/cleancache/zcache for in-kernel memory compression.  no xen, no kvm
Aug 06 13:01:07 <sashal>	djm1, hey!
Aug 06 13:01:10 <konrad>	sjennings, rcj : OK, so its the 'feature' needs to be in the mainline before they will accept turning it on. Somehow I thought staging would be part of it since Fedora has some bits turned for that.
Aug 06 13:02:43 <konrad>	sjennings, rcj , djm1 : But didn't realize the tainting part of the code? Ah yes: 2564                 add_taint_module(mod, TAINT_CRAP);
Aug 06 13:03:05 <sjennings>	yes, that looks bad in the dmesg of enterprise distros
Aug 06 13:03:27 *	konrad nods
Aug 06 13:03:57 <konrad>	Then it comes down to: time-line and resources
Aug 06 13:04:19 <djm1>	konrad: well, yes, and the small matter of technical solutions too ;-)
Aug 06 13:04:28 <sjennings>	i sent out the promotion patch because we find value in zcache as it is right now
Aug 06 13:05:12 <sjennings>	it is stable and, as both Dan and I have demostrated, has measurable benefits (I/O reduction and sometime speed)
Aug 06 13:05:14 <konrad>	sjennings, OK. so the aim for getting it out in v3.6 is .. an optimistic hope not a real I-MUST-GET-IT-NOW type.
Aug 06 13:05:18 <rcj>	sjennings, and there are other contributors that are in same situation where they are using zcache as it exists. 
Aug 06 13:06:46 <sjennings>	well, it's for 3.7 now, and the promotion patch should either work or tell us what showstoppers remain the prevent promotion
Aug 06 13:07:00 <djm1>	sjennings: two things... I recall Dave Hansen stating fairly clearly a year ago that zcache was not near suitable for promoting... is he happy?
Aug 06 13:07:25 <djm1>	second, have you measured zcache/non-zcache results on a recent kernel?
Aug 06 13:08:13 <sjennings>	depends on how recent your talking about.  i posted my zcache performance number on v3.4 i think
Aug 06 13:08:30 <sjennings>	i consider that recent
Aug 06 13:09:35 *	djm1 thinks it was 3.2, not sure, but Rik Van Riel made a lot of swap subsystem improvements in the last couple of kernels... I suggest rerunning at least a couple of benchmarks (especially something swap heavy)
Aug 06 13:10:46 <sjennings>	seems like that would only make zcache, in it currently form, more useful
Aug 06 13:10:46 <konrad>	djm1, Nothing big in v3.4: konrad@phenom:~/ssd/linux$ git log --oneline  v3.4..v3.5 mm/swapfile.c
Aug 06 13:10:46 <konrad>	9b15b81 swap: fix shmem swapping when more than 8 areas
Aug 06 13:10:46 <konrad>	a3fe778 Merge tag 'stable/frontswap.v16-tag' of git://git.kernel.org/pub/scm/linux/kernel/git/konrad/mm
Aug 06 13:10:46 <konrad>	4b91355 memcg: fix/change behavior of shared anon at moving task
Aug 06 13:10:46 <konrad>	bde05d1 shmem: replace page if mapping excludes its zone
Aug 06 13:10:46 <konrad>	38b5faf mm: frontswap: core swap subsystem hooks and headers
Aug 06 13:12:20 <konrad>	djm1, So I think that is OK for v3.4 perf perspective?
Aug 06 13:12:36 <konrad>	sjennings, These weren't benchmark with other patches on top? Like the WasActive one that Dan came up with?
Aug 06 13:13:25 <sjennings>	no, i used the mainline + frontswap (before it was mainlined in v3.5)
Aug 06 13:13:43 <rcj>	djm1, If dhansen has specific issues he'll need to speak for them in this promotion process.
Aug 06 13:13:54 <djm1>	sjennings: you ran your benchmarks before I was at LSF/MM and I think 3.3 was released that weekend
Aug 06 13:14:07 <djm1>	https://lkml.org/lkml/2012/4/16/449
Aug 06 13:14:23 <djm1>	here's one of the Rik van Riel patches
Aug 06 13:16:42 <djm1>	sjennings: after rik's patches went in, the "non-zcache" times dropped dramatically
Aug 06 13:18:11 <sjennings>	zcache's primary benefit for me is reduced I/O
Aug 06 13:18:29 <sjennings>	just because swap on rotational media is faster now, doesn't make zcache unneeded
Aug 06 13:18:57 <sjennings>	not all linux machines use rotational swap media (i.e. phones)
Aug 06 13:18:58 <djm1>	sjennings: believe me, I am not arguing that zcache is not needed, just that we now have a lot more work/tuning to do
Aug 06 13:19:42 <rcj>	djm1, but there will always be interactions that drive work.
Aug 06 13:20:48 <rcj>	djm1, having zcache in staging or mainline is orthogonal.  In fact, in mainline a patch that causes a regression for zcache might get more attention.
Aug 06 13:23:15 <djm1>	rcj: sorry, I'm not sure I understand your point
Aug 06 13:23:59 <djm1>	I am suggesting that the benchmarks Seth and I ran and posted, if rerun today on 3.4/3.5 would look horrible
Aug 06 13:24:58 <sjennings>	how is Rik's patchset going to reduce I/O like zcache does?
Aug 06 13:25:05 <djm1>	(correction: some of them look horrible)
Aug 06 13:25:26 <sjennings>	if anything, it increases I/O be doing more aggressive readahead
Aug 06 13:25:39 <rcj>	djm1, You brought up Rik's patch improving swap performance without zcache.  You're saying that zcache needs to improve.  That's not a zcache regression.  The kernel is improving in the swap area for some cases, that's great.  So then we take a TODO to worrk on zcache swap performance or elevate the priority of that work. it's not a blocker.
Aug 06 13:25:47 <djm1>	sjennings: good question... I don't know for sure... but they dramatically increase performance
Aug 06 13:26:34 <djm1>	rcj: are you saying that zcache is useful regardless of whether it increases performance?
Aug 06 13:27:29 <djm1>	(or are you saying you have measured it on non-rotating and it DOES increase performance there, and so you don't care if whether it increases performance on rotating?)
Aug 06 13:27:56 <djm1>	(measured on 3.4/3.5...)
Aug 06 13:27:59 <rcj>	djm1, I'm saying that there are other measures as Seth is pointing out.
Aug 06 13:28:02 <konrad>	djm1, Does it matter? The goal is to have limited amount of I/Os.
Aug 06 13:28:55 *	sjennings what konrad said
Aug 06 13:28:55 <konrad>	djm1, well, let me redact that. .. and not have horrible performance .
Aug 06 13:28:58 <djm1>	konrad,rcj: to me, reduced I/O and better performance are directly correlated, unless the bottleneck is the cpu of course
Aug 06 13:30:01 <djm1>	sjennings, ok, then please rerun your benchmarks on 3.4 or 3.5, and look at whether zcache reduced I/Os vs non-zcache
Aug 06 13:31:21 <konrad>	djm1, You are thinking is that it does not? Or that it does reduce I/O but the perf overall goes down?
Aug 06 13:31:30 <sjennings>	i can do that, but those numbers don't negate our point.  this change in behavior isn't a bug in zcache
Aug 06 13:32:16 <djm1>	sjennings: ok, then let's start over from objectives: I think you said you want to promote zcache because it reduces I/O
Aug 06 13:33:37 <djm1>	I am agreeing that on 3.2 it did, but I have seen on 3.4 performance for non-zcache has improved dramatically, so I believe zcache no longer reduces I/O over non-zcache
Aug 06 13:34:53 <sjennings>	i'm i correct in understand rik's patch to make swap readahead more agressive?
Aug 06 13:35:12 <djm1>	it MAY be the case that the number of I/Os has improved dramatically for non-zcache, but the number of pages read/written for zcache is better than non-zcache
Aug 06 13:35:15 <sjennings>	*am i
Aug 06 13:36:30 <djm1>	sjennings: yes, that is one of rik's patches, there were several and I didn't look at all of them carefully
Aug 06 13:37:47 <sjennings>	we need to come back around on this though.  we want promotion.  what are the absolute showstoppers to prevent this.  that is bugs or hard numbers that demonstrate the zcache has no value now (since previous number indictated it did have value)
Aug 06 13:38:52 <rcj>	sjennings, This doesn't affect cleancache and it doesn't break frontswap, it just improves other kernel code.  There will always be work, but I don't see that gating mainline acceptance.
Aug 06 13:38:56 <konrad>	sjennings, The ones that Minchin identified were cleanups and refactor of code to make it more readable. No zcache engine replacement.
Aug 06 13:40:01 <rcj>	konrad, that sort of patch can go in anytime though.  I could send out patchess to clean-up and refactor mainline code.
Aug 06 13:40:07 <djm1>	rcj: please help me understand... you want to promote zcache because it improved performance on older kernels even if it doesn't on current kernels?
Aug 06 13:41:13 <djm1>	sjennings: the hard numbers clearly demonstrate that the existing zcache has much less value now
Aug 06 13:42:22 <rcj>	djm1, I don't see you presenting numbers though, only saying that it "may" affect performance. So send out performance patches.  Even if Rik never sent out his patches, could zcache stand performance work?  Could any part of the kernel take performance patches?  I don't see this as a gate to mainline.
Aug 06 13:42:53 <djm1>	rcj: please answer my question, you have avoided it
Aug 06 13:43:36 <konrad>	djm1, Is your thought that the answer to the performance numbers are the zcache2 different engine? Or the different algorithm for dealing with pages?
Aug 06 13:43:40 <djm1>	it is true I don't wish to shoot myself in the foot by publicly showing that zcache sucks now, but nor do I want to put my sign-off on promoting it while hiding the knowledge that it does
Aug 06 13:45:01 <djm1>	konrad: yes, I've sent many emails (offlist, and one or two on) about the design flaws of the "demo" zcache...
Aug 06 13:45:55 <konrad>	djm1, So what you are saying is that zcache2 by itself , if it was in v3.3 would show phenomal numbers, not just good.
Aug 06 13:46:25 <rcj>	djm1, I can't answer general questions unless we're talking real numbers.  The code is in public and the development should be as well.
Aug 06 13:46:26 <konrad>	djm1, And when measuring it with v3.5, it shows good  respectible numbers.
Aug 06 13:46:45 <djm1>	konrad: sadly no, my hand was forced to release the current status
Aug 06 13:47:30 <konrad>	djm1, So what you are saying is that you want to continue on working on thsi until you do get to that point
Aug 06 13:47:53 <konrad>	djm1, But that might take longer than a couple of releases and one might as well just drop in the new code.
Aug 06 13:47:58 <djm1>	rcj: ok, let me give you two numbers off the top of my head... Seth's published measurement 1700 seconds on zcache, 2000 non-zcache.
Aug 06 13:48:15 <djm1>	New measurement on non-zcache 3.5: 800 seconds
Aug 06 13:48:46 <sjennings>	did you use my machine?
Aug 06 13:48:56 <sjennings>	they aren't comparable
Aug 06 13:49:13 <sjennings>	plus i'm talking about I/O
Aug 06 13:49:29 <djm1>	sjennings: I am inviting you to use your machine and re-measure, or to admit you don't care what the new numbers are
Aug 06 13:50:08 *	konrad sighs.
Aug 06 13:50:33 <konrad>	I was hoping to have a clear define ACTION LISTs out of this and it seems we have at least two:
Aug 06 13:50:44 <konrad>	  1).   I could send out patchess to clean-up and refactor mainline code
Aug 06 13:50:59 <konrad>	 2). Run existing benchmarks against v3.5 using zcache/non-zcache
Aug 06 13:51:42 <sjennings>	doing 1 won't resolve djm1 objections though
Aug 06 13:52:35 <konrad>	djm1, So Dan, if the numbers on sjennings show no perf degradation, or his tests on v3.5 show good numbers, I believe you would be OK with the current zcache code right?
Aug 06 13:52:56 <konrad>	sjennings, True. Just going through the action items to jot them down.
Aug 06 13:54:36 <djm1>	konrad: if sjennings runs the same benchmarks as he previously published on 3.5 and zcache performance always beats non-zcache performance, that is a big step in the right direction
Aug 06 13:55:12 <djm1>	konrad: but knowing the design flaws in zcache I can fairly easily find benchmarks for which it is not the case
Aug 06 13:55:20 <konrad>	djm1, If they show horrible perf that is tried in with the generic swap system... then what? Your drop-in does not necessarily fixes it, and it might be a swap system issue. Which is why rcj proposoal to move with the unstaging as soon as possible so that we aren't behind with this is the right thing
Aug 06 13:55:52 <konrad>	djm1, OK, but some benchmarks are so synthethic that they bear no resemblence to real world scenario. 
Aug 06 13:56:58 <konrad>	djm1, But the design flaws discussion is something that can be addressed later too.
Aug 06 13:58:17 <rcj>	"Lies, damn lies, and statistics", right?  Seth was talking about IOPs being reduced and Dan's talking about # seconds to run kern-bench which are different, you can always find some benchmark that falls down.  But that doesn't mean there isn't some value still. zcache is not a panacea but does have use-cases.
Aug 06 13:58:41 <konrad>	rcj: Heh
Aug 06 13:59:19 <rcj>	And with measurements you can understand the problem and address it.  But the question about promotion isn't necessarily resolved that way.
Aug 06 13:59:58 *	rcj re-reads the second sentence and needs to restate...
Aug 06 14:00:26 <djm1>	rcj: please re-run the same benchmarks as sjennings ran in March, measure all three: seconds, pages of I/O and number of I/Os and then let's discuss further
Aug 06 14:01:27 <sjennings>	djm1, regarding the step in the right direction comment, i need to know what evidence would be required for you to drop your objection to promotion before i go through all the trouble of producing that evidence.
Aug 06 14:01:53 <sjennings>	if i can show that zcache reduces I/O during a kernel build with a 3.5 kernel, is that enouhg
Aug 06 14:02:34 <djm1>	sjennings: across the same range of -jN?
Aug 06 14:02:39 <sjennings>	sure
Aug 06 14:03:16 <djm1>	number of pages of I/O or number of I/Os? (and I ask that for a very specific reason)
Aug 06 14:03:50 <konrad>	djm1, So I am curious. If this discussion was done in v3.3 day-time - would the issue of the design of zcache be on the table?
Aug 06 14:04:04 <konrad>	djm1, Or the rewrite or the benchmarks?
Aug 06 14:05:04 <djm1>	konrad: good question... yes, we had this discussion offlist prior to v3.3 (and I think you were cc'ed)
Aug 06 14:05:35 <djm1>	at that point, zcache was "good" and I was trying to make it "better", now I fear that it sucks and I am trying to make it at least "good"
Aug 06 14:07:19 <djm1>	rcj, sjennings: I have worked in a big company for 30 years, I understand you have constraints, and I can only guess what is driving this
Aug 06 14:07:51 <djm1>	I suspect that IBM has a contractual obligation to deliver this in some embedded system which uses SSD/NVRAM
Aug 06 14:08:31 <sjennings>	djm1, our motivation is not relevant
Aug 06 14:08:41 <rcj>	sjennings, and the community doesn't care.
Aug 06 14:08:44 <djm1>	so to answer sjennings question, if zcache is truly going to be used successfully by real users, no, I don't think I want to get in the way of that
Aug 06 14:08:50 <sjennings>	this code is of value to use and others
Aug 06 14:09:03 <sjennings>	s/use/us
Aug 06 14:10:00 <sjennings>	and improvements can continue to be made
Aug 06 14:10:09 <djm1>	sjennings: restating that and ignoring what I am telling you and refusing to measure it for yourself doesn't help
Aug 06 14:11:21 <djm1>	rcj: the community most certainly does care... had Seth and I never published *amazing* zcache numbers (compared to native), we wouldn't be having this conversation
Aug 06 14:12:03 <rcj>	djm1, I was just saying that the community doesn't care about motivations
Aug 06 14:12:10 <djm1>	by promoting zcache based on those numbers, it makes me feel disingenous, if not just dirty
Aug 06 14:12:18 <konrad>	djm1, I think you made your point. You would like Seth to do some benchmarking to verify the perf numbers.
Aug 06 14:12:35 <konrad>	djm1, And if they do not work right, then address those before promoting it.
Aug 06 14:13:34 <sjennings>	but we don't agree on what "work right" is
Aug 06 14:13:43 <sjennings>	how are we defining that
Aug 06 14:14:02 <sjennings>	i define it in reduced I/O (even if runtime is longer)
Aug 06 14:15:21 <djm1>	which is why motivation is relevant
Aug 06 14:16:04 <konrad>	djm1, motivation==use case I think?
Aug 06 14:16:09 <djm1>	if this is the classic battle: "which is more important? enterprise or embedded" then let's call it that
Aug 06 14:16:55 <djm1>	konrad: yes, but "my use case runs faster so I don't care if yours run slower, just don't use it"
Aug 06 14:17:57 <konrad>	djm1, So your concern is with .. I can't seem to find in the log here
Aug 06 14:18:22 <djm1>	sjennings, rcj: so IMHO zram is the right match for you then... what is it about zcache that solves your problem better than zram?
Aug 06 14:19:42 <konrad>	djm1, Ah, speed. Workloads running faster.
Aug 06 14:23:19 *	djm1 goes afk
Aug 06 14:26:03 <konrad>	djm1, Um, hope you won't be long afk
Aug 06 14:27:02 <sjennings>	i'll post numbers on the v3.5 kernel
Aug 06 14:27:20 <konrad>	sjennings, OK.
Aug 06 14:27:31 <konrad>	sjennings, Thank you.
Aug 06 14:27:45 *	sashal has quit (Excess Flood)
Aug 06 14:28:05 *	sashal (~sasha@95-89-78-76-dynip.superkabel.de) has joined #zcache
Aug 06 14:28:21 <konrad>	sashal, Last thing said was: "<sjennings> i'll post numbers on the v3.5 kernel
Aug 06 14:28:21 <konrad>	<konrad> sjennings, OK.
Aug 06 14:28:21 <konrad>	<konrad> sjennings, Thank you."
Aug 06 14:29:00 <konrad>	sjennings, rcj , djm1 : I thought this would be only an hour but it went for an hour and half. Yikes.
Aug 06 14:29:21 <konrad>	sjennings, rcj : I hope it doesn't negatively impact your guys schedule for today.
Aug 06 14:30:08 <konrad>	sjennings, rcj djm1 :I think it makes sense to one more discussion about this after Seth has the opportunity to run the numbers.
Aug 06 14:30:32 <konrad>	sjennings, rcj djm1 sashal : Would thsi time work next week? Would a conference call be better than IRC?
Aug 06 14:30:57 <rcj>	konrad, IRC is better, this needs to be completely public.  On-list would be better.
Aug 06 14:31:31 <rcj>	konrad, I just don't want to see barriers to people being involved in a discussion.
Aug 06 14:31:55 <konrad>	rcj, Good point. .. I am thinking of more of removing some of the barriers by having folks in one location so to speak.
Aug 06 14:32:27 <rcj>	konrad, I understand completely.  Just trying to find a good balance.
Aug 06 14:33:27 <konrad>	sjennings, djm1, rcj,  So let me write a summary of this and also save the full log as an attachment.
Aug 06 14:33:30 <rcj>	konrad, I'm still worried by the premise of the objection.  That a non-zcache patch has improved performance somewhere else in the kernel and this poses a barrier to mainline inclusion.
Aug 06 14:34:52 <konrad>	rcj, Right. Thought not for embedded side. The things that Andrew Morton pointed out is that he would like zcache be enabled by default.
Aug 06 14:36:07 <konrad>	rcj, And Dan is trying to make that happen. But if the enablement of zcache does not benefit  on nowadays desktops..Then it should not be enabled by default.
Aug 06 14:36:37 <konrad>	rcj, And then it comes back to Andrew having a potential issue with zcache. So Dan is trying to make sure that this issue will not surface.
Aug 06 14:37:04 <konrad>	rcj, But the other side of the coin is that if its used in the embedded side then it does not matter.
Aug 06 14:37:51 <konrad>	rcj, Which I believe is what you guys are coming from.
Aug 06 14:38:58 <rcj>	konrad, We don't know the other show-stoppers because the conversation got killed pretty early on-list.
Aug 06 14:40:37 <konrad>	rcj, Ugh. OK.
Aug 06 14:41:32 <konrad>	rcj, Let me see what I have in the mbox and if I can compile to something similar to what Seth did for frontswa
Aug 06 14:42:08 <konrad>	Well, I have to head out, other things are showing up in my calendar
Aug 06 14:42:48 <rcj>	konrad, thanks.
Aug 06 14:43:13 <konrad>	sjennings, rcj djm1 sashal : Gotta go. I think the two TODOs are: 1). Seth run v3.5 w/ zcache and w/o zcache; 2) Konrad to rummage in his mbox to find earlier objections to zcache
Aug 06 14:43:27 *	djm1 returnsm apparently too late
Aug 06 14:43:54 <rcj>	konrad, sounds good.
Aug 06 14:44:00 <konrad>	sjennings, rcj djm1 sashal : 3) Propose to continue this on mailing list for the more broader topics, while the more fine one - on IRC.
Aug 06 14:44:17 <konrad>	.. and also get Minchan involved here.
Aug 06 14:44:44 *	konrad is away
Aug 06 15:01:14 *	sashal has quit (Ping timeout: 240 seconds)
Aug 06 15:42:06 *	sashal (~sasha@95-89-78-76-dynip.superkabel.de) has joined #zcache
Aug 06 16:20:00 *	rcj has quit (Quit: rcj)
Aug 06 17:03:01 *	sjennings has quit (Quit: Leaving)
Aug 07 12:17:29 *	Disconnected (Connection reset by peer).

--rwEMma7ioTxnRzrJ--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
