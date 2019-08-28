Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9BA81C3A5A4
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 01:08:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 412B32186A
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 01:08:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=arista.com header.i=@arista.com header.b="lyKxTBzD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 412B32186A
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=arista.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E47466B0008; Tue, 27 Aug 2019 21:08:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E1D7B6B000A; Tue, 27 Aug 2019 21:08:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D354B6B000C; Tue, 27 Aug 2019 21:08:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0058.hostedemail.com [216.40.44.58])
	by kanga.kvack.org (Postfix) with ESMTP id AB0666B0008
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 21:08:08 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 5B2AF824CA1C
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 01:08:08 +0000 (UTC)
X-FDA: 75870050256.24.song43_46f4b04dc2d02
X-HE-Tag: song43_46f4b04dc2d02
X-Filterd-Recvd-Size: 26160
Received: from mail-io1-f66.google.com (mail-io1-f66.google.com [209.85.166.66])
	by imf48.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 01:08:07 +0000 (UTC)
Received: by mail-io1-f66.google.com with SMTP id t6so2429248ios.7
        for <linux-mm@kvack.org>; Tue, 27 Aug 2019 18:08:07 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=arista.com; s=googlenew;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=HvUnsqZ8+NUrFDSGwnmhMji/RUmtizQRFFGLbVZdeyo=;
        b=lyKxTBzD8e4Y1CaE6URsE5xSsIa9P2TGmdJcTXYB4/t4QnC/F/sT9b3doFLQw9Ek6v
         jCbWCMd7wqDUXhdhCXtQKQHTs5SHmvFrmduE987GneMf4ILGttcwzm5x61fEOlqnnIOZ
         1typxyYkg4fJ+QIZ/SBYyiQST/xoe2yF2fXnSqqwtCrALxIIn0M8EsmyGqYd2+RvI5rG
         4rrnuzTZI09ifKelygFaE07jLnkG8AyjXjpUR6srJoahr+MZ/QhG1XxO7IPEbug9sWNJ
         7Wa3rvrsa3yOYwMILpOZdQ3U1Ek5Luw7vzc4c87bcWY8cHzbhEaljv6ntIYJp2W6kaf8
         v/9Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=HvUnsqZ8+NUrFDSGwnmhMji/RUmtizQRFFGLbVZdeyo=;
        b=A3DV19tlpecc4IrBpsDQbtOocKlb4Vc18LNzETBv/Ebp7gawtuXFPPHbBxMsCj2H9G
         2myrcHWnBJKWODovSKTy5/7b21BAP1VT0E4kjiqIZ3esWH+p4CqUiztJQcbECKUbO0jm
         I6lFVt2a4Hilx2Wls/xL5fDiO2HLVZL/bjCuMVBEP0KjQSrCvzcNM7B1GmIY/6g7RdTr
         5y5ZKQRYI3Droe5tGXi8x8w9/RFsA9ql5JmSeTzV3sfSKf1EnUZTpyCeAf/E7fC0yIFE
         Rp7fdiLWOPIaUXR6fFLhONhya5RfaQJ/Ra3tQSfFGh6hkTxCEqU/db9VyxW4BnSXe6qJ
         S8Ag==
X-Gm-Message-State: APjAAAUJsrE2Mnj6pcx7FS1PgWQb/pm5fjWguElX4nXyGTKJrq/AjYD9
	r5VYy62s+zRdf8W2LJUbKW0N8QzU/KQ6XLEtStiA7A==
X-Google-Smtp-Source: APXvYqxu5lrWuQDrjNvARmfaze1FLfOmu1xBTFFvY17yI0h12lPW+cDp9nzA5F092+S7MsKYoH4EIS3qQP6pPboKCIk=
X-Received: by 2002:a02:ba91:: with SMTP id g17mr1822823jao.11.1566954486373;
 Tue, 27 Aug 2019 18:08:06 -0700 (PDT)
MIME-Version: 1.0
References: <20190826193638.6638-1-echron@arista.com> <20190827071523.GR7538@dhcp22.suse.cz>
In-Reply-To: <20190827071523.GR7538@dhcp22.suse.cz>
From: Edward Chron <echron@arista.com>
Date: Tue, 27 Aug 2019 18:07:54 -0700
Message-ID: <CAM3twVRZfarAP6k=LLWH0jEJXu8C8WZKgMXCFKBZdRsTVVFrUQ@mail.gmail.com>
Subject: Re: [PATCH 00/10] OOM Debug print selection and additional information
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Shakeel Butt <shakeelb@google.com>, 
	linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Ivan Delalande <colona@arista.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 27, 2019 at 12:15 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Mon 26-08-19 12:36:28, Edward Chron wrote:
> [...]
> > Extensibility using OOM debug options
> > -------------------------------------
> > What is needed is an extensible system to optionally configure
> > debug options as needed and to then dynamically enable and disable
> > them. Also for options that produce multiple lines of entry based
> > output, to configure which entries to print based on how much
> > memory they use (or optionally all the entries).
>
> With a patch this large and adding a lot of new stuff we need a more
> detailed usecases described I believe.

I guess it would make sense to explain motivation for each OOM Debug
option I've sent separately.
I see there comments on the patches I will try and add more information there.

An overview would be that we've been collecting information on OOM's
over the last 12 years or so.
These are from switches, other embedded devices, servers both large and small.
We ask for feedback on what information was helpful or could be helpful.
We try and add it to make root causing issues easier.

These OOM debug options are some of the options we've created.
I didn't port all of them to 5.3 but these are representative.
Our latest is kernel is a bit behind 5.3.

>
>
> [...]
>
> > Use of debugfs to allow dynamic controls
> > ----------------------------------------
> > By providing a debugfs interface that allows options to be configured,
> > enabled and where appropriate to set a minimum size for selecting
> > entries to print, the output produced when an OOM event occurs can be
> > dynamically adjusted to produce as little or as much detail as needed
> > for a given system.
>
> Who is going to consume this information and why would that consumer be
> unreasonable to demand further maintenance of that information in future
> releases? In other words debugfs is not considered a stableAPI which is
> OK here but the side effect of any change to these files results in user
> visible behavior and we consider that more or less a stable as long as
> there are consumers.
>
> > OOM debug options can be added to the base code as needed.
> >
> > Currently we have the following OOM debug options defined:
> >
> > * System State Summary
> >   --------------------
> >   One line of output that includes:
> >   - Uptime (days, hour, minutes, seconds)
>
> We do have timestamps in the log so why is this needed?


Here is how an OOM report looks when we get it to look at:

Aug 26 09:06:34 coronado kernel: oomprocs invoked oom-killer:
gfp_mask=0x100dca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), order=0,
oom_score_adj=1000
Aug 26 09:06:34 coronado kernel: CPU: 1 PID: 2795 Comm: oomprocs Not
tainted 5.3.0-rc6+ #33
Aug 26 09:06:34 coronado kernel: Hardware name: Compulab Ltd.
IPC3/IPC3, BIOS 5.12_IPC3K.PRD.0.25.7 08/09/2018

This shows the date and time, not time of the last boot. The
/var/log/messages output is what we often have to look at not raw
dmesgs.

>
>
> >   - Number CPUs
> >   - Machine Type
> >   - Node name
> >   - Domain name
>
> why are these needed? That is a static information that doesn't really
> influence the OOM situation.


Sorry if a few of the items overlap what OOM prints.
We've been printing a lot of this information since 2.6.38 and OOM
reporting has been updated.

We're updating our 4.19 system to have the latest OOM Report format.
This was the 5.0 patch Reorg the OOM report in the dump header.
Also back porting Shakeel's 5.3 patch to refactor dump tasks for memcg OOMs.
We're testing those back ports right now in fact.

We can probably get rid of some of the information we have but I
haven't had a chance yet.
Hopefully can do it as part of sending some code upstream.

>
>
> >   - Kernel Release
> >   - Kernel Version
>
> part of the oom report
>
> >
> >   Example output when configured and enabled:
> >
> > Jul 27 10:56:46 yoursystem kernel: System Uptime:0 days 00:17:27 CPUs:4 Machine:x86_64 Node:yoursystem Domain:localdomain Kernel Release:5.3.0-rc2+ Version: #49 SMP Mon Jul 27 10:35:32 PDT 2019
> >
> > * Tasks Summary
> >   -------------
> >   One line of output that includes:
> >   - Number of Threads
> >   - Number of processes
> >   - Forks since boot
> >   - Processes that are runnable
> >   - Processes that are in iowait
>
> We do have sysrq+t for this kind of information. Why do we need to
> duplicate it?

Unfortunately, we can't login into every customer system or even
system of our own and do a sysrq+t after each OOM.
You could scan for OOMs and have a script do it, but doing a sysrq+t
after an OOM event, you'll get different results.
I'd rather have the runnable and iowait counts during the OOM event not after.
Computers are so darn fast, free up some memory and things can look a
lot different.

We've seen crond fork and hang and gradually create thousands of
processes and sorts of other unintended fork bombs.
On some systems we can't print all of the process information as we've
discussed.
So we print a summary of how many there are total and if you use the
select process print option you can print all the processes
that use more than 1% for example. That may be a dozen or two versus
hundreds or thousands. That may make printing some
user processes, the largest memory users feasible.

>
>
> >   Example output when configured and enabled:
> >
> > Jul 22 15:20:57 yoursystem kernel: Threads:530 Processes:279 forks_since_boot:2786 procs_runable:2 procs_iowait:0
> >
> > * ARP Table and/or Neighbour Discovery Table Summary
> >   --------------------------------------------------
> >   One line of output each for ARP and ND that includes:
> >   - Table name
> >   - Table size (max # entries)
> >   - Key Length
> >   - Entry Size
> >   - Number of Entries
> >   - Last Flush (in seconds)
> >   - hash grows
> >   - entry allocations
> >   - entry destroys
> >   - Number lookups
> >   - Number of lookup hits
> >   - Resolution failures
> >   - Garbage Collection Forced Runs
> >   - Table Full
> >   - Proxy Queue Length
> >
> >   Example output when configured and enabled (for both):
> >
> > ... kernel: neighbour: Table: arp_tbl size:   256 keyLen:  4 entrySize: 360 entries:     9 lastFlush:  1721s hGrows:     1 allocs:     9 destroys:     0 lookups:   204 hits:   199 resFailed:    38 gcRuns/Forced: 111 /  0 tblFull:  0 proxyQlen:  0
> >
> > ... kernel: neighbour: Table:  nd_tbl size:   128 keyLen: 16 entrySize: 368 entries:     6 lastFlush:  1720s hGrows:     0 allocs:     7 destroys:     1 lookups:     0 hits:     0 resFailed:     0 gcRuns/Forced: 110 /  0 tblFull:  0 proxyQlen:  0
>
> Again, why is this needed particularly for the OOM event? I do
> understand this might be useful system health diagnostic information but
> how does this contribute to the OOM?
>

It is example of some system table information we print.
Other adjustable table information may be useful as well.
These table sizes are often adjustable and collecting stats on usage
helps determine if settings are appropriate.
The value during OOM events is very useful as usage varies.
We also collect the same stats like this from user code periodically
and can compare these.

>
> > * Add Select Slabs Print
> >   ----------------------
> >   Allow select slab entries (based on a minimum size) to be printed.
> >   Minimum size is specified as a percentage of the total RAM memory
> >   in tenths of a percent, consistent with existing OOM process scoring.
> >   Valid values are specified from 0 to 1000 where 0 prints all slab
> >   entries (all slabs that have at least one slab object in use) up
> >   to 1000 which would require a slab to use 100% of memory which can't
> >   happen so in that case only summary information is printed.
> >
> >   The first line of output is the standard Linux output header for
> >   OOM printed Slab entries. This header looks like this:
> >
> > Aug  6 09:37:21 egc103 yourserver: Unreclaimable slab info:
> >
> >   The output is existing slab entry memory usage limited such that only
> >   entries equal to or larger than the minimum size are printed.
> >   Empty slabs (no slab entries in slabs in use) are never printed.
> >
> >   Additional output consists of summary information that is printed
> >   at the end of the output. This summary information includes:
> >   - # entries examined
> >   - # entries selected and printed
> >   - minimum entry size for selection
> >   - Slabs total size (kB)
> >   - Slabs reclaimable size (kB)
> >   - Slabs unreclaimable size (kB)
> >
> >   Example Summary output when configured and enabled:
> >
> > Jul 23 23:26:34 yoursystem kernel: Summary: Slab entries examined: 123 printed: 83 minsize: 0kB
> >
> > Jul 23 23:26:34 yoursystem kernel: Slabs Total: 151212kB Reclaim: 50632kB Unreclaim: 100580kB
>
> I am all for practical improvements for slab reporting. It is not really
> trivial to find a good balance though. Printing all the caches simply
> doesn't scale. So I would start by improving the current state rather
> than adding more configurability.


Yes, there is a challenge here and with the information you choose to
report when an OOM event occurs.
Paraphrasing, one size may not fit all.
To address this we tried to make it easy to add options and to allow
them to enabled / disabled.
We'd rather rate limit based on memory usage than have the kernel
print rate limit arbitrarily.
We had to make some choices on how to do this.

That said we view the OOM report as debugging information.
So if you change the format as long as we get the information we feel
is relevant, we're happy.
Since we print release and version information we can adjust our
scripts to handle format changes.
It's work but not really that big a deal.
If you remove information that was useful that is a bit more painful,
but not the end of the world.

>
>
> >
> > * Add Select Vmalloc allocations Print
> >   ------------------------------------
> >   Allow select vmalloc entries (based on a minimum size) to be printed.
> >   Minimum size is specified as a percentage of the total RAM memory
> >   in tenths of a percent, consistent with existing OOM process scoring.
> >   Valid values are specified from 0 to 1000 where 0 prints all vmalloc
> >   entries (all vmalloc allocations that have at least one page in use) up
> >   to 1000 which would require a vmalloc to use 100% of memory which can't
> >   happen so in that case only summary information is printed.
> >
> >   The first line of output is a new Vmalloc output header for
> >   OOM printed Vmalloc entries. This header looks like this:
> >
> > Aug 19 19:27:01 yourserver kernel: Vmalloc Info:
> >
> >   The output is vmalloc entry information output limited such that only
> >   entries equal to or larger than the minimum size are printed.
> >   Unused vmallocs (no pages assigned to the vmalloc) are never printed.
> >   The vmalloc entry information includes:
> >   - Size (in bytes)
> >   - pages (Number pages in use)
> >   - Caller Information to identify the request
> >
> >   A sample vmalloc entry output looks like this:
> >
> > Jul 22 20:16:09 yoursystem kernel: Vmalloc size=2625536 pages=640 caller=__do_sys_swapon+0x78e/0x113
> >
> >   Additional output consists of summary information that is printed
> >   at the end of the output. This summary information includes:
> >   - Number of Vmalloc entries examined
> >   - Number of Vmalloc entries printed
> >   - minimum entry size for selection
> >
> >   A sample Vmalloc Summary output looks like this:
> >
> > Aug 19 19:27:01 coronado kernel: Summary: Vmalloc entries examined: 1070 printed: 989 minsize: 0kB
>
> This is a lot of information. I wouldn't be surprised if this alone
> could easily overflow the ringbuffer. Besides that, it is rarely useful
> for the OOM situation debugging. The overall size of the vmalloc area
> is certainly interesting but I am not sure we have a handy counter to
> cope with constrained OOM contexts.
>

We've had cases where just displaying very large allocations explained
why an OOM event occurred.
We size this so we rarely get much output here, an entry or two at most.
Again it is optional so if you don't care don't enable it.

>
> > * Add Select Process Entries Print
> >   --------------------------------
> >   Allow select process entries (based on a minimum size) to be printed.
> >   Minimum size is specified as a percentage totalpages (RAM + swap)
> >   in tenths of a percent, consistent with existing OOM process scoring.
> >   Note: user process memory can be swapped out when swap space present
> >   so that is why swap space and ram memory comprise the totalpages
> >   used to calculate the percentage of memory a process is using.
> >   Valid values are specified from 0 to 1000 where 0 prints all user
> >   processes (that have valid mm sections and aren't exiting) up to
> >   1000 which would require a user process to use 100% of memory which
> >   can't happen so in that case only summary information is printed.
> >
> >   The first line of output is the standard Linux output headers for
> >   OOM printed User Processes. This header looks like this:
> >
> > Aug 19 19:27:01 yourserver kernel: Tasks state (memory values in pages):
> > Aug 19 19:27:01 yourserver kernel: [  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name
> >
> >   The output is existing per user process data limited such that only
> >   entries equal to or larger than the minimum size are printed.
> >
> > Jul 21 20:07:48 yourserver kernel: [    579]     0   579     7942     1010          90112        0         -1000 systemd-udevd
> >
> >   Additional output consists of summary information that is printed
> >   at the end of the output. This summary information includes:
> >
> > Aug 19 19:27:01 yourserver kernel: Summary: OOM Tasks considered:277 printed:143 minimum size:0kB totalpages:32791608kB
>
> This sounds like a good idea to limit the eligible process list size but
> I am concerned that it might get misleading easily when there are many
> small processes contributing to the OOM in the end.
>
> > * Add Enhanced Process Print Information
> >   --------------------------------------
> >   Add OOM Debug code that prints additional detailed information about
> >   users processes that were considered for OOM killing for any print
> >   selected processes. The information is displayed for each user process
> >   that OOM prints in the output.
> >
> >   This supplemental per user process information is very helpful for
> >   determing how process memory is used to allow OOM event root cause
> >   identifcation that might not otherwise be possible.
> >
> >   Output information for enhanced user process entrys printed includes:
> >   - pid
> >   - parent pid
> >   - ruid
> >   - euid
> >   - tgid
> >   - Process State (S)
> >   - utime in seconds
> >   - stime in seconds
> >   - oom_score_adjust
> >   - task comm value (name of process)
> >   - Vmem KiB
> >   - MaxRss KiB
> >   - CurRss KiB
> >   - Pte KiB
> >   - Swap KiB
> >   - Sock KiB
> >   - Lib KiB
> >   - Text KiB
> >   - Heap KiB
> >   - Stack KiB
> >   - File KiB
> >   - Shmem KiB
> >   - Read Pages
> >   - Fault Pages
> >   - Lock KiB
> >   - Pinned KiB
>
> I can see some of these being interesting but I would rather pick up
> those and add to the regular oom output rather than go over configuring
> them.
>

Would be glad to add these to standard OOM output.
One issue is there are extra bytes of output with more detail.
So when constrained, to justify this we said we'd rather have lots of
detail on the top 50 or so many consuming processes versus course
information on all user processes.
The task information will provide us counts of processes and measures
of process creation that are very useful.

>
> > Configuring Patches:
> > -------------------
> > OOM Debug and any options you want to use must first be configured so
> > the code is included in your kernel. This requires selecting kernel
> > config file options. You will find config options to select under:
> >
> > Kernel hacking ---> Memory Debugging --->
> >
> > [*] Debug OOM
> >     [*] Debug OOM System State
> >     [*] Debug OOM System Tasks Summary
> >     [*] Debug OOM ARP Table
> >     [*] Debug OOM ND Table
> >     [*] Debug OOM Select Slabs Print
> >        [*] Debug OOM Slabs Select Always Print Enable
> >        [*] Debug OOM Enhanced Slab Print
> >     [*] Debug OOM Select Vmallocs Print
> >     [*] Debug OOM Select Process Print
> >        [*] Debug OOM Enhanced Process Print
>
> I really dislike these though. We already have zillions of debugging
> options and the config space is enormous. Different combinations of them
> make any compile testing a challenge and a lot of cpu cycles eaten.
> Besides that, who is going to configure those in without using them
> directly? Distributions are not going to enable without having all
> options being disabled by default for example.
>

Oh I agree, I dislike configuration options, there are so many and
when you upgrade you're like what now.
That said, I understand their value when range from small embedded
devices up to super computers and
zillions of devices.

I would be pleased to just have one configuration option or better yet
just have the code be part of
the standard system. So getting rid of any or all of that would be a pleasure.
Quite honestly, we may argue for certain items but in general we're
quite flexible.

> >  12 files changed, 1339 insertions(+), 11 deletions(-)
>
> This must have a been a lot of work and I really appreciate that.
>
> On the other hand it is a lot of code to maintain (note that you are
> usually introspecting deep internals of subsystems so changes would
> have to be carefully considered here as well) without a very strong
> demand.
>
> Sure it is a nice to have thing in some cases. I can imagine that some
> of that information would have helped me when debugging some weird OOM
> reports but I strongly suspect I would likely not have all necessary
> pieces enabled because those were not reproducible. Having everything
> on is just not usable due to amount of data. printk is not free and
> we have seen cases where a lot of output just turned the machine into
> unsuable state. If you have a reproducible OOMs then you can trigger
> a panic and have the full state of the system to examine. So I am not
> really convinced all this is going to be used to justify the maintenance
> overhead.


I can speak to many OOM events we have had to triage and root cause
over the past
7+ years that I've been involved with. It is quite true that there is
no single OOM report
format that will allow every problem to be completely root caused. The
OOM report
cannot provide all the information a full dump provides. That said,
the OOM report can give
you an excellent start on where to look when you otherwise aren't sure
where to look.
With luck everything you need is in the OOM report and you root cause
right there.

I can give you all sort of examples of this.
They're all anecdotal but I would expect that admin and support people
in data centers
see much of the same sorts of issues. Would welcome input from others too.
Different environments certainly can vary.

On the issue of reproducible OOMs verus non-reproducible, that is
important to consider:

First many OOMs we look at happen in the data center and they are not easily
reproducible. The analogy I use we spend a lot of time having to drive
with our tail lights.
That is we do a postmortem with limited information after the fact. Why?
We don't have the time or luxury to turn on panic on OOM and let the
system reboot.
In fact we very often have neither the time it takes to dump the
system or the storage space
to hold a full system dump, a shame as it is the best scenario for sure.
If a switch locks up for a few seconds the routing protocols can time
out and that can
start a reconfiguration chain reaction in your data center that will
not be well received.

If we could take a full system dump every time we need to capture the
state of the system
you wouldn't need an OOM report. In fact where else in the Kernel does
the Kernel produce
a report? OOM events are an odd beast that for some systems are just
an annoyance and
on other systems can be quite painful.

If you're lucky you can ignore the fact that OOM killed one of your
tabs in chrome browser.
Your not so lucky if a key process gets OOM killed causing a cascade
of issues. The more
pain you feel the more motivated you become to try and avoid future events.

We're not touching situations where OOM events occur in clusters or
periodically due to
a persisting issue or lots of other OOM dramas that occur from time to
time. For people who
are unlucky and have to care about OOM events, you often can't
reproduce these and you
want to capture as much information as is reasonable so you can work
what the cause was
with the hope that you can prevent future events.

How much information is reasonable and what information you want to
record may vary.

> All that being said, I do not think this is something we want to merge
> without a really _strong_ usecase to back it.
>

I will supply any information that I can. Let me know specifics on
what you need.
I guess I can try an explain a justification for each option I sent
and we can have a dialog as needed.
That is at least a starting point.

I was hoping that posting this code and starting a discussion might
draw in both experts and
others with an interest in the information that is produced for an OOM event.

Our experience is that some additional information and the ability to
adjust what is produced is valuable.
We don't add new options all the time but making it easy to do so is helpful.

It would be nice if everything was standard output but even optional
configurable information is better than none.
We can continue to mod our kernel but if others would benefit, we're
happy to contribute to the best
of our abilities. We're flexible enough to make any recommended
improvements as well.

Also, our implementation though we've been using it for some years,
and it continues to evolve, is a
reference implementation. Since the output is debugging information
and we identify what system
release and version produces the output with each event, we can adjust
our scripts to deal without
output changes as the system evolves. This is expected as systems and
Linux continue to evolve
and improve.

We'd be happy to work with you and your colleagues to contribute any
improvements that you can accept
 to help to improve the OOM Report output.

Thank-you again for your time and consideration!

Edward Chron
Arista Networks

>
> Thanks!
> --
> Michal Hocko
> SUSE Labs

