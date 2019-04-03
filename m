Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BBDC6C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 16:59:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F79D205C9
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 16:59:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="q2j3mqXe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F79D205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F31C06B0266; Wed,  3 Apr 2019 12:59:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE3276B0269; Wed,  3 Apr 2019 12:59:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD20E6B026A; Wed,  3 Apr 2019 12:59:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id B6DC36B0266
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 12:59:58 -0400 (EDT)
Received: by mail-vk1-f200.google.com with SMTP id d64so8059292vkg.7
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 09:59:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=gawuhcBgmNYwcXw+Qq+t0NbpqmKCtoHXDdE/SykUmVk=;
        b=X6alakLXNXG88UfAEeX0co/dlH9cBT1pI0QKhMB8ki3oGkSSi//S9s0nWtEWp6CevN
         yp5duBhf4leYhk5Moxk+g8E9qy+qnIFE5JeIwAFh7n3t1ueE5jvDOKf/XaNzC3N5sXWt
         uKa1gKP8XizqGZ8NRNZve7Bn/utae+27uMN/CbMie0rS8kjbD7d7XiG8srTkfD+mIX1t
         3kBs0MlnSkRWPmo3Qj3pa0MgEozwFcsNUx1Gx8LrtH9SvMBPmu/eEx3UyTFQP2vXhE8X
         aQSa/Y2OQYmEDiiL2i60oNKcFMJ6BkmaMhzfUehEAIwfYhiz3NrQ6bOLUpWMvB9n98Tn
         rcMA==
X-Gm-Message-State: APjAAAXUuA/oFBMV26N9vFIJPJBFk4bntZ8zAA6Mi3SS7brH7W+Cpu9Q
	RuPEkBFyc7uHPXN/9Lyu7Os0J/uixtVXXQV+3CmBSeqV9EEOWMKugPUsiYrPE4fnjNOKO9bvxFL
	jETwAhOw0awIX8ekxcjKM/Pk15/JmYMgdRvpkPIezERNEViiL4K6YjjGSijfcetB4Fg==
X-Received: by 2002:a67:fbc2:: with SMTP id o2mr1030817vsr.78.1554310798299;
        Wed, 03 Apr 2019 09:59:58 -0700 (PDT)
X-Received: by 2002:a67:fbc2:: with SMTP id o2mr1030752vsr.78.1554310797429;
        Wed, 03 Apr 2019 09:59:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554310797; cv=none;
        d=google.com; s=arc-20160816;
        b=EWaq4uafQ1tG30XfbUOkQT0pU7FrqwnaPVMqPULf2LgStrgh06HFVf72EQfYUkYWoW
         VfE7x/avNfU2XneIDzyeirx9SnGCRowVP1YthW9XUXXQmizEr7eA3Dv4lVB3wGVfh8AV
         Zz9FnFUmeV9+45cW73o6oyv6TlHROnTn/FZxqMTCt9qL631nW3AFGWbbYRx/9I09+/4w
         4AXP9cIRBNxuf7BQf1ML0Nzy6Utevkbyx73CzKpHt3iWQ2lmyeh1rftdOC3wntFjO//z
         Cm/wf7x0QCeIB9YreijwcaOnOC2k/ADVQtMFUDcunjmwWsv2l+czNEgUmHPp4uNnJ6Yh
         Szcw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=gawuhcBgmNYwcXw+Qq+t0NbpqmKCtoHXDdE/SykUmVk=;
        b=wcftbnjqtdJoHuMLd6a2oSg8TVmg8d85dzUmyFLa0sJcdx0b8QKGDyjXQqE1gNipfY
         i4a0RjXMd9hceUZANEAXothkgWjFfLKEJsq267gD7lziIlF/vY0K88JaVdt2DYJSUZTU
         15Leq7UxxehBRdsLk9b3J2/JjkllXnzrsftu0oPzKg8X6ag6TNvop5ETWBL2YdkuUD9Z
         zlcmNCq00zfwCuNX7xoQ/5QxwyY5RvfjSuSbHTYlBNUFJHpaMS4yIYAmajsILR5evrJW
         b9RCM0Ddk9lQWRZ0bZ4/0N9t+nOM3Y+ziLxC65UhSMg4Si+qOfSVAM/2NNQ5QhmQltRs
         0ssQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=q2j3mqXe;
       spf=pass (google.com: domain of matheusfillipeag@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=matheusfillipeag@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i18sor10411233uak.71.2019.04.03.09.59.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Apr 2019 09:59:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of matheusfillipeag@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=q2j3mqXe;
       spf=pass (google.com: domain of matheusfillipeag@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=matheusfillipeag@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=gawuhcBgmNYwcXw+Qq+t0NbpqmKCtoHXDdE/SykUmVk=;
        b=q2j3mqXeYaBttBjGMar6e9Qw8QYhhSutzKG3LptW0VJXYb7sPZB2ALhfrnTca/yWkA
         4v16Poz7rQ8YpIZUP+9+YUmzSstrKrcrjzazmgtzclRGCTrwzeiuyPM9BSonzY6AUSE2
         QPzemi3TP1+2dKyqoZG/B0Of/nL7XWuyP7XGggIlSH5cziOwBJ8zYfijJde9Cny+OVbL
         +7CdNVzcSdAAajTHy189Y38CcUxa2wOelmast7w9fH8mt4H7ZhryChEfp7TGCwRdxMW5
         QQ43aqp407b1ZuYeriK6nW6PMBtapmmak/aa3veDgiX2FdWCP3FZn439cw6kSC/gu9RS
         Hqbw==
X-Google-Smtp-Source: APXvYqx0bTYyV86fvOc6MHB46P+9RSfoz8k6gz6SkXV814bGIHSLPgE+E9eUmKytG/FZJESQ4jM7kPlbGLgjqke3L7I=
X-Received: by 2002:ab0:2814:: with SMTP id w20mr822998uap.97.1554310796743;
 Wed, 03 Apr 2019 09:59:56 -0700 (PDT)
MIME-Version: 1.0
References: <20140505233358.GC19914@cmpxchg.org> <5368227D.7060302@intel.com>
 <20140612220200.GA25344@cmpxchg.org> <539A3CD7.6080100@intel.com>
 <20140613045557.GL2878@cmpxchg.org> <539F1B66.2020006@intel.com>
 <20190402162500.def729ec05e6e267bff8a5da@linux-foundation.org>
 <20190403093432.GD8836@quack2.suse.cz> <1ea9f923-4756-85b2-6092-6d9e94d576a1@mailbox.org>
In-Reply-To: <1ea9f923-4756-85b2-6092-6d9e94d576a1@mailbox.org>
From: Matheus Fillipe <matheusfillipeag@gmail.com>
Date: Wed, 3 Apr 2019 13:59:45 -0300
Message-ID: <CAFWuBvcS-8AFZ4KoimMrLPjFXGE8a48QnSqV3_gajJNWYZymGA@mail.gmail.com>
Subject: Re: [Bug 75101] New: [bisected] s2disk / hibernate blocks on "Saving
 506031 image data pages () ..."
To: Rainer Fiebig <jrf@mailbox.org>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, 
	"Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	=?UTF-8?B?Um9kb2xmbyBHYXJjw61hIFBlw7FhcyAoa2l4KQ==?= <kix@kix.es>, 
	Oliver Winker <oliverml1@oli1170.net>, bugzilla-daemon@bugzilla.kernel.org, 
	linux-mm@kvack.org, Maxim Patlasov <mpatlasov@parallels.com>, 
	Fengguang Wu <fengguang.wu@intel.com>, Tejun Heo <tj@kernel.org>, 
	"Rafael J. Wysocki" <rjw@rjwysocki.net>, killian.de.volder@megasoft.be, 
	Atilla Karaca <atillakaraca72@hotmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Yes I can sorta confirm the bug is in uswsusp. I removed the package
and pm-utils and used both "systemctl hibernate"  and "echo disk >>
/sys/power/state" to hibernate. It seems to succeed and shuts down, I
am just not able to resume from it, which seems to be a classical
problem solved just by setting the resume swap file/partition on grub.
(which i tried and didn't work even with nvidia disabled)

Anyway uswsusp is still necessary because the default kernel
hibernation doesn't work with the proprietary nvidia drivers as long
as I know  and tested.

Is there anyway I could get any workaround to this bug on my current
OS by the way?

On Wed, Apr 3, 2019 at 7:04 AM Rainer Fiebig <jrf@mailbox.org> wrote:
>
> Am 03.04.19 um 11:34 schrieb Jan Kara:
> > On Tue 02-04-19 16:25:00, Andrew Morton wrote:
> >>
> >> I cc'ed a bunch of people from bugzilla.
> >>
> >> Folks, please please please remember to reply via emailed
> >> reply-to-all.  Don't use the bugzilla interface!
> >>
> >> On Mon, 16 Jun 2014 18:29:26 +0200 "Rafael J. Wysocki" <rafael.j.wysocki@intel.com> wrote:
> >>
> >>> On 6/13/2014 6:55 AM, Johannes Weiner wrote:
> >>>> On Fri, Jun 13, 2014 at 01:50:47AM +0200, Rafael J. Wysocki wrote:
> >>>>> On 6/13/2014 12:02 AM, Johannes Weiner wrote:
> >>>>>> On Tue, May 06, 2014 at 01:45:01AM +0200, Rafael J. Wysocki wrote:
> >>>>>>> On 5/6/2014 1:33 AM, Johannes Weiner wrote:
> >>>>>>>> Hi Oliver,
> >>>>>>>>
> >>>>>>>> On Mon, May 05, 2014 at 11:00:13PM +0200, Oliver Winker wrote:
> >>>>>>>>> Hello,
> >>>>>>>>>
> >>>>>>>>> 1) Attached a full function-trace log + other SysRq outputs, see [1]
> >>>>>>>>> attached.
> >>>>>>>>>
> >>>>>>>>> I saw bdi_...() calls in the s2disk paths, but didn't check in detail
> >>>>>>>>> Probably more efficient when one of you guys looks directly.
> >>>>>>>> Thanks, this looks interesting.  balance_dirty_pages() wakes up the
> >>>>>>>> bdi_wq workqueue as it should:
> >>>>>>>>
> >>>>>>>> [  249.148009]   s2disk-3327    2.... 48550413us : global_dirty_limits <-balance_dirty_pages_ratelimited
> >>>>>>>> [  249.148009]   s2disk-3327    2.... 48550414us : global_dirtyable_memory <-global_dirty_limits
> >>>>>>>> [  249.148009]   s2disk-3327    2.... 48550414us : writeback_in_progress <-balance_dirty_pages_ratelimited
> >>>>>>>> [  249.148009]   s2disk-3327    2.... 48550414us : bdi_start_background_writeback <-balance_dirty_pages_ratelimited
> >>>>>>>> [  249.148009]   s2disk-3327    2.... 48550414us : mod_delayed_work_on <-balance_dirty_pages_ratelimited
> >>>>>>>> but the worker wakeup doesn't actually do anything:
> >>>>>>>> [  249.148009] kworker/-3466    2d... 48550431us : finish_task_switch <-__schedule
> >>>>>>>> [  249.148009] kworker/-3466    2.... 48550431us : _raw_spin_lock_irq <-worker_thread
> >>>>>>>> [  249.148009] kworker/-3466    2d... 48550431us : need_to_create_worker <-worker_thread
> >>>>>>>> [  249.148009] kworker/-3466    2d... 48550432us : worker_enter_idle <-worker_thread
> >>>>>>>> [  249.148009] kworker/-3466    2d... 48550432us : too_many_workers <-worker_enter_idle
> >>>>>>>> [  249.148009] kworker/-3466    2.... 48550432us : schedule <-worker_thread
> >>>>>>>> [  249.148009] kworker/-3466    2.... 48550432us : __schedule <-worker_thread
> >>>>>>>>
> >>>>>>>> My suspicion is that this fails because the bdi_wq is frozen at this
> >>>>>>>> point and so the flush work never runs until resume, whereas before my
> >>>>>>>> patch the effective dirty limit was high enough so that image could be
> >>>>>>>> written in one go without being throttled; followed by an fsync() that
> >>>>>>>> then writes the pages in the context of the unfrozen s2disk.
> >>>>>>>>
> >>>>>>>> Does this make sense?  Rafael?  Tejun?
> >>>>>>> Well, it does seem to make sense to me.
> >>>>>>  From what I see, this is a deadlock in the userspace suspend model and
> >>>>>> just happened to work by chance in the past.
> >>>>> Well, it had been working for quite a while, so it was a rather large
> >>>>> opportunity
> >>>>> window it seems. :-)
> >>>> No doubt about that, and I feel bad that it broke.  But it's still a
> >>>> deadlock that can't reasonably be accommodated from dirty throttling.
> >>>>
> >>>> It can't just put the flushers to sleep and then issue a large amount
> >>>> of buffered IO, hoping it doesn't hit the dirty limits.  Don't shoot
> >>>> the messenger, this bug needs to be addressed, not get papered over.
> >>>>
> >>>>>> Can we patch suspend-utils as follows?
> >>>>> Perhaps we can.  Let's ask the new maintainer.
> >>>>>
> >>>>> Rodolfo, do you think you can apply the patch below to suspend-utils?
> >>>>>
> >>>>>> Alternatively, suspend-utils
> >>>>>> could clear the dirty limits before it starts writing and restore them
> >>>>>> post-resume.
> >>>>> That (and the patch too) doesn't seem to address the problem with existing
> >>>>> suspend-utils
> >>>>> binaries, however.
> >>>> It's userspace that freezes the system before issuing buffered IO, so
> >>>> my conclusion was that the bug is in there.  This is arguable.  I also
> >>>> wouldn't be opposed to a patch that sets the dirty limits to infinity
> >>>> from the ioctl that freezes the system or creates the image.
> >>>
> >>> OK, that sounds like a workable plan.
> >>>
> >>> How do I set those limits to infinity?
> >>
> >> Five years have passed and people are still hitting this.
> >>
> >> Killian described the workaround in comment 14 at
> >> https://bugzilla.kernel.org/show_bug.cgi?id=75101.
> >>
> >> People can use this workaround manually by hand or in scripts.  But we
> >> really should find a proper solution.  Maybe special-case the freezing
> >> of the flusher threads until all the writeout has completed.  Or
> >> something else.
> >
> > I've refreshed my memory wrt this bug and I believe the bug is really on
> > the side of suspend-utils (uswsusp or however it is called). They are low
> > level system tools, they ask the kernel to freeze all processes
> > (SNAPSHOT_FREEZE ioctl), and then they rely on buffered writeback (which is
> > relatively heavyweight infrastructure) to work. That is wrong in my
> > opinion.
> >
> > I can see Johanness was suggesting in comment 11 to use O_SYNC in
> > suspend-utils which worked but was too slow. Indeed O_SYNC is rather big
> > hammer but using O_DIRECT should be what they need and get better
> > performance - no additional buffering in the kernel, no dirty throttling,
> > etc. They only need their buffer & device offsets sector aligned - they
> > seem to be even page aligned in suspend-utils so they should be fine. And
> > if the performance still sucks (currently they appear to do mostly random
> > 4k writes so it probably would for rotating disks), they could use AIO DIO
> > to get multiple pages in flight (as many as they dare to allocate buffers)
> > and then the IO scheduler will reorder things as good as it can and they
> > should get reasonable performance.
> >
> > Is there someone who works on suspend-utils these days? Because the repo
> > I've found on kernel.org seems to be long dead (last commit in 2012).
> >
> >                                                               Honza
> >
>
> Whether it's suspend-utils (or uswsusp) or not could be answered quickly
> by de-installing this package and using the kernel-methods instead.
>
>

