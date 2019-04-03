Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7185C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 19:08:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4AB2C20700
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 19:08:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="s4ntdBnf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4AB2C20700
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E5D1F6B000A; Wed,  3 Apr 2019 15:08:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE50A6B000C; Wed,  3 Apr 2019 15:08:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C5F1B6B000D; Wed,  3 Apr 2019 15:08:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id 883926B000A
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 15:08:41 -0400 (EDT)
Received: by mail-vk1-f200.google.com with SMTP id z75so69652vkd.2
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 12:08:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ygBGJ1w/RCoDaXYVhjgmvEDwEcg1cbZCgHzJuZ1tBus=;
        b=gu+s3sPiHvwR8nCyZvEo3qdq2klcvTKGEh5kFVmmNHL7GSQ3Ysw9nCQoEGO4DaOFDv
         lgSLbjEspEclXPk1xMGaUGfcmN568NHs2J9vUexZzburlTI3JEFrn+T6M5PAG/Zo1O/E
         pvwmdAlzYQAaVv41GbK7zYoPFvdIyPNeY5xxI4Uu9xpoEAi2DImJdvFxjBFyolqSMd6s
         9hNWiMpMA95nVygrt/5h4UDjyILeBUrqQHnAjNj+v4QAUhLS+qpS7vxL3vlZte7TdAGx
         R7mxIsIHU99Kl3WT1o+E3vckOXPQi9js0EuiDSADRV9rLtdjen5ZSIbMJBGbrNgi4BKi
         6LTg==
X-Gm-Message-State: APjAAAW1+4bREnGzXA7AY6H9CdO1xc8Kj/YS0JBXtsr0VcKYy4gb2KEq
	w1PfUpJ+l5jMSZ4CQafRSmFur3r3FcUIiyMz/6HQHmjkoG6xvMU/4rDc1UaASh50C9Ub0mB2ooN
	n1a1hMLDDGnmr9a9moPG2hOnHSYdlPK8QTnekiS7DwzxEciPetdqloXNf+f2vtcfT5A==
X-Received: by 2002:a67:7d91:: with SMTP id y139mr1443525vsc.168.1554318521130;
        Wed, 03 Apr 2019 12:08:41 -0700 (PDT)
X-Received: by 2002:a67:7d91:: with SMTP id y139mr1443443vsc.168.1554318520028;
        Wed, 03 Apr 2019 12:08:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554318520; cv=none;
        d=google.com; s=arc-20160816;
        b=ibLq3iWttSyxVlotivNLLzTSIVDm5etOaQnQ7/R1C4GBvQiXmM9nLRcIYMenuHlFj3
         vUObEYJcy6qbEBiIbWOr8Vet+NPzHmSYpXOPB60ySNXOAIYNF9MANhQ4ctWTyxX6eHMf
         nei3xHx0R4yt3kCqoPiLaj0J+/IQWqvtMjuH5BcLbBFhKdEhGa7Mt3FKWoTEJnO1mBVC
         wkK9z7LX673hewipkvNDyyRSO9QgYPepWfeOPMFCDYpI1weuVFIPsa1ekvXaxHxUk2I1
         ZzHPgJLFR6ytTG2gm7bHGIXE99wt3Wewx9REXCAEj9dqfq0+uTIYslSjzUsB/IkxeRtI
         zBAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ygBGJ1w/RCoDaXYVhjgmvEDwEcg1cbZCgHzJuZ1tBus=;
        b=xQgPALoPKocXQoXX2+ALZrD2mDSM9+rIBcZqIGlFImLWdxvdMYiLeOep3cskg6hiFc
         u6PfSXrXOInPwQWNi6xfs1OxmGnfyNuyXuJnQ469Kor+oWLIlCzNVNZv69K7wurkIeaX
         rsn8dtfWI3k0cUTSajtD2tFBFUX7vsAFQJ+CObORcztjm+LhH9Rm2bXhN9m3l/6NJLvZ
         CS/9nHK8YbpBYnNybYCNPOyT2i+Vjn4AMR0HyMIecRkkkorUn/x5f7jVvhuZm+ce15ky
         QlzGcSbHOhoAgxKoVwf5BWFa5XwzWp0iRDMXo6w6mBZwhJfJ3eWdJLRuMZDw0sFByzSh
         jZ1A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=s4ntdBnf;
       spf=pass (google.com: domain of matheusfillipeag@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=matheusfillipeag@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x140sor11124761vsc.37.2019.04.03.12.08.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Apr 2019 12:08:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of matheusfillipeag@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=s4ntdBnf;
       spf=pass (google.com: domain of matheusfillipeag@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=matheusfillipeag@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ygBGJ1w/RCoDaXYVhjgmvEDwEcg1cbZCgHzJuZ1tBus=;
        b=s4ntdBnfE2WiA78vu+iiyLt2sAE5ORVQCggTuc++pefuSQwGmxuMcrWdbAkBGaH2xg
         E/sf2yOlywv0Nf+0vEhdX6xljmUz6nruOMEicABf+/ZculDdwedMvdDszttcvr/Bd1ni
         OycqC7CKOEDVDBK+iGe88m6/zu//63nCylUx/AyGybQ+0Tm8GQ5WhU+7lAbHE4uJaTzo
         CF2ACmaERJqJZbsWcYJuyJPKM6V87kbAATUtlMjwDy42qO1s8wdJfBuCfDcnFGl+uK53
         VGZBjbKprA7hvogqjoSkEarcsc5eFAEdln0IIr9Z1+wmf5hPE+BDsORCabXnxVazTYWu
         5YMQ==
X-Google-Smtp-Source: APXvYqwL26TEZrQHwiN0He6xS/5mcqJvq6VPl+UlAiB8UoHHJvJsiZOjzaxjRwSxJ1GgjMn3bx3Oebd4lncUZPx+SCE=
X-Received: by 2002:a67:fb45:: with SMTP id e5mr1475045vsr.72.1554318519307;
 Wed, 03 Apr 2019 12:08:39 -0700 (PDT)
MIME-Version: 1.0
References: <20140505233358.GC19914@cmpxchg.org> <5368227D.7060302@intel.com>
 <20140612220200.GA25344@cmpxchg.org> <539A3CD7.6080100@intel.com>
 <20140613045557.GL2878@cmpxchg.org> <539F1B66.2020006@intel.com>
 <20190402162500.def729ec05e6e267bff8a5da@linux-foundation.org>
 <20190403093432.GD8836@quack2.suse.cz> <1ea9f923-4756-85b2-6092-6d9e94d576a1@mailbox.org>
 <CAFWuBvcS-8AFZ4KoimMrLPjFXGE8a48QnSqV3_gajJNWYZymGA@mail.gmail.com> <56c1efb7-142b-9ae3-7f59-852d739f6632@mailbox.org>
In-Reply-To: <56c1efb7-142b-9ae3-7f59-852d739f6632@mailbox.org>
From: Matheus Fillipe <matheusfillipeag@gmail.com>
Date: Wed, 3 Apr 2019 16:08:13 -0300
Message-ID: <CAFWuBvegodiV58P9Q=3s2AUQ3Gf5xKj3ySf=W8VcSN_BypjxPQ@mail.gmail.com>
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
Content-Type: multipart/mixed; boundary="000000000000367cd40585a4fb5f"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--000000000000367cd40585a4fb5f
Content-Type: text/plain; charset="UTF-8"

Okay, I reinstalled pm-utils and make sure uswsusp was removed (apt
remove --purge uswsusp).

# fdisk -l |  grep swap
/dev/sda8  439762944 473214975  33452032    16G Linux swap
root@matheus-Inspiron-15-7000-Gaming:/home/matheus# blkid /dev/sda8
/dev/sda8: UUID="70d967e6-ad52-4c21-baf0-01a813ccc6ac" TYPE="swap"
PARTUUID="666096bb-0e72-431a-b981-9fd0c7e553ee"

I have  resume=70d967e6-ad52-4c21-baf0-01a813ccc6ac variable set in
all linux comamnd kernel (GRUB_CMDLINE_LINUX_DEFAULT) as you can see
on my attached boot-sequence. You can see more info about my setup and
what I already did here:
https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1819915

> What doesn't work: hibernating or resuming?
> And /var/log/pm-suspend.log might give you a clue what causes the problem.

Resuming doesn't work and still don't work.I tried setting either my
partition to /dev/sda8 or the uiid. It simply boots as if it was the
fist boot.



On Wed, Apr 3, 2019 at 2:55 PM Rainer Fiebig <jrf@mailbox.org> wrote:
>
> Am 03.04.19 um 18:59 schrieb Matheus Fillipe:
> > Yes I can sorta confirm the bug is in uswsusp. I removed the package
> > and pm-utils
>
> Matheus,
>
> there is no need to uninstall pm-utils. You actually need this to have
> comfortable suspend/hibernate.
>
> The only additional option you will get from uswsusp is true s2both
> (which is nice, imo).
>
> pm-utils provides something similar called "suspend-hybrid" which means
> that the computer suspends and after a configurable time wakes up again
> to go into hibernation.
>
> and used both "systemctl hibernate"  and "echo disk >>
> > /sys/power/state" to hibernate. It seems to succeed and shuts down, I
> > am just not able to resume from it, which seems to be a classical
> > problem solved just by setting the resume swap file/partition on grub.
> > (which i tried and didn't work even with nvidia disabled)
> >
> > Anyway uswsusp is still necessary because the default kernel
> > hibernation doesn't work with the proprietary nvidia drivers as long
> > as I know  and tested.
>
> What doesn't work: hibernating or resuming?
> And /var/log/pm-suspend.log might give you a clue what causes the problem.
>
> >
> > Is there anyway I could get any workaround to this bug on my current
> > OS by the way?
>
> *I* don't know, I don't use Ubuntu. But what I would do now is
> re-install pm-utils *without* uswsusp and make sure that you have got
> the swap-partition/file right in grub.cfg or menu.lst (grub legacy).
>
> Then do a few pm-hibernate/resume and tell us what happened.
>
> So long!
>
> >
> > On Wed, Apr 3, 2019 at 7:04 AM Rainer Fiebig <jrf@mailbox.org> wrote:
> >>
> >> Am 03.04.19 um 11:34 schrieb Jan Kara:
> >>> On Tue 02-04-19 16:25:00, Andrew Morton wrote:
> >>>>
> >>>> I cc'ed a bunch of people from bugzilla.
> >>>>
> >>>> Folks, please please please remember to reply via emailed
> >>>> reply-to-all.  Don't use the bugzilla interface!
> >>>>
> >>>> On Mon, 16 Jun 2014 18:29:26 +0200 "Rafael J. Wysocki" <rafael.j.wysocki@intel.com> wrote:
> >>>>
> >>>>> On 6/13/2014 6:55 AM, Johannes Weiner wrote:
> >>>>>> On Fri, Jun 13, 2014 at 01:50:47AM +0200, Rafael J. Wysocki wrote:
> >>>>>>> On 6/13/2014 12:02 AM, Johannes Weiner wrote:
> >>>>>>>> On Tue, May 06, 2014 at 01:45:01AM +0200, Rafael J. Wysocki wrote:
> >>>>>>>>> On 5/6/2014 1:33 AM, Johannes Weiner wrote:
> >>>>>>>>>> Hi Oliver,
> >>>>>>>>>>
> >>>>>>>>>> On Mon, May 05, 2014 at 11:00:13PM +0200, Oliver Winker wrote:
> >>>>>>>>>>> Hello,
> >>>>>>>>>>>
> >>>>>>>>>>> 1) Attached a full function-trace log + other SysRq outputs, see [1]
> >>>>>>>>>>> attached.
> >>>>>>>>>>>
> >>>>>>>>>>> I saw bdi_...() calls in the s2disk paths, but didn't check in detail
> >>>>>>>>>>> Probably more efficient when one of you guys looks directly.
> >>>>>>>>>> Thanks, this looks interesting.  balance_dirty_pages() wakes up the
> >>>>>>>>>> bdi_wq workqueue as it should:
> >>>>>>>>>>
> >>>>>>>>>> [  249.148009]   s2disk-3327    2.... 48550413us : global_dirty_limits <-balance_dirty_pages_ratelimited
> >>>>>>>>>> [  249.148009]   s2disk-3327    2.... 48550414us : global_dirtyable_memory <-global_dirty_limits
> >>>>>>>>>> [  249.148009]   s2disk-3327    2.... 48550414us : writeback_in_progress <-balance_dirty_pages_ratelimited
> >>>>>>>>>> [  249.148009]   s2disk-3327    2.... 48550414us : bdi_start_background_writeback <-balance_dirty_pages_ratelimited
> >>>>>>>>>> [  249.148009]   s2disk-3327    2.... 48550414us : mod_delayed_work_on <-balance_dirty_pages_ratelimited
> >>>>>>>>>> but the worker wakeup doesn't actually do anything:
> >>>>>>>>>> [  249.148009] kworker/-3466    2d... 48550431us : finish_task_switch <-__schedule
> >>>>>>>>>> [  249.148009] kworker/-3466    2.... 48550431us : _raw_spin_lock_irq <-worker_thread
> >>>>>>>>>> [  249.148009] kworker/-3466    2d... 48550431us : need_to_create_worker <-worker_thread
> >>>>>>>>>> [  249.148009] kworker/-3466    2d... 48550432us : worker_enter_idle <-worker_thread
> >>>>>>>>>> [  249.148009] kworker/-3466    2d... 48550432us : too_many_workers <-worker_enter_idle
> >>>>>>>>>> [  249.148009] kworker/-3466    2.... 48550432us : schedule <-worker_thread
> >>>>>>>>>> [  249.148009] kworker/-3466    2.... 48550432us : __schedule <-worker_thread
> >>>>>>>>>>
> >>>>>>>>>> My suspicion is that this fails because the bdi_wq is frozen at this
> >>>>>>>>>> point and so the flush work never runs until resume, whereas before my
> >>>>>>>>>> patch the effective dirty limit was high enough so that image could be
> >>>>>>>>>> written in one go without being throttled; followed by an fsync() that
> >>>>>>>>>> then writes the pages in the context of the unfrozen s2disk.
> >>>>>>>>>>
> >>>>>>>>>> Does this make sense?  Rafael?  Tejun?
> >>>>>>>>> Well, it does seem to make sense to me.
> >>>>>>>>  From what I see, this is a deadlock in the userspace suspend model and
> >>>>>>>> just happened to work by chance in the past.
> >>>>>>> Well, it had been working for quite a while, so it was a rather large
> >>>>>>> opportunity
> >>>>>>> window it seems. :-)
> >>>>>> No doubt about that, and I feel bad that it broke.  But it's still a
> >>>>>> deadlock that can't reasonably be accommodated from dirty throttling.
> >>>>>>
> >>>>>> It can't just put the flushers to sleep and then issue a large amount
> >>>>>> of buffered IO, hoping it doesn't hit the dirty limits.  Don't shoot
> >>>>>> the messenger, this bug needs to be addressed, not get papered over.
> >>>>>>
> >>>>>>>> Can we patch suspend-utils as follows?
> >>>>>>> Perhaps we can.  Let's ask the new maintainer.
> >>>>>>>
> >>>>>>> Rodolfo, do you think you can apply the patch below to suspend-utils?
> >>>>>>>
> >>>>>>>> Alternatively, suspend-utils
> >>>>>>>> could clear the dirty limits before it starts writing and restore them
> >>>>>>>> post-resume.
> >>>>>>> That (and the patch too) doesn't seem to address the problem with existing
> >>>>>>> suspend-utils
> >>>>>>> binaries, however.
> >>>>>> It's userspace that freezes the system before issuing buffered IO, so
> >>>>>> my conclusion was that the bug is in there.  This is arguable.  I also
> >>>>>> wouldn't be opposed to a patch that sets the dirty limits to infinity
> >>>>>> from the ioctl that freezes the system or creates the image.
> >>>>>
> >>>>> OK, that sounds like a workable plan.
> >>>>>
> >>>>> How do I set those limits to infinity?
> >>>>
> >>>> Five years have passed and people are still hitting this.
> >>>>
> >>>> Killian described the workaround in comment 14 at
> >>>> https://bugzilla.kernel.org/show_bug.cgi?id=75101.
> >>>>
> >>>> People can use this workaround manually by hand or in scripts.  But we
> >>>> really should find a proper solution.  Maybe special-case the freezing
> >>>> of the flusher threads until all the writeout has completed.  Or
> >>>> something else.
> >>>
> >>> I've refreshed my memory wrt this bug and I believe the bug is really on
> >>> the side of suspend-utils (uswsusp or however it is called). They are low
> >>> level system tools, they ask the kernel to freeze all processes
> >>> (SNAPSHOT_FREEZE ioctl), and then they rely on buffered writeback (which is
> >>> relatively heavyweight infrastructure) to work. That is wrong in my
> >>> opinion.
> >>>
> >>> I can see Johanness was suggesting in comment 11 to use O_SYNC in
> >>> suspend-utils which worked but was too slow. Indeed O_SYNC is rather big
> >>> hammer but using O_DIRECT should be what they need and get better
> >>> performance - no additional buffering in the kernel, no dirty throttling,
> >>> etc. They only need their buffer & device offsets sector aligned - they
> >>> seem to be even page aligned in suspend-utils so they should be fine. And
> >>> if the performance still sucks (currently they appear to do mostly random
> >>> 4k writes so it probably would for rotating disks), they could use AIO DIO
> >>> to get multiple pages in flight (as many as they dare to allocate buffers)
> >>> and then the IO scheduler will reorder things as good as it can and they
> >>> should get reasonable performance.
> >>>
> >>> Is there someone who works on suspend-utils these days? Because the repo
> >>> I've found on kernel.org seems to be long dead (last commit in 2012).
> >>>
> >>>                                                               Honza
> >>>
> >>
> >> Whether it's suspend-utils (or uswsusp) or not could be answered quickly
> >> by de-installing this package and using the kernel-methods instead.
> >>
> >>
>
>

--000000000000367cd40585a4fb5f
Content-Type: text/x-log; charset="US-ASCII"; name="pm-suspend.log"
Content-Disposition: attachment; filename="pm-suspend.log"
Content-Transfer-Encoding: base64
Content-ID: <f_ju1k69a40>
X-Attachment-Id: f_ju1k69a40

SW5pdGlhbCBjb21tYW5kbGluZSBwYXJhbWV0ZXJzOiAKcXVhIGFiciAgMyAxMzowMjozOCAtMDMg
MjAxOTogUnVubmluZyBob29rcyBmb3IgaGliZXJuYXRlLgpSdW5uaW5nIGhvb2sgL3Vzci9saWIv
cG0tdXRpbHMvc2xlZXAuZC8wMDBrZXJuZWwtY2hhbmdlIGhpYmVybmF0ZSBoaWJlcm5hdGU6Ci91
c3IvbGliL3BtLXV0aWxzL3NsZWVwLmQvMDAwa2VybmVsLWNoYW5nZSBoaWJlcm5hdGUgaGliZXJu
YXRlOiBzdWNjZXNzLgoKUnVubmluZyBob29rIC91c3IvbGliL3BtLXV0aWxzL3NsZWVwLmQvMDAw
cmVjb3JkLXN0YXR1cyBoaWJlcm5hdGUgaGliZXJuYXRlOgovdXNyL2xpYi9wbS11dGlscy9zbGVl
cC5kLzAwMHJlY29yZC1zdGF0dXMgaGliZXJuYXRlIGhpYmVybmF0ZTogc3VjY2Vzcy4KClJ1bm5p
bmcgaG9vayAvdXNyL2xpYi9wbS11dGlscy9zbGVlcC5kLzAwbG9nZ2luZyBoaWJlcm5hdGUgaGli
ZXJuYXRlOgpMaW51eCBtYXRoZXVzLUluc3Bpcm9uLTE1LTcwMDAtR2FtaW5nIDQuMTguMC0xNy1n
ZW5lcmljICMxOH4xOC4wNC4xLVVidW50dSBTTVAgRnJpIE1hciAxNSAxNToyNzoxMiBVVEMgMjAx
OSB4ODZfNjQgeDg2XzY0IHg4Nl82NCBHTlUvTGludXgKTW9kdWxlICAgICAgICAgICAgICAgICAg
U2l6ZSAgVXNlZCBieQpyZmNvbW0gICAgICAgICAgICAgICAgIDc3ODI0ICA0CmlwdGFibGVfZmls
dGVyICAgICAgICAgMTYzODQgIDAKYnBmaWx0ZXIgICAgICAgICAgICAgICAxNjM4NCAgMApjY20g
ICAgICAgICAgICAgICAgICAgIDIwNDgwICA2CnBjaV9zdHViICAgICAgICAgICAgICAgMTYzODQg
IDEKdmJveHBjaSAgICAgICAgICAgICAgICAyNDU3NiAgMAp2Ym94bmV0YWRwICAgICAgICAgICAg
IDI4NjcyICAwCnZib3huZXRmbHQgICAgICAgICAgICAgMjg2NzIgIDAKdmJveGRydiAgICAgICAg
ICAgICAgIDQ4NzQyNCAgMyB2Ym94cGNpLHZib3huZXRhZHAsdmJveG5ldGZsdApjbWFjICAgICAg
ICAgICAgICAgICAgIDE2Mzg0ICAxCmJuZXAgICAgICAgICAgICAgICAgICAgMjA0ODAgIDIKYnJp
ZGdlICAgICAgICAgICAgICAgIDE1OTc0NCAgMApzdHAgICAgICAgICAgICAgICAgICAgIDE2Mzg0
ICAxIGJyaWRnZQpsbGMgICAgICAgICAgICAgICAgICAgIDE2Mzg0ICAyIGJyaWRnZSxzdHAKYmlu
Zm10X21pc2MgICAgICAgICAgICAyMDQ4MCAgMQpubHNfaXNvODg1OV8xICAgICAgICAgIDE2Mzg0
ICAxCmFyYzQgICAgICAgICAgICAgICAgICAgMTYzODQgIDIKaGlkX211bHRpdG91Y2ggICAgICAg
ICAyMDQ4MCAgMAppbnRlbF9yYXBsICAgICAgICAgICAgIDIwNDgwICAwCng4Nl9wa2dfdGVtcF90
aGVybWFsICAgIDE2Mzg0ICAwCmludGVsX3Bvd2VyY2xhbXAgICAgICAgMTYzODQgIDAKZGVsbF9z
bW1faHdtb24gICAgICAgICAxNjM4NCAgMApjb3JldGVtcCAgICAgICAgICAgICAgIDE2Mzg0ICAw
CmRlbGxfbGFwdG9wICAgICAgICAgICAgMjA0ODAgIDEKa3ZtX2ludGVsICAgICAgICAgICAgIDIw
ODg5NiAgMAprdm0gICAgICAgICAgICAgICAgICAgNjI2Njg4ICAxIGt2bV9pbnRlbAppcnFieXBh
c3MgICAgICAgICAgICAgIDE2Mzg0ICAxIGt2bQpjcmN0MTBkaWZfcGNsbXVsICAgICAgIDE2Mzg0
ICAwCnNuZF91c2JfYXVkaW8gICAgICAgICAyMjUyODAgIDMKY3JjMzJfcGNsbXVsICAgICAgICAg
ICAxNjM4NCAgMApzbmRfaGRhX2NvZGVjX3JlYWx0ZWsgICAxMDY0OTYgIDEKZ2hhc2hfY2xtdWxu
aV9pbnRlbCAgICAxNjM4NCAgMApzbmRfdXNibWlkaV9saWIgICAgICAgIDMyNzY4ICAxIHNuZF91
c2JfYXVkaW8Kc25kX2hkYV9jb2RlY19nZW5lcmljICAgIDczNzI4ICAxIHNuZF9oZGFfY29kZWNf
cmVhbHRlawpwY2JjICAgICAgICAgICAgICAgICAgIDE2Mzg0ICAwCmFlc25pX2ludGVsICAgICAg
ICAgICAyMDA3MDQgIDYKdXZjdmlkZW8gICAgICAgICAgICAgICA5NDIwOCAgMAphZXNfeDg2XzY0
ICAgICAgICAgICAgIDIwNDgwICAxIGFlc25pX2ludGVsCnZpZGVvYnVmMl92bWFsbG9jICAgICAg
MTYzODQgIDEgdXZjdmlkZW8KY3J5cHRvX3NpbWQgICAgICAgICAgICAxNjM4NCAgMSBhZXNuaV9p
bnRlbAp2aWRlb2J1ZjJfbWVtb3BzICAgICAgIDE2Mzg0ICAxIHZpZGVvYnVmMl92bWFsbG9jCnNu
ZF9oZGFfaW50ZWwgICAgICAgICAgNDA5NjAgIDMKY3J5cHRkICAgICAgICAgICAgICAgICAyNDU3
NiAgMyBjcnlwdG9fc2ltZCxnaGFzaF9jbG11bG5pX2ludGVsLGFlc25pX2ludGVsCnZpZGVvYnVm
Ml92NGwyICAgICAgICAgMjQ1NzYgIDEgdXZjdmlkZW8KZ2x1ZV9oZWxwZXIgICAgICAgICAgICAx
NjM4NCAgMSBhZXNuaV9pbnRlbApzbmRfaGRhX2NvZGVjICAgICAgICAgMTI2OTc2ICAzIHNuZF9o
ZGFfY29kZWNfZ2VuZXJpYyxzbmRfaGRhX2ludGVsLHNuZF9oZGFfY29kZWNfcmVhbHRlawp2aWRl
b2J1ZjJfY29tbW9uICAgICAgIDQwOTYwICAyIHZpZGVvYnVmMl92NGwyLHV2Y3ZpZGVvCmJ0dXNi
ICAgICAgICAgICAgICAgICAgNDUwNTYgIDAKdmlkZW9kZXYgICAgICAgICAgICAgIDE4ODQxNiAg
MyB2aWRlb2J1ZjJfdjRsMix1dmN2aWRlbyx2aWRlb2J1ZjJfY29tbW9uCmJ0cnRsICAgICAgICAg
ICAgICAgICAgMTYzODQgIDEgYnR1c2IKc25kX2hkYV9jb3JlICAgICAgICAgICA4MTkyMCAgNCBz
bmRfaGRhX2NvZGVjX2dlbmVyaWMsc25kX2hkYV9pbnRlbCxzbmRfaGRhX2NvZGVjLHNuZF9oZGFf
Y29kZWNfcmVhbHRlawpidGJjbSAgICAgICAgICAgICAgICAgIDE2Mzg0ICAxIGJ0dXNiCm1lZGlh
ICAgICAgICAgICAgICAgICAgNDA5NjAgIDIgdmlkZW9kZXYsdXZjdmlkZW8KYnRpbnRlbCAgICAg
ICAgICAgICAgICAyMDQ4MCAgMSBidHVzYgpzbmRfaHdkZXAgICAgICAgICAgICAgIDIwNDgwICAy
IHNuZF91c2JfYXVkaW8sc25kX2hkYV9jb2RlYwpibHVldG9vdGggICAgICAgICAgICAgNTUyOTYw
ICAzMyBidHJ0bCxidGludGVsLGJ0YmNtLGJuZXAsYnR1c2IscmZjb21tCnNuZF9wY20gICAgICAg
ICAgICAgICAgOTgzMDQgIDUgc25kX2hkYV9pbnRlbCxzbmRfdXNiX2F1ZGlvLHNuZF9oZGFfY29k
ZWMsc25kX2hkYV9jb3JlCmVjZGhfZ2VuZXJpYyAgICAgICAgICAgMjQ1NzYgIDIgYmx1ZXRvb3Ro
CnNuZF9zZXFfbWlkaSAgICAgICAgICAgMTYzODQgIDAKYXRoMTBrX3BjaSAgICAgICAgICAgICA0
MDk2MCAgMApzbmRfc2VxX21pZGlfZXZlbnQgICAgIDE2Mzg0ICAxIHNuZF9zZXFfbWlkaQpzbmRf
cmF3bWlkaSAgICAgICAgICAgIDMyNzY4ICAyIHNuZF9zZXFfbWlkaSxzbmRfdXNibWlkaV9saWIK
YXRoMTBrX2NvcmUgICAgICAgICAgIDQxNzc5MiAgMSBhdGgxMGtfcGNpCmF0aCAgICAgICAgICAg
ICAgICAgICAgMzI3NjggIDEgYXRoMTBrX2NvcmUKaW50ZWxfY3N0YXRlICAgICAgICAgICAyMDQ4
MCAgMApzbmRfc2VxICAgICAgICAgICAgICAgIDY1NTM2ICAyIHNuZF9zZXFfbWlkaSxzbmRfc2Vx
X21pZGlfZXZlbnQKbWFjODAyMTEgICAgICAgICAgICAgIDgwMjgxNiAgMSBhdGgxMGtfY29yZQpp
bnRlbF9yYXBsX3BlcmYgICAgICAgIDE2Mzg0ICAwCmNmZzgwMjExICAgICAgICAgICAgICA2Njc2
NDggIDMgYXRoLG1hYzgwMjExLGF0aDEwa19jb3JlCnNuZF9zZXFfZGV2aWNlICAgICAgICAgMTYz
ODQgIDMgc25kX3NlcSxzbmRfc2VxX21pZGksc25kX3Jhd21pZGkKc25kX3RpbWVyICAgICAgICAg
ICAgICAzMjc2OCAgMiBzbmRfc2VxLHNuZF9wY20KaWRtYTY0ICAgICAgICAgICAgICAgICAyMDQ4
MCAgMAp2aXJ0X2RtYSAgICAgICAgICAgICAgIDE2Mzg0ICAxIGlkbWE2NApkZWxsX3dtaSAgICAg
ICAgICAgICAgIDE2Mzg0ICAwCnNuZCAgICAgICAgICAgICAgICAgICAgODE5MjAgIDIzIHNuZF9o
ZGFfY29kZWNfZ2VuZXJpYyxzbmRfc2VxLHNuZF9zZXFfZGV2aWNlLHNuZF9od2RlcCxzbmRfaGRh
X2ludGVsLHNuZF91c2JfYXVkaW8sc25kX3VzYm1pZGlfbGliLHNuZF9oZGFfY29kZWMsc25kX2hk
YV9jb2RlY19yZWFsdGVrLHNuZF90aW1lcixzbmRfcGNtLHNuZF9yYXdtaWRpCmRlbGxfc21iaW9z
ICAgICAgICAgICAgMjQ1NzYgIDIgZGVsbF93bWksZGVsbF9sYXB0b3AKaW50ZWxfbHBzc19wY2kg
ICAgICAgICAyMDQ4MCAgMApzb3VuZGNvcmUgICAgICAgICAgICAgIDE2Mzg0ICAxIHNuZApkY2Ri
YXMgICAgICAgICAgICAgICAgIDE2Mzg0ICAxIGRlbGxfc21iaW9zCm1laV9tZSAgICAgICAgICAg
ICAgICAgNDA5NjAgIDAKaW50ZWxfbHBzcyAgICAgICAgICAgICAxNjM4NCAgMSBpbnRlbF9scHNz
X3BjaQpqb3lkZXYgICAgICAgICAgICAgICAgIDI0NTc2ICAwCmlucHV0X2xlZHMgICAgICAgICAg
ICAgMTYzODQgIDAKbWVpICAgICAgICAgICAgICAgICAgICA5ODMwNCAgMSBtZWlfbWUKZGVsbF93
bWlfZGVzY3JpcHRvciAgICAxNjM4NCAgMiBkZWxsX3dtaSxkZWxsX3NtYmlvcwp3bWlfYm1vZiAg
ICAgICAgICAgICAgIDE2Mzg0ICAwCnNlcmlvX3JhdyAgICAgICAgICAgICAgMTYzODQgIDAKaW50
ZWxfcGNoX3RoZXJtYWwgICAgICAxNjM4NCAgMAppbnQzNDAzX3RoZXJtYWwgICAgICAgIDE2Mzg0
ICAwCmludDM0MDBfdGhlcm1hbCAgICAgICAgMTYzODQgIDAKcHJvY2Vzc29yX3RoZXJtYWxfZGV2
aWNlICAgIDE2Mzg0ICAwCmFjcGlfdGhlcm1hbF9yZWwgICAgICAgMTYzODQgIDEgaW50MzQwMF90
aGVybWFsCm1hY19oaWQgICAgICAgICAgICAgICAgMTYzODQgIDAKaW50ZWxfc29jX2R0c19pb3Nm
ICAgICAxNjM4NCAgMSBwcm9jZXNzb3JfdGhlcm1hbF9kZXZpY2UKaW50MzQwMl90aGVybWFsICAg
ICAgICAxNjM4NCAgMAppbnRlbF9oaWQgICAgICAgICAgICAgIDE2Mzg0ICAwCmludDM0MHhfdGhl
cm1hbF96b25lICAgIDE2Mzg0ICAzIGludDM0MDNfdGhlcm1hbCxpbnQzNDAyX3RoZXJtYWwscHJv
Y2Vzc29yX3RoZXJtYWxfZGV2aWNlCnNwYXJzZV9rZXltYXAgICAgICAgICAgMTYzODQgIDIgaW50
ZWxfaGlkLGRlbGxfd21pCmFjcGlfcGFkICAgICAgICAgICAgICAxODAyMjQgIDAKc2NoX2ZxX2Nv
ZGVsICAgICAgICAgICAyMDQ4MCAgMgpudmlkaWFfdXZtICAgICAgICAgICAgNzk4NzIwICAwCnZo
Y2lfaGNkICAgICAgICAgICAgICAgNDkxNTIgIDAKdXNiaXBfY29yZSAgICAgICAgICAgICAzMjc2
OCAgMSB2aGNpX2hjZApwYXJwb3J0X3BjICAgICAgICAgICAgIDM2ODY0ICAwCnBwZGV2ICAgICAg
ICAgICAgICAgICAgMjA0ODAgIDAKbHAgICAgICAgICAgICAgICAgICAgICAyMDQ4MCAgMApzdW5y
cGMgICAgICAgICAgICAgICAgMzUyMjU2ICAxCnBhcnBvcnQgICAgICAgICAgICAgICAgNDkxNTIg
IDMgcGFycG9ydF9wYyxscCxwcGRldgpiaW5kZXJfbGludXggICAgICAgICAgMTAyNDAwICAwCmFz
aG1lbV9saW51eCAgICAgICAgICAgMTYzODQgIDAKaXBfdGFibGVzICAgICAgICAgICAgICAyODY3
MiAgMSBpcHRhYmxlX2ZpbHRlcgp4X3RhYmxlcyAgICAgICAgICAgICAgIDQwOTYwICAyIGlwdGFi
bGVfZmlsdGVyLGlwX3RhYmxlcwphdXRvZnM0ICAgICAgICAgICAgICAgIDQwOTYwICAyCmJ0cmZz
ICAgICAgICAgICAgICAgIDExNjMyNjQgIDAKenN0ZF9jb21wcmVzcyAgICAgICAgIDE2Mzg0MCAg
MSBidHJmcwpyYWlkMTAgICAgICAgICAgICAgICAgIDUzMjQ4ICAwCnJhaWQ0NTYgICAgICAgICAg
ICAgICAxNTE1NTIgIDAKYXN5bmNfcmFpZDZfcmVjb3YgICAgICAyMDQ4MCAgMSByYWlkNDU2CmFz
eW5jX21lbWNweSAgICAgICAgICAgMTYzODQgIDIgcmFpZDQ1Nixhc3luY19yYWlkNl9yZWNvdgph
c3luY19wcSAgICAgICAgICAgICAgIDE2Mzg0ICAyIHJhaWQ0NTYsYXN5bmNfcmFpZDZfcmVjb3YK
YXN5bmNfeG9yICAgICAgICAgICAgICAxNjM4NCAgMyBhc3luY19wcSxyYWlkNDU2LGFzeW5jX3Jh
aWQ2X3JlY292CmFzeW5jX3R4ICAgICAgICAgICAgICAgMTYzODQgIDUgYXN5bmNfcHEsYXN5bmNf
bWVtY3B5LGFzeW5jX3hvcixyYWlkNDU2LGFzeW5jX3JhaWQ2X3JlY292CnhvciAgICAgICAgICAg
ICAgICAgICAgMjQ1NzYgIDIgYXN5bmNfeG9yLGJ0cmZzCnJhaWQ2X3BxICAgICAgICAgICAgICAx
MTQ2ODggIDQgYXN5bmNfcHEsYnRyZnMscmFpZDQ1Nixhc3luY19yYWlkNl9yZWNvdgpsaWJjcmMz
MmMgICAgICAgICAgICAgIDE2Mzg0ICAyIGJ0cmZzLHJhaWQ0NTYKcmFpZDEgICAgICAgICAgICAg
ICAgICA0MDk2MCAgMApyYWlkMCAgICAgICAgICAgICAgICAgIDIwNDgwICAwCm11bHRpcGF0aCAg
ICAgICAgICAgICAgMTYzODQgIDAKbGluZWFyICAgICAgICAgICAgICAgICAxNjM4NCAgMApkbV9t
aXJyb3IgICAgICAgICAgICAgIDI0NTc2ICAwCmRtX3JlZ2lvbl9oYXNoICAgICAgICAgMjA0ODAg
IDEgZG1fbWlycm9yCmRtX2xvZyAgICAgICAgICAgICAgICAgMjA0ODAgIDIgZG1fcmVnaW9uX2hh
c2gsZG1fbWlycm9yCmhpZF9nZW5lcmljICAgICAgICAgICAgMTYzODQgIDAKdXNiaGlkICAgICAg
ICAgICAgICAgICA0OTE1MiAgMApudmlkaWFfZHJtICAgICAgICAgICAgIDQwOTYwICAzCm52aWRp
YV9tb2Rlc2V0ICAgICAgIDEwODU0NDAgIDMgbnZpZGlhX2RybQpudmlkaWEgICAgICAgICAgICAg
IDE3NjAwNTEyICAxMDUgbnZpZGlhX3V2bSxudmlkaWFfbW9kZXNldAppOTE1ICAgICAgICAgICAg
ICAgICAxNzQwODAwICAzCm14bV93bWkgICAgICAgICAgICAgICAgMTYzODQgIDAKaTJjX2FsZ29f
Yml0ICAgICAgICAgICAxNjM4NCAgMSBpOTE1CmRybV9rbXNfaGVscGVyICAgICAgICAxNzIwMzIg
IDIgbnZpZGlhX2RybSxpOTE1CnN5c2NvcHlhcmVhICAgICAgICAgICAgMTYzODQgIDEgZHJtX2tt
c19oZWxwZXIKc3lzZmlsbHJlY3QgICAgICAgICAgICAxNjM4NCAgMSBkcm1fa21zX2hlbHBlcgpz
eXNpbWdibHQgICAgICAgICAgICAgIDE2Mzg0ICAxIGRybV9rbXNfaGVscGVyCmZiX3N5c19mb3Bz
ICAgICAgICAgICAgMTYzODQgIDEgZHJtX2ttc19oZWxwZXIKcjgxNjkgICAgICAgICAgICAgICAg
ICA4NjAxNiAgMApwc21vdXNlICAgICAgICAgICAgICAgMTUxNTUyICAwCmRybSAgICAgICAgICAg
ICAgICAgICA0NTg3NTIgIDcgZHJtX2ttc19oZWxwZXIsbnZpZGlhX2RybSxpOTE1CmlwbWlfZGV2
aW50ZiAgICAgICAgICAgMjA0ODAgIDAKbWlpICAgICAgICAgICAgICAgICAgICAxNjM4NCAgMSBy
ODE2OQphaGNpICAgICAgICAgICAgICAgICAgIDQwOTYwICA1CmkyY19oaWQgICAgICAgICAgICAg
ICAgMjA0ODAgIDAKaXBtaV9tc2doYW5kbGVyICAgICAgIDEwMjQwMCAgMiBpcG1pX2RldmludGYs
bnZpZGlhCmxpYmFoY2kgICAgICAgICAgICAgICAgMzI3NjggIDEgYWhjaQpoaWQgICAgICAgICAg
ICAgICAgICAgMTIyODgwICA0IGkyY19oaWQsdXNiaGlkLGhpZF9tdWx0aXRvdWNoLGhpZF9nZW5l
cmljCndtaSAgICAgICAgICAgICAgICAgICAgMjQ1NzYgIDUgZGVsbF93bWksd21pX2Jtb2YsZGVs
bF9zbWJpb3MsZGVsbF93bWlfZGVzY3JpcHRvcixteG1fd21pCnZpZGVvICAgICAgICAgICAgICAg
ICAgNDUwNTYgIDMgZGVsbF93bWksZGVsbF9sYXB0b3AsaTkxNQogICAgICAgICAgICAgIHRvdGFs
ICAgICAgICB1c2VkICAgICAgICBmcmVlICAgICAgc2hhcmVkICBidWZmL2NhY2hlICAgYXZhaWxh
YmxlCk1lbTogICAgICAgMTYyODgwMzYgICAgICA4NDQ2MDQgICAgMTM4NDcwMTIgICAgICAgMzc5
MDggICAgIDE1OTY0MjAgICAgMTUxMTIwMDQKU3dhcDogICAgICAxNjcyNjAxMiAgICAgICAgICAg
MCAgICAxNjcyNjAxMgovdXNyL2xpYi9wbS11dGlscy9zbGVlcC5kLzAwbG9nZ2luZyBoaWJlcm5h
dGUgaGliZXJuYXRlOiBzdWNjZXNzLgoKUnVubmluZyBob29rIC91c3IvbGliL3BtLXV0aWxzL3Ns
ZWVwLmQvMDBwb3dlcnNhdmUgaGliZXJuYXRlIGhpYmVybmF0ZToKL3Vzci9saWIvcG0tdXRpbHMv
c2xlZXAuZC8wMHBvd2Vyc2F2ZSBoaWJlcm5hdGUgaGliZXJuYXRlOiBzdWNjZXNzLgoKUnVubmlu
ZyBob29rIC9ldGMvcG0vc2xlZXAuZC8xMF9ncnViLWNvbW1vbiBoaWJlcm5hdGUgaGliZXJuYXRl
OgovZXRjL3BtL3NsZWVwLmQvMTBfZ3J1Yi1jb21tb24gaGliZXJuYXRlIGhpYmVybmF0ZTogc3Vj
Y2Vzcy4KClJ1bm5pbmcgaG9vayAvZXRjL3BtL3NsZWVwLmQvMTBfdW5hdHRlbmRlZC11cGdyYWRl
cy1oaWJlcm5hdGUgaGliZXJuYXRlIGhpYmVybmF0ZToKL2V0Yy9wbS9zbGVlcC5kLzEwX3VuYXR0
ZW5kZWQtdXBncmFkZXMtaGliZXJuYXRlIGhpYmVybmF0ZSBoaWJlcm5hdGU6IHN1Y2Nlc3MuCgpS
dW5uaW5nIGhvb2sgL3Vzci9saWIvcG0tdXRpbHMvc2xlZXAuZC8yMHR1eG9uaWNlIGhpYmVybmF0
ZSBoaWJlcm5hdGU6Ci91c3IvbGliL3BtLXV0aWxzL3NsZWVwLmQvMjB0dXhvbmljZSBoaWJlcm5h
dGUgaGliZXJuYXRlOiBub3QgYXBwbGljYWJsZS4KClJ1bm5pbmcgaG9vayAvdXNyL2xpYi9wbS11
dGlscy9zbGVlcC5kLzQwaW5wdXRhdHRhY2ggaGliZXJuYXRlIGhpYmVybmF0ZToKL3Vzci9saWIv
cG0tdXRpbHMvc2xlZXAuZC80MGlucHV0YXR0YWNoIGhpYmVybmF0ZSBoaWJlcm5hdGU6IHN1Y2Nl
c3MuCgpSdW5uaW5nIGhvb2sgL3Vzci9saWIvcG0tdXRpbHMvc2xlZXAuZC81MHVubG9hZF9hbHgg
aGliZXJuYXRlIGhpYmVybmF0ZToKL3Vzci9saWIvcG0tdXRpbHMvc2xlZXAuZC81MHVubG9hZF9h
bHggaGliZXJuYXRlIGhpYmVybmF0ZTogc3VjY2Vzcy4KClJ1bm5pbmcgaG9vayAvdXNyL2xpYi9w
bS11dGlscy9zbGVlcC5kLzYwX3dwYV9zdXBwbGljYW50IGhpYmVybmF0ZSBoaWJlcm5hdGU6ClNl
bGVjdGVkIGludGVyZmFjZSAncDJwLWRldi13bHAzczAnCk9LCi91c3IvbGliL3BtLXV0aWxzL3Ns
ZWVwLmQvNjBfd3BhX3N1cHBsaWNhbnQgaGliZXJuYXRlIGhpYmVybmF0ZTogc3VjY2Vzcy4KClJ1
bm5pbmcgaG9vayAvdXNyL2xpYi9wbS11dGlscy9zbGVlcC5kLzc1bW9kdWxlcyBoaWJlcm5hdGUg
aGliZXJuYXRlOgovdXNyL2xpYi9wbS11dGlscy9zbGVlcC5kLzc1bW9kdWxlcyBoaWJlcm5hdGUg
aGliZXJuYXRlOiBub3QgYXBwbGljYWJsZS4KClJ1bm5pbmcgaG9vayAvdXNyL2xpYi9wbS11dGls
cy9zbGVlcC5kLzkwY2xvY2sgaGliZXJuYXRlIGhpYmVybmF0ZToKL3Vzci9saWIvcG0tdXRpbHMv
c2xlZXAuZC85MGNsb2NrIGhpYmVybmF0ZSBoaWJlcm5hdGU6IG5vdCBhcHBsaWNhYmxlLgoKUnVu
bmluZyBob29rIC91c3IvbGliL3BtLXV0aWxzL3NsZWVwLmQvOTRjcHVmcmVxIGhpYmVybmF0ZSBo
aWJlcm5hdGU6Ci91c3IvbGliL3BtLXV0aWxzL3NsZWVwLmQvOTRjcHVmcmVxIGhpYmVybmF0ZSBo
aWJlcm5hdGU6IHN1Y2Nlc3MuCgpSdW5uaW5nIGhvb2sgL3Vzci9saWIvcG0tdXRpbHMvc2xlZXAu
ZC85NWFuYWNyb24gaGliZXJuYXRlIGhpYmVybmF0ZToKV2FybmluZzogU3RvcHBpbmcgYW5hY3Jv
bi5zZXJ2aWNlLCBidXQgaXQgY2FuIHN0aWxsIGJlIGFjdGl2YXRlZCBieToKICBhbmFjcm9uLnRp
bWVyCi91c3IvbGliL3BtLXV0aWxzL3NsZWVwLmQvOTVhbmFjcm9uIGhpYmVybmF0ZSBoaWJlcm5h
dGU6IHN1Y2Nlc3MuCgpSdW5uaW5nIGhvb2sgL3Vzci9saWIvcG0tdXRpbHMvc2xlZXAuZC85NWhk
cGFybS1hcG0gaGliZXJuYXRlIGhpYmVybmF0ZToKL3Vzci9saWIvcG0tdXRpbHMvc2xlZXAuZC85
NWhkcGFybS1hcG0gaGliZXJuYXRlIGhpYmVybmF0ZTogbm90IGFwcGxpY2FibGUuCgpSdW5uaW5n
IGhvb2sgL3Vzci9saWIvcG0tdXRpbHMvc2xlZXAuZC85NWxlZCBoaWJlcm5hdGUgaGliZXJuYXRl
OgovdXNyL2xpYi9wbS11dGlscy9zbGVlcC5kLzk1bGVkIGhpYmVybmF0ZSBoaWJlcm5hdGU6IG5v
dCBhcHBsaWNhYmxlLgoKUnVubmluZyBob29rIC91c3IvbGliL3BtLXV0aWxzL3NsZWVwLmQvOTh2
aWRlby1xdWlyay1kYi1oYW5kbGVyIGhpYmVybmF0ZSBoaWJlcm5hdGU6Cktlcm5lbCBtb2Rlc2V0
dGluZyB2aWRlbyBkcml2ZXIgZGV0ZWN0ZWQsIG5vdCB1c2luZyBxdWlya3MuCi91c3IvbGliL3Bt
LXV0aWxzL3NsZWVwLmQvOTh2aWRlby1xdWlyay1kYi1oYW5kbGVyIGhpYmVybmF0ZSBoaWJlcm5h
dGU6IHN1Y2Nlc3MuCgpSdW5uaW5nIGhvb2sgL3Vzci9saWIvcG0tdXRpbHMvc2xlZXAuZC85OTlt
b3VudGEgaGliZXJuYXRlIGhpYmVybmF0ZToKL3Vzci9saWIvcG0tdXRpbHMvc2xlZXAuZC85OTlt
b3VudGEgaGliZXJuYXRlIGhpYmVybmF0ZTogc3VjY2Vzcy4KClJ1bm5pbmcgaG9vayAvZXRjL3Bt
L3NsZWVwLmQvOTlfaGliZXJuYXRlX3NjcmlwdHMgaGliZXJuYXRlIGhpYmVybmF0ZToKL2V0Yy9w
bS9zbGVlcC5kLzk5X2hpYmVybmF0ZV9zY3JpcHRzIGhpYmVybmF0ZSBoaWJlcm5hdGU6IHN1Y2Nl
c3MuCgpSdW5uaW5nIGhvb2sgL3Vzci9saWIvcG0tdXRpbHMvc2xlZXAuZC85OXZpZGVvIGhpYmVy
bmF0ZSBoaWJlcm5hdGU6Ci91c3IvbGliL3BtLXV0aWxzL3NsZWVwLmQvOTl2aWRlbyBoaWJlcm5h
dGUgaGliZXJuYXRlOiBzdWNjZXNzLgoKcXVhIGFiciAgMyAxMzowMjozOCAtMDMgMjAxOTogcGVy
Zm9ybWluZyBoaWJlcm5hdGUKSW5pdGlhbCBjb21tYW5kbGluZSBwYXJhbWV0ZXJzOiAKcXVhIGFi
ciAgMyAxNToyNDo1MSAtMDMgMjAxOTogUnVubmluZyBob29rcyBmb3IgaGliZXJuYXRlLgpSdW5u
aW5nIGhvb2sgL3Vzci9saWIvcG0tdXRpbHMvc2xlZXAuZC8wMDBrZXJuZWwtY2hhbmdlIGhpYmVy
bmF0ZSBoaWJlcm5hdGU6Ci91c3IvbGliL3BtLXV0aWxzL3NsZWVwLmQvMDAwa2VybmVsLWNoYW5n
ZSBoaWJlcm5hdGUgaGliZXJuYXRlOiBzdWNjZXNzLgoKUnVubmluZyBob29rIC91c3IvbGliL3Bt
LXV0aWxzL3NsZWVwLmQvMDAwcmVjb3JkLXN0YXR1cyBoaWJlcm5hdGUgaGliZXJuYXRlOgovdXNy
L2xpYi9wbS11dGlscy9zbGVlcC5kLzAwMHJlY29yZC1zdGF0dXMgaGliZXJuYXRlIGhpYmVybmF0
ZTogc3VjY2Vzcy4KClJ1bm5pbmcgaG9vayAvdXNyL2xpYi9wbS11dGlscy9zbGVlcC5kLzAwbG9n
Z2luZyBoaWJlcm5hdGUgaGliZXJuYXRlOgpMaW51eCBtYXRoZXVzLUluc3Bpcm9uLTE1LTcwMDAt
R2FtaW5nIDQuMTguMC0xNy1nZW5lcmljICMxOH4xOC4wNC4xLVVidW50dSBTTVAgRnJpIE1hciAx
NSAxNToyNzoxMiBVVEMgMjAxOSB4ODZfNjQgeDg2XzY0IHg4Nl82NCBHTlUvTGludXgKTW9kdWxl
ICAgICAgICAgICAgICAgICAgU2l6ZSAgVXNlZCBieQp0Y3BfZGlhZyAgICAgICAgICAgICAgIDE2
Mzg0ICAwCmluZXRfZGlhZyAgICAgICAgICAgICAgMjQ1NzYgIDEgdGNwX2RpYWcKdW5peF9kaWFn
ICAgICAgICAgICAgICAxNjM4NCAgMApzbmRfc2VxX2R1bW15ICAgICAgICAgIDE2Mzg0ICAwCnJm
Y29tbSAgICAgICAgICAgICAgICAgNzc4MjQgIDE2CmlwdGFibGVfZmlsdGVyICAgICAgICAgMTYz
ODQgIDAKYnBmaWx0ZXIgICAgICAgICAgICAgICAxNjM4NCAgMApjY20gICAgICAgICAgICAgICAg
ICAgIDIwNDgwICA2CnBjaV9zdHViICAgICAgICAgICAgICAgMTYzODQgIDEKdmJveHBjaSAgICAg
ICAgICAgICAgICAyNDU3NiAgMAp2Ym94bmV0YWRwICAgICAgICAgICAgIDI4NjcyICAwCnZib3hu
ZXRmbHQgICAgICAgICAgICAgMjg2NzIgIDAKY21hYyAgICAgICAgICAgICAgICAgICAxNjM4NCAg
MQp2Ym94ZHJ2ICAgICAgICAgICAgICAgNDg3NDI0ICAzIHZib3hwY2ksdmJveG5ldGFkcCx2Ym94
bmV0Zmx0CmJuZXAgICAgICAgICAgICAgICAgICAgMjA0ODAgIDIKYnJpZGdlICAgICAgICAgICAg
ICAgIDE1OTc0NCAgMApzdHAgICAgICAgICAgICAgICAgICAgIDE2Mzg0ICAxIGJyaWRnZQpsbGMg
ICAgICAgICAgICAgICAgICAgIDE2Mzg0ICAyIGJyaWRnZSxzdHAKYmluZm10X21pc2MgICAgICAg
ICAgICAyMDQ4MCAgMQpubHNfaXNvODg1OV8xICAgICAgICAgIDE2Mzg0ICAxCmFyYzQgICAgICAg
ICAgICAgICAgICAgMTYzODQgIDIKaGlkX211bHRpdG91Y2ggICAgICAgICAyMDQ4MCAgMAppbnRl
bF9yYXBsICAgICAgICAgICAgIDIwNDgwICAwCmRlbGxfbGFwdG9wICAgICAgICAgICAgMjA0ODAg
IDEKeDg2X3BrZ190ZW1wX3RoZXJtYWwgICAgMTYzODQgIDAKZGVsbF9zbW1faHdtb24gICAgICAg
ICAxNjM4NCAgMAppbnRlbF9wb3dlcmNsYW1wICAgICAgIDE2Mzg0ICAwCmNvcmV0ZW1wICAgICAg
ICAgICAgICAgMTYzODQgIDAKdXZjdmlkZW8gICAgICAgICAgICAgICA5NDIwOCAgMAprdm1faW50
ZWwgICAgICAgICAgICAgMjA4ODk2ICAwCnNuZF9oZGFfY29kZWNfcmVhbHRlayAgIDEwNjQ5NiAg
MQpzbmRfaGRhX2NvZGVjX2dlbmVyaWMgICAgNzM3MjggIDEgc25kX2hkYV9jb2RlY19yZWFsdGVr
Cmt2bSAgICAgICAgICAgICAgICAgICA2MjY2ODggIDEga3ZtX2ludGVsCnZpZGVvYnVmMl92bWFs
bG9jICAgICAgMTYzODQgIDEgdXZjdmlkZW8KaXJxYnlwYXNzICAgICAgICAgICAgICAxNjM4NCAg
MSBrdm0KdmlkZW9idWYyX21lbW9wcyAgICAgICAxNjM4NCAgMSB2aWRlb2J1ZjJfdm1hbGxvYwp2
aWRlb2J1ZjJfdjRsMiAgICAgICAgIDI0NTc2ICAxIHV2Y3ZpZGVvCmNyY3QxMGRpZl9wY2xtdWwg
ICAgICAgMTYzODQgIDAKdmlkZW9idWYyX2NvbW1vbiAgICAgICA0MDk2MCAgMiB2aWRlb2J1ZjJf
djRsMix1dmN2aWRlbwpjcmMzMl9wY2xtdWwgICAgICAgICAgIDE2Mzg0ICAwCnZpZGVvZGV2ICAg
ICAgICAgICAgICAxODg0MTYgIDMgdmlkZW9idWYyX3Y0bDIsdXZjdmlkZW8sdmlkZW9idWYyX2Nv
bW1vbgpzbmRfaGRhX2ludGVsICAgICAgICAgIDQwOTYwICA2CmdoYXNoX2NsbXVsbmlfaW50ZWwg
ICAgMTYzODQgIDAKcGNiYyAgICAgICAgICAgICAgICAgICAxNjM4NCAgMApzbmRfdXNiX2F1ZGlv
ICAgICAgICAgMjI1MjgwICA0CnNuZF9oZGFfY29kZWMgICAgICAgICAxMjY5NzYgIDMgc25kX2hk
YV9jb2RlY19nZW5lcmljLHNuZF9oZGFfaW50ZWwsc25kX2hkYV9jb2RlY19yZWFsdGVrCmJ0dXNi
ICAgICAgICAgICAgICAgICAgNDUwNTYgIDAKbWVkaWEgICAgICAgICAgICAgICAgICA0MDk2MCAg
MiB2aWRlb2Rldix1dmN2aWRlbwpidHJ0bCAgICAgICAgICAgICAgICAgIDE2Mzg0ICAxIGJ0dXNi
CnNuZF91c2JtaWRpX2xpYiAgICAgICAgMzI3NjggIDEgc25kX3VzYl9hdWRpbwpzbmRfaGRhX2Nv
cmUgICAgICAgICAgIDgxOTIwICA0IHNuZF9oZGFfY29kZWNfZ2VuZXJpYyxzbmRfaGRhX2ludGVs
LHNuZF9oZGFfY29kZWMsc25kX2hkYV9jb2RlY19yZWFsdGVrCmJ0YmNtICAgICAgICAgICAgICAg
ICAgMTYzODQgIDEgYnR1c2IKYWVzbmlfaW50ZWwgICAgICAgICAgIDIwMDcwNCAgNgpidGludGVs
ICAgICAgICAgICAgICAgIDIwNDgwICAxIGJ0dXNiCnNuZF9od2RlcCAgICAgICAgICAgICAgMjA0
ODAgIDIgc25kX3VzYl9hdWRpbyxzbmRfaGRhX2NvZGVjCmJsdWV0b290aCAgICAgICAgICAgICA1
NTI5NjAgIDQzIGJ0cnRsLGJ0aW50ZWwsYnRiY20sYm5lcCxidHVzYixyZmNvbW0Kc25kX3BjbSAg
ICAgICAgICAgICAgICA5ODMwNCAgOCBzbmRfaGRhX2ludGVsLHNuZF91c2JfYXVkaW8sc25kX2hk
YV9jb2RlYyxzbmRfaGRhX2NvcmUKYWVzX3g4Nl82NCAgICAgICAgICAgICAyMDQ4MCAgMSBhZXNu
aV9pbnRlbApjcnlwdG9fc2ltZCAgICAgICAgICAgIDE2Mzg0ICAxIGFlc25pX2ludGVsCmVjZGhf
Z2VuZXJpYyAgICAgICAgICAgMjQ1NzYgIDIgYmx1ZXRvb3RoCmF0aDEwa19wY2kgICAgICAgICAg
ICAgNDA5NjAgIDAKY3J5cHRkICAgICAgICAgICAgICAgICAyNDU3NiAgMyBjcnlwdG9fc2ltZCxn
aGFzaF9jbG11bG5pX2ludGVsLGFlc25pX2ludGVsCmF0aDEwa19jb3JlICAgICAgICAgICA0MTc3
OTIgIDEgYXRoMTBrX3BjaQpnbHVlX2hlbHBlciAgICAgICAgICAgIDE2Mzg0ICAxIGFlc25pX2lu
dGVsCnNuZF9zZXFfbWlkaSAgICAgICAgICAgMTYzODQgIDAKc25kX3NlcV9taWRpX2V2ZW50ICAg
ICAxNjM4NCAgMSBzbmRfc2VxX21pZGkKYXRoICAgICAgICAgICAgICAgICAgICAzMjc2OCAgMSBh
dGgxMGtfY29yZQppbnRlbF9jc3RhdGUgICAgICAgICAgIDIwNDgwICAwCnNuZF9yYXdtaWRpICAg
ICAgICAgICAgMzI3NjggIDIgc25kX3NlcV9taWRpLHNuZF91c2JtaWRpX2xpYgppbnRlbF9yYXBs
X3BlcmYgICAgICAgIDE2Mzg0ICAwCm1hYzgwMjExICAgICAgICAgICAgICA4MDI4MTYgIDEgYXRo
MTBrX2NvcmUKc25kX3NlcSAgICAgICAgICAgICAgICA2NTUzNiAgOSBzbmRfc2VxX21pZGksc25k
X3NlcV9taWRpX2V2ZW50LHNuZF9zZXFfZHVtbXkKc25kX3NlcV9kZXZpY2UgICAgICAgICAxNjM4
NCAgMyBzbmRfc2VxLHNuZF9zZXFfbWlkaSxzbmRfcmF3bWlkaQpqb3lkZXYgICAgICAgICAgICAg
ICAgIDI0NTc2ICAwCnNuZF90aW1lciAgICAgICAgICAgICAgMzI3NjggIDIgc25kX3NlcSxzbmRf
cGNtCmlucHV0X2xlZHMgICAgICAgICAgICAgMTYzODQgIDAKZGVsbF93bWkgICAgICAgICAgICAg
ICAxNjM4NCAgMApzZXJpb19yYXcgICAgICAgICAgICAgIDE2Mzg0ICAwCmNmZzgwMjExICAgICAg
ICAgICAgICA2Njc2NDggIDMgYXRoLG1hYzgwMjExLGF0aDEwa19jb3JlCmlkbWE2NCAgICAgICAg
ICAgICAgICAgMjA0ODAgIDAKZGVsbF9zbWJpb3MgICAgICAgICAgICAyNDU3NiAgMiBkZWxsX3dt
aSxkZWxsX2xhcHRvcApzbmQgICAgICAgICAgICAgICAgICAgIDgxOTIwICAzMiBzbmRfaGRhX2Nv
ZGVjX2dlbmVyaWMsc25kX3NlcSxzbmRfc2VxX2RldmljZSxzbmRfaHdkZXAsc25kX2hkYV9pbnRl
bCxzbmRfdXNiX2F1ZGlvLHNuZF91c2JtaWRpX2xpYixzbmRfaGRhX2NvZGVjLHNuZF9oZGFfY29k
ZWNfcmVhbHRlayxzbmRfdGltZXIsc25kX3BjbSxzbmRfcmF3bWlkaQp2aXJ0X2RtYSAgICAgICAg
ICAgICAgIDE2Mzg0ICAxIGlkbWE2NApkY2RiYXMgICAgICAgICAgICAgICAgIDE2Mzg0ICAxIGRl
bGxfc21iaW9zCm1laV9tZSAgICAgICAgICAgICAgICAgNDA5NjAgIDAKd21pX2Jtb2YgICAgICAg
ICAgICAgICAxNjM4NCAgMApzb3VuZGNvcmUgICAgICAgICAgICAgIDE2Mzg0ICAxIHNuZAppbnRl
bF9scHNzX3BjaSAgICAgICAgIDIwNDgwICAwCmRlbGxfd21pX2Rlc2NyaXB0b3IgICAgMTYzODQg
IDIgZGVsbF93bWksZGVsbF9zbWJpb3MKbWVpICAgICAgICAgICAgICAgICAgICA5ODMwNCAgMSBt
ZWlfbWUKcHJvY2Vzc29yX3RoZXJtYWxfZGV2aWNlICAgIDE2Mzg0ICAwCmludGVsX2xwc3MgICAg
ICAgICAgICAgMTYzODQgIDEgaW50ZWxfbHBzc19wY2kKaW50ZWxfc29jX2R0c19pb3NmICAgICAx
NjM4NCAgMSBwcm9jZXNzb3JfdGhlcm1hbF9kZXZpY2UKaW50ZWxfcGNoX3RoZXJtYWwgICAgICAx
NjM4NCAgMAppbnQzNDAzX3RoZXJtYWwgICAgICAgIDE2Mzg0ICAwCmludGVsX2hpZCAgICAgICAg
ICAgICAgMTYzODQgIDAKaW50MzQwMF90aGVybWFsICAgICAgICAxNjM4NCAgMApzcGFyc2Vfa2V5
bWFwICAgICAgICAgIDE2Mzg0ICAyIGludGVsX2hpZCxkZWxsX3dtaQphY3BpX3RoZXJtYWxfcmVs
ICAgICAgIDE2Mzg0ICAxIGludDM0MDBfdGhlcm1hbAppbnQzNDAyX3RoZXJtYWwgICAgICAgIDE2
Mzg0ICAwCmludDM0MHhfdGhlcm1hbF96b25lICAgIDE2Mzg0ICAzIGludDM0MDNfdGhlcm1hbCxp
bnQzNDAyX3RoZXJtYWwscHJvY2Vzc29yX3RoZXJtYWxfZGV2aWNlCm1hY19oaWQgICAgICAgICAg
ICAgICAgMTYzODQgIDAKYWNwaV9wYWQgICAgICAgICAgICAgIDE4MDIyNCAgMApzY2hfZnFfY29k
ZWwgICAgICAgICAgIDIwNDgwICAyCm52aWRpYV91dm0gICAgICAgICAgICA3OTg3MjAgIDAKdmhj
aV9oY2QgICAgICAgICAgICAgICA0OTE1MiAgMAp1c2JpcF9jb3JlICAgICAgICAgICAgIDMyNzY4
ICAxIHZoY2lfaGNkCnBhcnBvcnRfcGMgICAgICAgICAgICAgMzY4NjQgIDAKcHBkZXYgICAgICAg
ICAgICAgICAgICAyMDQ4MCAgMApscCAgICAgICAgICAgICAgICAgICAgIDIwNDgwICAwCnN1bnJw
YyAgICAgICAgICAgICAgICAzNTIyNTYgIDEKcGFycG9ydCAgICAgICAgICAgICAgICA0OTE1MiAg
MyBwYXJwb3J0X3BjLGxwLHBwZGV2CmJpbmRlcl9saW51eCAgICAgICAgICAxMDI0MDAgIDAKYXNo
bWVtX2xpbnV4ICAgICAgICAgICAxNjM4NCAgMAppcF90YWJsZXMgICAgICAgICAgICAgIDI4Njcy
ICAxIGlwdGFibGVfZmlsdGVyCnhfdGFibGVzICAgICAgICAgICAgICAgNDA5NjAgIDIgaXB0YWJs
ZV9maWx0ZXIsaXBfdGFibGVzCmF1dG9mczQgICAgICAgICAgICAgICAgNDA5NjAgIDIKYnRyZnMg
ICAgICAgICAgICAgICAgMTE2MzI2NCAgMAp6c3RkX2NvbXByZXNzICAgICAgICAgMTYzODQwICAx
IGJ0cmZzCnJhaWQxMCAgICAgICAgICAgICAgICAgNTMyNDggIDAKcmFpZDQ1NiAgICAgICAgICAg
ICAgIDE1MTU1MiAgMAphc3luY19yYWlkNl9yZWNvdiAgICAgIDIwNDgwICAxIHJhaWQ0NTYKYXN5
bmNfbWVtY3B5ICAgICAgICAgICAxNjM4NCAgMiByYWlkNDU2LGFzeW5jX3JhaWQ2X3JlY292CmFz
eW5jX3BxICAgICAgICAgICAgICAgMTYzODQgIDIgcmFpZDQ1Nixhc3luY19yYWlkNl9yZWNvdgph
c3luY194b3IgICAgICAgICAgICAgIDE2Mzg0ICAzIGFzeW5jX3BxLHJhaWQ0NTYsYXN5bmNfcmFp
ZDZfcmVjb3YKYXN5bmNfdHggICAgICAgICAgICAgICAxNjM4NCAgNSBhc3luY19wcSxhc3luY19t
ZW1jcHksYXN5bmNfeG9yLHJhaWQ0NTYsYXN5bmNfcmFpZDZfcmVjb3YKeG9yICAgICAgICAgICAg
ICAgICAgICAyNDU3NiAgMiBhc3luY194b3IsYnRyZnMKcmFpZDZfcHEgICAgICAgICAgICAgIDEx
NDY4OCAgNCBhc3luY19wcSxidHJmcyxyYWlkNDU2LGFzeW5jX3JhaWQ2X3JlY292CmxpYmNyYzMy
YyAgICAgICAgICAgICAgMTYzODQgIDIgYnRyZnMscmFpZDQ1NgpyYWlkMSAgICAgICAgICAgICAg
ICAgIDQwOTYwICAwCnJhaWQwICAgICAgICAgICAgICAgICAgMjA0ODAgIDAKbXVsdGlwYXRoICAg
ICAgICAgICAgICAxNjM4NCAgMApsaW5lYXIgICAgICAgICAgICAgICAgIDE2Mzg0ICAwCmRtX21p
cnJvciAgICAgICAgICAgICAgMjQ1NzYgIDAKZG1fcmVnaW9uX2hhc2ggICAgICAgICAyMDQ4MCAg
MSBkbV9taXJyb3IKZG1fbG9nICAgICAgICAgICAgICAgICAyMDQ4MCAgMiBkbV9yZWdpb25faGFz
aCxkbV9taXJyb3IKaGlkX2dlbmVyaWMgICAgICAgICAgICAxNjM4NCAgMAp1c2JoaWQgICAgICAg
ICAgICAgICAgIDQ5MTUyICAwCm52aWRpYV9kcm0gICAgICAgICAgICAgNDA5NjAgIDEzCm52aWRp
YV9tb2Rlc2V0ICAgICAgIDEwODU0NDAgIDMzIG52aWRpYV9kcm0KbnZpZGlhICAgICAgICAgICAg
ICAxNzYwMDUxMiAgMTY4MyBudmlkaWFfdXZtLG52aWRpYV9tb2Rlc2V0Cmk5MTUgICAgICAgICAg
ICAgICAgIDE3NDA4MDAgIDMKbXhtX3dtaSAgICAgICAgICAgICAgICAxNjM4NCAgMAppMmNfYWxn
b19iaXQgICAgICAgICAgIDE2Mzg0ICAxIGk5MTUKZHJtX2ttc19oZWxwZXIgICAgICAgIDE3MjAz
MiAgMiBudmlkaWFfZHJtLGk5MTUKc3lzY29weWFyZWEgICAgICAgICAgICAxNjM4NCAgMSBkcm1f
a21zX2hlbHBlcgpzeXNmaWxscmVjdCAgICAgICAgICAgIDE2Mzg0ICAxIGRybV9rbXNfaGVscGVy
CnN5c2ltZ2JsdCAgICAgICAgICAgICAgMTYzODQgIDEgZHJtX2ttc19oZWxwZXIKZmJfc3lzX2Zv
cHMgICAgICAgICAgICAxNjM4NCAgMSBkcm1fa21zX2hlbHBlcgpwc21vdXNlICAgICAgICAgICAg
ICAgMTUxNTUyICAwCmRybSAgICAgICAgICAgICAgICAgICA0NTg3NTIgIDE2IGRybV9rbXNfaGVs
cGVyLG52aWRpYV9kcm0saTkxNQpyODE2OSAgICAgICAgICAgICAgICAgIDg2MDE2ICAwCmFoY2kg
ICAgICAgICAgICAgICAgICAgNDA5NjAgIDUKaXBtaV9kZXZpbnRmICAgICAgICAgICAyMDQ4MCAg
MAptaWkgICAgICAgICAgICAgICAgICAgIDE2Mzg0ICAxIHI4MTY5CmxpYmFoY2kgICAgICAgICAg
ICAgICAgMzI3NjggIDEgYWhjaQppcG1pX21zZ2hhbmRsZXIgICAgICAgMTAyNDAwICAyIGlwbWlf
ZGV2aW50ZixudmlkaWEKaTJjX2hpZCAgICAgICAgICAgICAgICAyMDQ4MCAgMApoaWQgICAgICAg
ICAgICAgICAgICAgMTIyODgwICA0IGkyY19oaWQsdXNiaGlkLGhpZF9tdWx0aXRvdWNoLGhpZF9n
ZW5lcmljCndtaSAgICAgICAgICAgICAgICAgICAgMjQ1NzYgIDUgZGVsbF93bWksd21pX2Jtb2Ys
ZGVsbF9zbWJpb3MsZGVsbF93bWlfZGVzY3JpcHRvcixteG1fd21pCnZpZGVvICAgICAgICAgICAg
ICAgICAgNDUwNTYgIDMgZGVsbF93bWksZGVsbF9sYXB0b3AsaTkxNQogICAgICAgICAgICAgIHRv
dGFsICAgICAgICB1c2VkICAgICAgICBmcmVlICAgICAgc2hhcmVkICBidWZmL2NhY2hlICAgYXZh
aWxhYmxlCk1lbTogICAgICAgMTYyODgwMzYgICAgIDgyMjYyMDAgICAgIDEwOTQwNzIgICAgICA1
NDM4MTIgICAgIDY5Njc3NjQgICAgIDcyNTQ1MTIKU3dhcDogICAgICAxNjcyNjAxMiAgICAgICAg
ICAgMCAgICAxNjcyNjAxMgovdXNyL2xpYi9wbS11dGlscy9zbGVlcC5kLzAwbG9nZ2luZyBoaWJl
cm5hdGUgaGliZXJuYXRlOiBzdWNjZXNzLgoKUnVubmluZyBob29rIC91c3IvbGliL3BtLXV0aWxz
L3NsZWVwLmQvMDBwb3dlcnNhdmUgaGliZXJuYXRlIGhpYmVybmF0ZToKL3Vzci9saWIvcG0tdXRp
bHMvc2xlZXAuZC8wMHBvd2Vyc2F2ZSBoaWJlcm5hdGUgaGliZXJuYXRlOiBzdWNjZXNzLgoKUnVu
bmluZyBob29rIC9ldGMvcG0vc2xlZXAuZC8xMF9ncnViLWNvbW1vbiBoaWJlcm5hdGUgaGliZXJu
YXRlOgovZXRjL3BtL3NsZWVwLmQvMTBfZ3J1Yi1jb21tb24gaGliZXJuYXRlIGhpYmVybmF0ZTog
c3VjY2Vzcy4KClJ1bm5pbmcgaG9vayAvZXRjL3BtL3NsZWVwLmQvMTBfdW5hdHRlbmRlZC11cGdy
YWRlcy1oaWJlcm5hdGUgaGliZXJuYXRlIGhpYmVybmF0ZToKL2V0Yy9wbS9zbGVlcC5kLzEwX3Vu
YXR0ZW5kZWQtdXBncmFkZXMtaGliZXJuYXRlIGhpYmVybmF0ZSBoaWJlcm5hdGU6IHN1Y2Nlc3Mu
CgpSdW5uaW5nIGhvb2sgL3Vzci9saWIvcG0tdXRpbHMvc2xlZXAuZC8yMHR1eG9uaWNlIGhpYmVy
bmF0ZSBoaWJlcm5hdGU6Ci91c3IvbGliL3BtLXV0aWxzL3NsZWVwLmQvMjB0dXhvbmljZSBoaWJl
cm5hdGUgaGliZXJuYXRlOiBub3QgYXBwbGljYWJsZS4KClJ1bm5pbmcgaG9vayAvdXNyL2xpYi9w
bS11dGlscy9zbGVlcC5kLzQwaW5wdXRhdHRhY2ggaGliZXJuYXRlIGhpYmVybmF0ZToKL3Vzci9s
aWIvcG0tdXRpbHMvc2xlZXAuZC80MGlucHV0YXR0YWNoIGhpYmVybmF0ZSBoaWJlcm5hdGU6IHN1
Y2Nlc3MuCgpSdW5uaW5nIGhvb2sgL3Vzci9saWIvcG0tdXRpbHMvc2xlZXAuZC81MHVubG9hZF9h
bHggaGliZXJuYXRlIGhpYmVybmF0ZToKL3Vzci9saWIvcG0tdXRpbHMvc2xlZXAuZC81MHVubG9h
ZF9hbHggaGliZXJuYXRlIGhpYmVybmF0ZTogc3VjY2Vzcy4KClJ1bm5pbmcgaG9vayAvdXNyL2xp
Yi9wbS11dGlscy9zbGVlcC5kLzYwX3dwYV9zdXBwbGljYW50IGhpYmVybmF0ZSBoaWJlcm5hdGU6
ClNlbGVjdGVkIGludGVyZmFjZSAncDJwLWRldi13bHAzczAnCk9LCi91c3IvbGliL3BtLXV0aWxz
L3NsZWVwLmQvNjBfd3BhX3N1cHBsaWNhbnQgaGliZXJuYXRlIGhpYmVybmF0ZTogc3VjY2Vzcy4K
ClJ1bm5pbmcgaG9vayAvdXNyL2xpYi9wbS11dGlscy9zbGVlcC5kLzc1bW9kdWxlcyBoaWJlcm5h
dGUgaGliZXJuYXRlOgovdXNyL2xpYi9wbS11dGlscy9zbGVlcC5kLzc1bW9kdWxlcyBoaWJlcm5h
dGUgaGliZXJuYXRlOiBub3QgYXBwbGljYWJsZS4KClJ1bm5pbmcgaG9vayAvdXNyL2xpYi9wbS11
dGlscy9zbGVlcC5kLzkwY2xvY2sgaGliZXJuYXRlIGhpYmVybmF0ZToKL3Vzci9saWIvcG0tdXRp
bHMvc2xlZXAuZC85MGNsb2NrIGhpYmVybmF0ZSBoaWJlcm5hdGU6IG5vdCBhcHBsaWNhYmxlLgoK
UnVubmluZyBob29rIC91c3IvbGliL3BtLXV0aWxzL3NsZWVwLmQvOTRjcHVmcmVxIGhpYmVybmF0
ZSBoaWJlcm5hdGU6Ci91c3IvbGliL3BtLXV0aWxzL3NsZWVwLmQvOTRjcHVmcmVxIGhpYmVybmF0
ZSBoaWJlcm5hdGU6IHN1Y2Nlc3MuCgpSdW5uaW5nIGhvb2sgL3Vzci9saWIvcG0tdXRpbHMvc2xl
ZXAuZC85NWFuYWNyb24gaGliZXJuYXRlIGhpYmVybmF0ZToKV2FybmluZzogU3RvcHBpbmcgYW5h
Y3Jvbi5zZXJ2aWNlLCBidXQgaXQgY2FuIHN0aWxsIGJlIGFjdGl2YXRlZCBieToKICBhbmFjcm9u
LnRpbWVyCi91c3IvbGliL3BtLXV0aWxzL3NsZWVwLmQvOTVhbmFjcm9uIGhpYmVybmF0ZSBoaWJl
cm5hdGU6IHN1Y2Nlc3MuCgpSdW5uaW5nIGhvb2sgL3Vzci9saWIvcG0tdXRpbHMvc2xlZXAuZC85
NWhkcGFybS1hcG0gaGliZXJuYXRlIGhpYmVybmF0ZToKL3Vzci9saWIvcG0tdXRpbHMvc2xlZXAu
ZC85NWhkcGFybS1hcG0gaGliZXJuYXRlIGhpYmVybmF0ZTogbm90IGFwcGxpY2FibGUuCgpSdW5u
aW5nIGhvb2sgL3Vzci9saWIvcG0tdXRpbHMvc2xlZXAuZC85NWxlZCBoaWJlcm5hdGUgaGliZXJu
YXRlOgovdXNyL2xpYi9wbS11dGlscy9zbGVlcC5kLzk1bGVkIGhpYmVybmF0ZSBoaWJlcm5hdGU6
IG5vdCBhcHBsaWNhYmxlLgoKUnVubmluZyBob29rIC91c3IvbGliL3BtLXV0aWxzL3NsZWVwLmQv
OTh2aWRlby1xdWlyay1kYi1oYW5kbGVyIGhpYmVybmF0ZSBoaWJlcm5hdGU6Cktlcm5lbCBtb2Rl
c2V0dGluZyB2aWRlbyBkcml2ZXIgZGV0ZWN0ZWQsIG5vdCB1c2luZyBxdWlya3MuCi91c3IvbGli
L3BtLXV0aWxzL3NsZWVwLmQvOTh2aWRlby1xdWlyay1kYi1oYW5kbGVyIGhpYmVybmF0ZSBoaWJl
cm5hdGU6IHN1Y2Nlc3MuCgpSdW5uaW5nIGhvb2sgL3Vzci9saWIvcG0tdXRpbHMvc2xlZXAuZC85
OTltb3VudGEgaGliZXJuYXRlIGhpYmVybmF0ZToKL3Vzci9saWIvcG0tdXRpbHMvc2xlZXAuZC85
OTltb3VudGEgaGliZXJuYXRlIGhpYmVybmF0ZTogc3VjY2Vzcy4KClJ1bm5pbmcgaG9vayAvZXRj
L3BtL3NsZWVwLmQvOTlfaGliZXJuYXRlX3NjcmlwdHMgaGliZXJuYXRlIGhpYmVybmF0ZToKL2V0
Yy9wbS9zbGVlcC5kLzk5X2hpYmVybmF0ZV9zY3JpcHRzIGhpYmVybmF0ZSBoaWJlcm5hdGU6IHN1
Y2Nlc3MuCgpSdW5uaW5nIGhvb2sgL3Vzci9saWIvcG0tdXRpbHMvc2xlZXAuZC85OXZpZGVvIGhp
YmVybmF0ZSBoaWJlcm5hdGU6Ci91c3IvbGliL3BtLXV0aWxzL3NsZWVwLmQvOTl2aWRlbyBoaWJl
cm5hdGUgaGliZXJuYXRlOiBzdWNjZXNzLgoKcXVhIGFiciAgMyAxNToyNDo1MSAtMDMgMjAxOTog
cGVyZm9ybWluZyBoaWJlcm5hdGUK
--000000000000367cd40585a4fb5f
Content-Type: application/octet-stream; name=boot-sequence
Content-Disposition: attachment; filename=boot-sequence
Content-Transfer-Encoding: base64
Content-ID: <f_ju1k9g0p1>
X-Attachment-Id: f_ju1k9g0p1

cmVjb3JkZmFpbApsb2FkX3ZpZGVvCmdmeG1vZGUgJGxpbnV4X2dmeF9tb2RlCmluc21vZCBnemlv
CmlmIFsgeCRncnViX3BsYXRmb3JtID0geHhlbiBdOyB0aGVuIGluc21vZCB4emlvOyBpbnNtb2Qg
bHpvcGlvOyBmaQppbnNtb2QgcGFydF9ncHQKaW5zbW9kIGV4dDIKc2V0IHJvb3Q9J2hkMCxncHQ3
JwppZiBbIHgkZmVhdHVyZV9wbGF0Zm9ybV9zZWFyY2hfaGludCA9IHh5IF07IHRoZW4KICBzZWFy
Y2ggLS1uby1mbG9wcHkgLS1mcy11dWlkIC0tc2V0PXJvb3QgLS1oaW50LWJpb3M9aGQwLGdwdDcg
LS1oaW50LWVmaT1oZDAsZ3B0NyAtLWhpbnQtYmFyZW1ldGFsPWFoY2kwLGdwdDcgIDY1OWRiMTRj
LTJhNmMtNGY5Yy05M2JmLWQzMWM0YTg0YWJiNgplbHNlCiAgc2VhcmNoIC0tbm8tZmxvcHB5IC0t
ZnMtdXVpZCAtLXNldD1yb290IDY1OWRiMTRjLTJhNmMtNGY5Yy05M2JmLWQzMWM0YTg0YWJiNgpm
aQogICAgICAgIGxpbnV4CS9ib290L3ZtbGludXotNC4xOC4wLTE3LWdlbmVyaWMgcm9vdD1VVUlE
PTY1OWRiMTRjLTJhNmMtNGY5Yy05M2JmLWQzMWM0YTg0YWJiNiBybyBub3V2ZWF1LmJsYWNrbGlz
dD0xIGRlYnVnIG5vX2NvbnNvbGVfc3VzcGVuZCBzeXN0ZW1kLmxvZ19sZXZlbD1pbmZvIG52aWRp
YS1kcm0ubW9kZXNldD0wICNzcGxhc2ggcXVpZXQgcmVzdW1lPTcwZDk2N2U2LWFkNTItNGMyMS1i
YWYwLTAxYTgxM2NjYzZhYwppbml0cmQJL2Jvb3QvaW5pdHJkLmltZy00LjE4LjAtMTctZ2VuZXJp
YwoK
--000000000000367cd40585a4fb5f--

