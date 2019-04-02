Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0CFADC4360F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 23:25:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C3A2620663
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 23:25:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C3A2620663
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4B5956B0269; Tue,  2 Apr 2019 19:25:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4649D6B026D; Tue,  2 Apr 2019 19:25:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 37D6C6B0272; Tue,  2 Apr 2019 19:25:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id F32356B0269
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 19:25:07 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id e19so4920198pfd.19
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 16:25:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=V7nv4ms1GE0QdClMikzCeVo0vlzjR33GTUsLRHmQ0ao=;
        b=mFsXga0T+cif1r8rSkEUFrVxjRG4INYNzkBZ9vZzRA+39vkptO2fQ1qh7z26qVIprC
         BbtRawFuFu6FHhK6Or3Np60orfoFVhMC585nC00ndJvgV/92a7JGeyLepqie9getg4HL
         JPEpOMibH3Kt8NVnOIM/+HRCws6EVdnUmFnfNSw1O4xO2c5gsmNP3BH32ueQMGUPH3IZ
         OHqA8Xbp2sMkeE2BWnvQLOR3vAFQhZkPYOlDzyU+M1aDW1LH0XKueajfsAJj803UbwpW
         1Xo7Q6uIua7Rzsa660xxyMNLXF5VrEZ0kbfjdp7FIHECvkpAzYRFcCIZu4P8erg3/i5Q
         UYsQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAVQeb195pp8Tdpxr/oZzyzIPCLKpQx/g5ZBqDyscMpiG/sZX+H6
	93f6yef4cc5Fgcy23WguAeSz1gbxjQQ8BulrKQkSSRHsIkhUY67ppkM2p6Lp/Ukpz+nEZVj3Bdw
	lXLbaacXrRQamyYoGglBihOQ+ubihpPY7OEl/vmEaIrRcIIEfFAQiV692pr7V23M4dQ==
X-Received: by 2002:a62:6490:: with SMTP id y138mr58495768pfb.230.1554247507599;
        Tue, 02 Apr 2019 16:25:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyu3iZ7xfMmXtAbPl197UUAIr+qSQedzCNd9E1PtUkDc5bPvX8x6jhcoTlHHBymVhJHJ6be
X-Received: by 2002:a62:6490:: with SMTP id y138mr58495555pfb.230.1554247504757;
        Tue, 02 Apr 2019 16:25:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554247504; cv=none;
        d=google.com; s=arc-20160816;
        b=wKUNXgnBlqxgAuiNY+anvJ2urQ2SUh7uNVzu4oOdHPz/VFwc8KsW53tnJXUqyLlsos
         CEwq7O0tnX4oBAZSzs2uE9Mm+Zy8UKP1gSU3ZFJBBKhVDrwSL8G+JMewYdAaleL9HLVH
         yAQJpxmxxnoixjxMiX75DWDqTf5zqnhcdLEbCqk4cHMup1rdABSkCtwjKh4UxkmGqzWU
         ISRZz815U7QLtLGc6iBqRbkyxpAlephNvdbfmUeCVZQIDLBTyBcsMwaTQVyylQEp5n1l
         gzfa47fzmREmkjTTSLGORCsXbzXl0SooPT7vGyQ241/Vfd+M7BIkS6JZIq0/FfZiUVN6
         tnsw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=V7nv4ms1GE0QdClMikzCeVo0vlzjR33GTUsLRHmQ0ao=;
        b=PWrt78q7hl/qzzUiftExJcT2keGvrgTtc2IZXEMcI0KCSnDQZmJ+Cp2g2YOo9wCMTC
         3gtLpCK0KpjWhiEDpuOegx668rsv4hSLPiluGp+0vcb8jIkUuFXN9tWm8ECRwUGbxQim
         2b9ZEPYb9uzzWQ9ei+dgQNMHwX0/I2BkWrbHkMd1y2u0hC1RgpjDFFFbsUpTZECOgHMh
         8qDyqZYbvA6o1ZHAHRvWUJxEZOZ0iUV3JxzDNel+AHIWBnQNjPhz+gMjkaetJVImT6OP
         9P8In2jSaxkyvi6FMa/iPlgg3x7LJaSOFsUYmOMLRq8sjkuShnxhITivNa5wji7Je6jy
         NfMw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s3si12473507pgl.380.2019.04.02.16.25.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 16:25:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 96557DDE;
	Tue,  2 Apr 2019 23:25:03 +0000 (UTC)
Date: Tue, 2 Apr 2019 16:25:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, =?ISO-8859-1?Q?"Rodolfo_Garc=EDa?=
 =?ISO-8859-1?Q?_Pe=F1as_(kix)"?= <kix@kix.es>, Oliver Winker
 <oliverml1@oli1170.net>, Jan Kara <jack@suse.cz>,
 bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, Maxim Patlasov
 <mpatlasov@parallels.com>, Fengguang Wu <fengguang.wu@intel.com>, Tejun Heo
 <tj@kernel.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>,
 killian.de.volder@megasoft.be, atillakaraca72@hotmail.com, jrf@mailbox.org,
 matheusfillipeag@gmail.com
Subject: Re: [Bug 75101] New: [bisected] s2disk / hibernate blocks on
 "Saving 506031 image data pages () ..."
Message-Id: <20190402162500.def729ec05e6e267bff8a5da@linux-foundation.org>
In-Reply-To: <539F1B66.2020006@intel.com>
References: <20140505233358.GC19914@cmpxchg.org>
	<5368227D.7060302@intel.com>
	<20140612220200.GA25344@cmpxchg.org>
	<539A3CD7.6080100@intel.com>
	<20140613045557.GL2878@cmpxchg.org>
	<539F1B66.2020006@intel.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


I cc'ed a bunch of people from bugzilla.

Folks, please please please remember to reply via emailed
reply-to-all.  Don't use the bugzilla interface!

On Mon, 16 Jun 2014 18:29:26 +0200 "Rafael J. Wysocki" <rafael.j.wysocki@intel.com> wrote:

> On 6/13/2014 6:55 AM, Johannes Weiner wrote:
> > On Fri, Jun 13, 2014 at 01:50:47AM +0200, Rafael J. Wysocki wrote:
> >> On 6/13/2014 12:02 AM, Johannes Weiner wrote:
> >>> On Tue, May 06, 2014 at 01:45:01AM +0200, Rafael J. Wysocki wrote:
> >>>> On 5/6/2014 1:33 AM, Johannes Weiner wrote:
> >>>>> Hi Oliver,
> >>>>>
> >>>>> On Mon, May 05, 2014 at 11:00:13PM +0200, Oliver Winker wrote:
> >>>>>> Hello,
> >>>>>>
> >>>>>> 1) Attached a full function-trace log + other SysRq outputs, see [1]
> >>>>>> attached.
> >>>>>>
> >>>>>> I saw bdi_...() calls in the s2disk paths, but didn't check in detail
> >>>>>> Probably more efficient when one of you guys looks directly.
> >>>>> Thanks, this looks interesting.  balance_dirty_pages() wakes up the
> >>>>> bdi_wq workqueue as it should:
> >>>>>
> >>>>> [  249.148009]   s2disk-3327    2.... 48550413us : global_dirty_limits <-balance_dirty_pages_ratelimited
> >>>>> [  249.148009]   s2disk-3327    2.... 48550414us : global_dirtyable_memory <-global_dirty_limits
> >>>>> [  249.148009]   s2disk-3327    2.... 48550414us : writeback_in_progress <-balance_dirty_pages_ratelimited
> >>>>> [  249.148009]   s2disk-3327    2.... 48550414us : bdi_start_background_writeback <-balance_dirty_pages_ratelimited
> >>>>> [  249.148009]   s2disk-3327    2.... 48550414us : mod_delayed_work_on <-balance_dirty_pages_ratelimited
> >>>>> but the worker wakeup doesn't actually do anything:
> >>>>> [  249.148009] kworker/-3466    2d... 48550431us : finish_task_switch <-__schedule
> >>>>> [  249.148009] kworker/-3466    2.... 48550431us : _raw_spin_lock_irq <-worker_thread
> >>>>> [  249.148009] kworker/-3466    2d... 48550431us : need_to_create_worker <-worker_thread
> >>>>> [  249.148009] kworker/-3466    2d... 48550432us : worker_enter_idle <-worker_thread
> >>>>> [  249.148009] kworker/-3466    2d... 48550432us : too_many_workers <-worker_enter_idle
> >>>>> [  249.148009] kworker/-3466    2.... 48550432us : schedule <-worker_thread
> >>>>> [  249.148009] kworker/-3466    2.... 48550432us : __schedule <-worker_thread
> >>>>>
> >>>>> My suspicion is that this fails because the bdi_wq is frozen at this
> >>>>> point and so the flush work never runs until resume, whereas before my
> >>>>> patch the effective dirty limit was high enough so that image could be
> >>>>> written in one go without being throttled; followed by an fsync() that
> >>>>> then writes the pages in the context of the unfrozen s2disk.
> >>>>>
> >>>>> Does this make sense?  Rafael?  Tejun?
> >>>> Well, it does seem to make sense to me.
> >>>  From what I see, this is a deadlock in the userspace suspend model and
> >>> just happened to work by chance in the past.
> >> Well, it had been working for quite a while, so it was a rather large
> >> opportunity
> >> window it seems. :-)
> > No doubt about that, and I feel bad that it broke.  But it's still a
> > deadlock that can't reasonably be accommodated from dirty throttling.
> >
> > It can't just put the flushers to sleep and then issue a large amount
> > of buffered IO, hoping it doesn't hit the dirty limits.  Don't shoot
> > the messenger, this bug needs to be addressed, not get papered over.
> >
> >>> Can we patch suspend-utils as follows?
> >> Perhaps we can.  Let's ask the new maintainer.
> >>
> >> Rodolfo, do you think you can apply the patch below to suspend-utils?
> >>
> >>> Alternatively, suspend-utils
> >>> could clear the dirty limits before it starts writing and restore them
> >>> post-resume.
> >> That (and the patch too) doesn't seem to address the problem with existing
> >> suspend-utils
> >> binaries, however.
> > It's userspace that freezes the system before issuing buffered IO, so
> > my conclusion was that the bug is in there.  This is arguable.  I also
> > wouldn't be opposed to a patch that sets the dirty limits to infinity
> > from the ioctl that freezes the system or creates the image.
> 
> OK, that sounds like a workable plan.
> 
> How do I set those limits to infinity?

Five years have passed and people are still hitting this.

Killian described the workaround in comment 14 at
https://bugzilla.kernel.org/show_bug.cgi?id=75101.

People can use this workaround manually by hand or in scripts.  But we
really should find a proper solution.  Maybe special-case the freezing
of the flusher threads until all the writeout has completed.  Or
something else.

