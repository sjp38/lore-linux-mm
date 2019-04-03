Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05794C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 09:34:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A8CC02082C
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 09:34:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A8CC02082C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 360046B000C; Wed,  3 Apr 2019 05:34:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 310896B0010; Wed,  3 Apr 2019 05:34:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D98E6B0266; Wed,  3 Apr 2019 05:34:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id BDE506B000C
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 05:34:39 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id e55so7195862edd.6
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 02:34:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=QSwySKQaoN4/GFthRKDPxEhDVtq+Q5jXxoZp2D4Y5PM=;
        b=MdJd/gHBls7DgH04NXRQuqo7MR++5qTFEZznMCGX4lWkGekxw0BMPqGDY79t8SC0mQ
         eYTx8gmh/ygk5Cyi5N+YFq3sEV7zTYb/o1CF69ia4AI0rhdOAsmA7aevjd7Q7blfpbSx
         O5uau8YyOB6KvH9ZLnJEXqJXh9MrPIyCqOaZerQXo6FQ7DliHFKnWDZwO7DVYPj11X34
         HZk/VltM4mnOJyZaHh6BX3VjciaPv1cuHChtcB5HdfIt4xXHkJsVhLWPl3C5/971RMFW
         iQaTsw7IzQaGqgluGJsUexnmHDvPInzTdoVPvCseH884iirhqzrNHZgJvfBeyMsWFL6H
         W/Vw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAVFbRZ0Ve6g4xBIdeGXQRYAQNBVnCUq4B6gvy/81onJWEmrE3Mp
	srCnMjVFtncQcF1Hcy2S/N+NIKLGGfeHdsrW/itdgUkWuaw87Qgd5kX4j4b1PFXMDop08oomyl1
	xLlHgezS6ApL8AOHKT/nfz4mFEHQhAUWx45YWEgqr05FQVxqB/Fq8pnVS7iK10J7ceQ==
X-Received: by 2002:a05:6402:144d:: with SMTP id d13mr9953030edx.64.1554284079284;
        Wed, 03 Apr 2019 02:34:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzRfqJCKV1JE3uxT7e8oBzgPG4TVtxb6PFHkfZzRCHX5ldMtt9lnRcUfryF0MQ/PR1H95JC
X-Received: by 2002:a05:6402:144d:: with SMTP id d13mr9952989edx.64.1554284078256;
        Wed, 03 Apr 2019 02:34:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554284078; cv=none;
        d=google.com; s=arc-20160816;
        b=HlOCdxGdItxxE68hhALWVjS/vMfldJSvJcWETx6xQU1Wbaju3iZCg5N4fCavarmrBk
         hInhKOvhfh1uA5E90ohdlk4ghTwYZwuAubVC6I9LmsLiU0+Wmug9MO5A0Inm2eqaFxDP
         uthIZHdVHUuB7Z3E2yFQP3dUuWt58ZCeTQRtjJqGqXPvQ0cw0DpxBqDQdhTyqZWdVOAj
         VQam68x2X5DvPbGzkiiwI+ppKG6vkOVZKmiYOXHP290t0UObZiZhJvydci2nqahSOs94
         9OWqo0DwLj/wmxG4WzNYyUnmrQnBFgMiEI5iyzYl65lWhAFodj7fmnGBsBb184LZOr4c
         oX/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=QSwySKQaoN4/GFthRKDPxEhDVtq+Q5jXxoZp2D4Y5PM=;
        b=hocYk1LD9aChQvS5Zefo2IC99V+kwCEU2xEsAb9v1/14glacBUoVjdv6IjpzkCbvdt
         33p8r52eiIutIth/NmeKlGs1LpLz9PqtQH1M9eBzMUv3EQnrdJwjjEveJ8QC1v2aezuk
         6PpN+mUqIfebgUETXn6ZFnS1zMYenVkDbwTK9Fxzn5zXtR1NLnZ26wwcNsYG0mmyIbL6
         UXYM43bVGolyhffE9MelTLOAj1ATGRNxmmwJm99auo/3HAFD08pWE8XPw2i6od7TQvxi
         DWzWQgR3EsAfkSEq9vEDrdaWsrEz3HSDjdQkIawgdgzDsM6SCGDlA2qwW4QlecGSEjHf
         orKw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m36si2121086edc.49.2019.04.03.02.34.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 02:34:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4441DAEB3;
	Wed,  3 Apr 2019 09:34:37 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id E29811E3FFD; Wed,  3 Apr 2019 11:34:32 +0200 (CEST)
Date: Wed, 3 Apr 2019 11:34:32 +0200
From: Jan Kara <jack@suse.cz>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	 Rodolfo =?iso-8859-1?B?R2FyY+1hIFBl8WFzIChraXgp?= <kix@kix.es>,
	Oliver Winker <oliverml1@oli1170.net>, Jan Kara <jack@suse.cz>,
	bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org,
	Maxim Patlasov <mpatlasov@parallels.com>,
	Fengguang Wu <fengguang.wu@intel.com>, Tejun Heo <tj@kernel.org>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	killian.de.volder@megasoft.be, atillakaraca72@hotmail.com,
	jrf@mailbox.org, matheusfillipeag@gmail.com
Subject: Re: [Bug 75101] New: [bisected] s2disk / hibernate blocks on "Saving
 506031 image data pages () ..."
Message-ID: <20190403093432.GD8836@quack2.suse.cz>
References: <20140505233358.GC19914@cmpxchg.org>
 <5368227D.7060302@intel.com>
 <20140612220200.GA25344@cmpxchg.org>
 <539A3CD7.6080100@intel.com>
 <20140613045557.GL2878@cmpxchg.org>
 <539F1B66.2020006@intel.com>
 <20190402162500.def729ec05e6e267bff8a5da@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190402162500.def729ec05e6e267bff8a5da@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 02-04-19 16:25:00, Andrew Morton wrote:
> 
> I cc'ed a bunch of people from bugzilla.
> 
> Folks, please please please remember to reply via emailed
> reply-to-all.  Don't use the bugzilla interface!
> 
> On Mon, 16 Jun 2014 18:29:26 +0200 "Rafael J. Wysocki" <rafael.j.wysocki@intel.com> wrote:
> 
> > On 6/13/2014 6:55 AM, Johannes Weiner wrote:
> > > On Fri, Jun 13, 2014 at 01:50:47AM +0200, Rafael J. Wysocki wrote:
> > >> On 6/13/2014 12:02 AM, Johannes Weiner wrote:
> > >>> On Tue, May 06, 2014 at 01:45:01AM +0200, Rafael J. Wysocki wrote:
> > >>>> On 5/6/2014 1:33 AM, Johannes Weiner wrote:
> > >>>>> Hi Oliver,
> > >>>>>
> > >>>>> On Mon, May 05, 2014 at 11:00:13PM +0200, Oliver Winker wrote:
> > >>>>>> Hello,
> > >>>>>>
> > >>>>>> 1) Attached a full function-trace log + other SysRq outputs, see [1]
> > >>>>>> attached.
> > >>>>>>
> > >>>>>> I saw bdi_...() calls in the s2disk paths, but didn't check in detail
> > >>>>>> Probably more efficient when one of you guys looks directly.
> > >>>>> Thanks, this looks interesting.  balance_dirty_pages() wakes up the
> > >>>>> bdi_wq workqueue as it should:
> > >>>>>
> > >>>>> [  249.148009]   s2disk-3327    2.... 48550413us : global_dirty_limits <-balance_dirty_pages_ratelimited
> > >>>>> [  249.148009]   s2disk-3327    2.... 48550414us : global_dirtyable_memory <-global_dirty_limits
> > >>>>> [  249.148009]   s2disk-3327    2.... 48550414us : writeback_in_progress <-balance_dirty_pages_ratelimited
> > >>>>> [  249.148009]   s2disk-3327    2.... 48550414us : bdi_start_background_writeback <-balance_dirty_pages_ratelimited
> > >>>>> [  249.148009]   s2disk-3327    2.... 48550414us : mod_delayed_work_on <-balance_dirty_pages_ratelimited
> > >>>>> but the worker wakeup doesn't actually do anything:
> > >>>>> [  249.148009] kworker/-3466    2d... 48550431us : finish_task_switch <-__schedule
> > >>>>> [  249.148009] kworker/-3466    2.... 48550431us : _raw_spin_lock_irq <-worker_thread
> > >>>>> [  249.148009] kworker/-3466    2d... 48550431us : need_to_create_worker <-worker_thread
> > >>>>> [  249.148009] kworker/-3466    2d... 48550432us : worker_enter_idle <-worker_thread
> > >>>>> [  249.148009] kworker/-3466    2d... 48550432us : too_many_workers <-worker_enter_idle
> > >>>>> [  249.148009] kworker/-3466    2.... 48550432us : schedule <-worker_thread
> > >>>>> [  249.148009] kworker/-3466    2.... 48550432us : __schedule <-worker_thread
> > >>>>>
> > >>>>> My suspicion is that this fails because the bdi_wq is frozen at this
> > >>>>> point and so the flush work never runs until resume, whereas before my
> > >>>>> patch the effective dirty limit was high enough so that image could be
> > >>>>> written in one go without being throttled; followed by an fsync() that
> > >>>>> then writes the pages in the context of the unfrozen s2disk.
> > >>>>>
> > >>>>> Does this make sense?  Rafael?  Tejun?
> > >>>> Well, it does seem to make sense to me.
> > >>>  From what I see, this is a deadlock in the userspace suspend model and
> > >>> just happened to work by chance in the past.
> > >> Well, it had been working for quite a while, so it was a rather large
> > >> opportunity
> > >> window it seems. :-)
> > > No doubt about that, and I feel bad that it broke.  But it's still a
> > > deadlock that can't reasonably be accommodated from dirty throttling.
> > >
> > > It can't just put the flushers to sleep and then issue a large amount
> > > of buffered IO, hoping it doesn't hit the dirty limits.  Don't shoot
> > > the messenger, this bug needs to be addressed, not get papered over.
> > >
> > >>> Can we patch suspend-utils as follows?
> > >> Perhaps we can.  Let's ask the new maintainer.
> > >>
> > >> Rodolfo, do you think you can apply the patch below to suspend-utils?
> > >>
> > >>> Alternatively, suspend-utils
> > >>> could clear the dirty limits before it starts writing and restore them
> > >>> post-resume.
> > >> That (and the patch too) doesn't seem to address the problem with existing
> > >> suspend-utils
> > >> binaries, however.
> > > It's userspace that freezes the system before issuing buffered IO, so
> > > my conclusion was that the bug is in there.  This is arguable.  I also
> > > wouldn't be opposed to a patch that sets the dirty limits to infinity
> > > from the ioctl that freezes the system or creates the image.
> > 
> > OK, that sounds like a workable plan.
> > 
> > How do I set those limits to infinity?
> 
> Five years have passed and people are still hitting this.
> 
> Killian described the workaround in comment 14 at
> https://bugzilla.kernel.org/show_bug.cgi?id=75101.
> 
> People can use this workaround manually by hand or in scripts.  But we
> really should find a proper solution.  Maybe special-case the freezing
> of the flusher threads until all the writeout has completed.  Or
> something else.

I've refreshed my memory wrt this bug and I believe the bug is really on
the side of suspend-utils (uswsusp or however it is called). They are low
level system tools, they ask the kernel to freeze all processes
(SNAPSHOT_FREEZE ioctl), and then they rely on buffered writeback (which is
relatively heavyweight infrastructure) to work. That is wrong in my
opinion.

I can see Johanness was suggesting in comment 11 to use O_SYNC in
suspend-utils which worked but was too slow. Indeed O_SYNC is rather big
hammer but using O_DIRECT should be what they need and get better
performance - no additional buffering in the kernel, no dirty throttling,
etc. They only need their buffer & device offsets sector aligned - they
seem to be even page aligned in suspend-utils so they should be fine. And
if the performance still sucks (currently they appear to do mostly random
4k writes so it probably would for rotating disks), they could use AIO DIO
to get multiple pages in flight (as many as they dare to allocate buffers)
and then the IO scheduler will reorder things as good as it can and they
should get reasonable performance.

Is there someone who works on suspend-utils these days? Because the repo
I've found on kernel.org seems to be long dead (last commit in 2012).

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

