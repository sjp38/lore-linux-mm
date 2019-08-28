Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17F25C3A5A1
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 19:46:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9FB5622DA7
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 19:46:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=arista.com header.i=@arista.com header.b="Eb03A5DW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9FB5622DA7
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=arista.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3FCC76B0008; Wed, 28 Aug 2019 15:46:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3AAF76B000C; Wed, 28 Aug 2019 15:46:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 29AEA6B000D; Wed, 28 Aug 2019 15:46:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0039.hostedemail.com [216.40.44.39])
	by kanga.kvack.org (Postfix) with ESMTP id 025416B0008
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 15:46:34 -0400 (EDT)
Received: from smtpin27.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id A14E4482D
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 19:46:34 +0000 (UTC)
X-FDA: 75872868708.27.shame52_566903e8a1e14
X-HE-Tag: shame52_566903e8a1e14
X-Filterd-Recvd-Size: 30172
Received: from mail-io1-f68.google.com (mail-io1-f68.google.com [209.85.166.68])
	by imf08.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 19:46:33 +0000 (UTC)
Received: by mail-io1-f68.google.com with SMTP id z3so2076116iog.0
        for <linux-mm@kvack.org>; Wed, 28 Aug 2019 12:46:33 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=arista.com; s=googlenew;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=/rzlim4K8e+fQijOB2ey2JI2DtYFHwuJtpI5ucVWWG0=;
        b=Eb03A5DWjzAlCzmgyrV8S3YYaCHcmJV4vFxufI40vGHNvPRIzOcK7NuiANN5K4gAYc
         SeaL2xhVM3r+1ngszgqGoBDTBnrMPYIC7gQBKE8ZnhFwE6v8f9qnsngN3h6J0RnFKcX3
         uUoTwUrf+KYvqoeHP4gYR04Akm1AYwwKN9j+hVzO8FKIUisy+G5YozI5sGtDdoubQyA7
         +mapPjJuIR7RLnqbDkPfB+GljLR6GWt89oqWT20pRoAxWFNJAOrcqZ6ZjwIR9os7NujG
         VjA0ITCcc/JMSQALfkbItuQKgQI1F+4PkWGVxuLYrM+hVcYpa/p4Z96tYsoNqZQ/Qnuc
         cVIg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=/rzlim4K8e+fQijOB2ey2JI2DtYFHwuJtpI5ucVWWG0=;
        b=V7xrwJREr+6U7cU8Sryw3Bn5hQkfW5o6GOBHzNLI/0+ozps0GSPLgFxANL9Tc+7KEV
         PPuHVAFh6JeXihSt6x2VbNuLBjyDeVIT0d54fVWRAO9Mplpkzbt0UMyGIKqX/+qdXK9R
         519J3Fb0UCFXVHyrFiLLxrccqcfWFwk7Fd1z5cc/VlqGGBlv2Qg3Asrtmh97KKlAjgV6
         3GD8Oof5Nyr5vTcXeyAjY6XuITCUEmGXR8WJ4DwW/wCLbpgqCk9eB0sP6Eq+h6SdXJo8
         WMpudyeijjIAl1L/o2ptQV4V2Wt+Ql39UPKj+/xw4dBLTGIwb64UZKzxTx1qA9ChhzeG
         JjXg==
X-Gm-Message-State: APjAAAVmUtJ7xfcQLJMFpIpGkt+N5m0FmbeJSrep24rAcFs3TmfRlRSP
	Y1ZF12MP6/HhilKBWmrk1vDmGV/C3yJojlnC42bq+Q==
X-Google-Smtp-Source: APXvYqw0O7Wo7jlX15bmAvMRbAH08LQw0CFUxYO1fxxA1D+NiTZUuJlJ8m8DBn3bKdx8Wi0tLFKRyADUxBfo8AwcGwQ=
X-Received: by 2002:a6b:fc02:: with SMTP id r2mr6163184ioh.15.1567021592797;
 Wed, 28 Aug 2019 12:46:32 -0700 (PDT)
MIME-Version: 1.0
References: <20190826193638.6638-1-echron@arista.com> <20190827071523.GR7538@dhcp22.suse.cz>
 <CAM3twVRZfarAP6k=LLWH0jEJXu8C8WZKgMXCFKBZdRsTVVFrUQ@mail.gmail.com> <20190828065955.GB7386@dhcp22.suse.cz>
In-Reply-To: <20190828065955.GB7386@dhcp22.suse.cz>
From: Edward Chron <echron@arista.com>
Date: Wed, 28 Aug 2019 12:46:20 -0700
Message-ID: <CAM3twVR_OLffQ1U-SgQOdHxuByLNL5sicfnObimpGpPQ1tJ0FQ@mail.gmail.com>
Subject: Re: [PATCH 00/10] OOM Debug print selection and additional information
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, 
	Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Shakeel Butt <shakeelb@google.com>, 
	linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Ivan Delalande <colona@arista.com>
Content-Type: multipart/alternative; boundary="000000000000650e78059132a5a6"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--000000000000650e78059132a5a6
Content-Type: text/plain; charset="UTF-8"

On Tue, Aug 27, 2019 at 11:59 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Tue 27-08-19 18:07:54, Edward Chron wrote:
> > On Tue, Aug 27, 2019 at 12:15 AM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > On Mon 26-08-19 12:36:28, Edward Chron wrote:
> > > [...]
> > > > Extensibility using OOM debug options
> > > > -------------------------------------
> > > > What is needed is an extensible system to optionally configure
> > > > debug options as needed and to then dynamically enable and disable
> > > > them. Also for options that produce multiple lines of entry based
> > > > output, to configure which entries to print based on how much
> > > > memory they use (or optionally all the entries).
> > >
> > > With a patch this large and adding a lot of new stuff we need a more
> > > detailed usecases described I believe.
> >
> > I guess it would make sense to explain motivation for each OOM Debug
> > option I've sent separately.
> > I see there comments on the patches I will try and add more information
there.
> >
> > An overview would be that we've been collecting information on OOM's
> > over the last 12 years or so.
> > These are from switches, other embedded devices, servers both large and
small.
> > We ask for feedback on what information was helpful or could be helpful.
> > We try and add it to make root causing issues easier.
> >
> > These OOM debug options are some of the options we've created.
> > I didn't port all of them to 5.3 but these are representative.
> > Our latest is kernel is a bit behind 5.3.
> >
> > >
> > >
> > > [...]
> > >
> > > > Use of debugfs to allow dynamic controls
> > > > ----------------------------------------
> > > > By providing a debugfs interface that allows options to be
configured,
> > > > enabled and where appropriate to set a minimum size for selecting
> > > > entries to print, the output produced when an OOM event occurs can
be
> > > > dynamically adjusted to produce as little or as much detail as
needed
> > > > for a given system.
> > >
> > > Who is going to consume this information and why would that consumer
be
> > > unreasonable to demand further maintenance of that information in
future
> > > releases? In other words debugfs is not considered a stableAPI which
is
> > > OK here but the side effect of any change to these files results in
user
> > > visible behavior and we consider that more or less a stable as long as
> > > there are consumers.
> > >
> > > > OOM debug options can be added to the base code as needed.
> > > >
> > > > Currently we have the following OOM debug options defined:
> > > >
> > > > * System State Summary
> > > >   --------------------
> > > >   One line of output that includes:
> > > >   - Uptime (days, hour, minutes, seconds)
> > >
> > > We do have timestamps in the log so why is this needed?
> >
> >
> > Here is how an OOM report looks when we get it to look at:
> >
> > Aug 26 09:06:34 coronado kernel: oomprocs invoked oom-killer:
> > gfp_mask=0x100dca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), order=0,
> > oom_score_adj=1000
> > Aug 26 09:06:34 coronado kernel: CPU: 1 PID: 2795 Comm: oomprocs Not
> > tainted 5.3.0-rc6+ #33
> > Aug 26 09:06:34 coronado kernel: Hardware name: Compulab Ltd.
> > IPC3/IPC3, BIOS 5.12_IPC3K.PRD.0.25.7 08/09/2018
> >
> > This shows the date and time, not time of the last boot. The
> > /var/log/messages output is what we often have to look at not raw
> > dmesgs.
>
> This looks more like a configuration of the logging than a kernel
> problem. Kernel does provide timestamps for logs. E.g.
> $ tail -n1 /var/log/kern.log
> Aug 28 08:27:46 tiehlicka kernel: <1054>[336340.954345]
systemd-udevd[7971]: link_config: autonegotiation is unset or enabled, the
speed and duplex are not writable.
>
> [...]
> > > >   Example output when configured and enabled:
> > > >
> > > > Jul 22 15:20:57 yoursystem kernel: Threads:530 Processes:279
forks_since_boot:2786 procs_runable:2 procs_iowait:0
> > > >
> > > > * ARP Table and/or Neighbour Discovery Table Summary
> > > >   --------------------------------------------------
> > > >   One line of output each for ARP and ND that includes:
> > > >   - Table name
> > > >   - Table size (max # entries)
> > > >   - Key Length
> > > >   - Entry Size
> > > >   - Number of Entries
> > > >   - Last Flush (in seconds)
> > > >   - hash grows
> > > >   - entry allocations
> > > >   - entry destroys
> > > >   - Number lookups
> > > >   - Number of lookup hits
> > > >   - Resolution failures
> > > >   - Garbage Collection Forced Runs
> > > >   - Table Full
> > > >   - Proxy Queue Length
> > > >
> > > >   Example output when configured and enabled (for both):
> > > >
> > > > ... kernel: neighbour: Table: arp_tbl size:   256 keyLen:  4
entrySize: 360 entries:     9 lastFlush:  1721s hGrows:     1 allocs:     9
destroys:     0 lookups:   204 hits:   199 resFailed:    38 gcRuns/Forced:
111 /  0 tblFull:  0 proxyQlen:  0
> > > >
> > > > ... kernel: neighbour: Table:  nd_tbl size:   128 keyLen: 16
entrySize: 368 entries:     6 lastFlush:  1720s hGrows:     0 allocs:     7
destroys:     1 lookups:     0 hits:     0 resFailed:     0 gcRuns/Forced:
110 /  0 tblFull:  0 proxyQlen:  0
> > >
> > > Again, why is this needed particularly for the OOM event? I do
> > > understand this might be useful system health diagnostic information
but
> > > how does this contribute to the OOM?
> > >
> >
> > It is example of some system table information we print.
> > Other adjustable table information may be useful as well.
> > These table sizes are often adjustable and collecting stats on usage
> > helps determine if settings are appropriate.
> > The value during OOM events is very useful as usage varies.
> > We also collect the same stats like this from user code periodically
> > and can compare these.
>
> I suspect that this is a very narrow usecase and there are more like
> that and I can imagine somebody with a different workload could come up
> with yet another set of useful information to print. The more I think of
these
> additional modules the more I am convinced that this "plugin" architecture
> is a wrong approach. Why? Mostly because all the code maintenance burden
> is likely to be not worth all the niche usecase. This all has to be more
> dynamic and ideally scriptable so that the code in the kernel just
> provides the basic information and everybody can just hook in there and
> dump whatever additional information is needed. Sounds like something
> that eBPF could fit in, no? Have you considered that?
>

Just a comment, I have no doubt that the people commenting here have felt
the pain of trying to root cause OOM issues and you know how difficult it
can
be. Having the information you need since you can't easily reproduce the
problem is really your best hope. As much I wish we could take a full dump
of the system when an OOM event occurs that just isn't practical on
production
systems (would make my job and other people's jobs easier).

What we coded was quite reasonable given when we started back with 2.6.38
and then 3.4. We've been tailoring OOM to give us the information we need
since then. It isn't perfect but it's a significant improvement. So again
we've
offered it up to start this discussion, with the goal of figuring out "how
to get there"
as Michal says.

Going forward we remain flexible as to implementation.
We "just want to get there" too.

Yes, we have thought about eBPF.
Mentioned this in the discussion with Qian Cai.
But with the caveat that running a eBPF script that it isn't standard Linux
operating procedure, at this point in time any way will not be well
received in the data center.

Our belief is if you really think eBPF is the preferred mechanism
then move OOM reporting to an eBPF.
I mentioned this before but I will reiterate this here.

So how do we get there? Let's look at the existing report which we know
has issues.

Other than a few essential OOM messages the OOM code should produce,
such as the Killed process message message sequence being included,
you could have the entire OOM report moved to an eBPF script and
therefore make it customizable, configurable or if you prefer programmable.

Why? Because as we all agree, you'll never have a perfect OOM Report.
So if you believe this, than if you will, put your money where your mouth
is (so to speak) and make the entire OOM Report and eBPF script.
We'd be willing to help with this.

I'll give specific reasons why you want to do this.

   - Don't want to maintain a lot of code in the kernel (eBPF code doesn't
   count).
   - Can't produce an ideal OOM report.
   - Don't like configuring things but favor programmatic solutions.
   - Agree the existing OOM report doesn't work for all environments.
   - Want to allow flexibility but can't support everything people might
   want.
   - Then installing an eBPF for OOM Reporting isn't an option, it's
   required.

The last reason is huge for people who live in a world with large data
centers. Data center managers are very conservative. They don't want to
deviate from standard operating procedure unless absolutely necessary.
If loading an OOM Report eBPF is standard to get OOM Reporting output,
then they'll accept that.

For anyone who argues that the existing report should remain as is
with no changes, well our experience tells us otherwise.

I can go on about this for more than you'll care to read but I'll
highlight a few issues that should be obvious.

Having a choice of all processes dumped as either all user processes or none
doesn't work in general. For some environments or situations it makes sense
to only dump the largest memory using tasks. As I've already mentioned you
can configure this choice or you could make a decision based on the number
of processes on the system or you can use some other arbitrary decision
process. This will can help to avoid kernel print rate limiting make print
decisions for you. Having an eBPF script lets you program what you want.

Printing slabs only when slabs use more memory than user processes isn't
sufficient. We've had a number of cases where slabs use 30% or 40% of
system memory and that is abnormal for that system and we want slab usage
at the time of OOM event. Putting that in eBPF script makes that adjustable.

We have found printing large Vmalloc allocations helpful and an eBPF script
would alow us to add that.

We'd like to dump the status of a few kernel tables and we should be able to
add that to eBPF OOM Reporting script.

Including information as we do about task status of the system is essential
for us. We've debugged so many issues because of this information.
We can add this to the OOM Reporting eBPF script.

So yeah, we agree with using eBPF if you agree to using it as well.

If you don't agree, then we want to configure or otherwise mod your
code because we know our environment way better than you do
and sadly this stuff matters or we wouldn't be having this discussion.

> [...]
>
> Skipping over many useful stuff. I can reassure you that my experience
> with OOM debugging has been a real pain at times (e.g. when there is
> simply no way to find out who has eaten all the memory because it is not
> accounted anywhere) as well and I completely understand where you are
> coming from. There is definitely a room for improvements we just have to
> find a way how to get there.
>
> Thanks!
> --
> Michal Hocko
> SUSE Labs

Agreed. What do you think?

Thank-you,

Edward Chron
Arista Networks

--000000000000650e78059132a5a6
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><br><br>On Tue, Aug 27, 2019 at 11:59 PM Michal Hocko &lt;=
<a href=3D"mailto:mhocko@kernel.org">mhocko@kernel.org</a>&gt; wrote:<br>&g=
t;<br>&gt; On Tue 27-08-19 18:07:54, Edward Chron wrote:<br>&gt; &gt; On Tu=
e, Aug 27, 2019 at 12:15 AM Michal Hocko &lt;<a href=3D"mailto:mhocko@kerne=
l.org">mhocko@kernel.org</a>&gt; wrote:<br>&gt; &gt; &gt;<br>&gt; &gt; &gt;=
 On Mon 26-08-19 12:36:28, Edward Chron wrote:<br>&gt; &gt; &gt; [...]<br>&=
gt; &gt; &gt; &gt; Extensibility using OOM debug options<br>&gt; &gt; &gt; =
&gt; -------------------------------------<br>&gt; &gt; &gt; &gt; What is n=
eeded is an extensible system to optionally configure<br>&gt; &gt; &gt; &gt=
; debug options as needed and to then dynamically enable and disable<br>&gt=
; &gt; &gt; &gt; them. Also for options that produce multiple lines of entr=
y based<br>&gt; &gt; &gt; &gt; output, to configure which entries to print =
based on how much<br>&gt; &gt; &gt; &gt; memory they use (or optionally all=
 the entries).<br>&gt; &gt; &gt;<br>&gt; &gt; &gt; With a patch this large =
and adding a lot of new stuff we need a more<br>&gt; &gt; &gt; detailed use=
cases described I believe.<br>&gt; &gt;<br>&gt; &gt; I guess it would make =
sense to explain motivation for each OOM Debug<br>&gt; &gt; option I&#39;ve=
 sent separately.<br>&gt; &gt; I see there comments on the patches I will t=
ry and add more information there.<br>&gt; &gt;<br>&gt; &gt; An overview wo=
uld be that we&#39;ve been collecting information on OOM&#39;s<br>&gt; &gt;=
 over the last 12 years or so.<br>&gt; &gt; These are from switches, other =
embedded devices, servers both large and small.<br>&gt; &gt; We ask for fee=
dback on what information was helpful or could be helpful.<br>&gt; &gt; We =
try and add it to make root causing issues easier.<br>&gt; &gt;<br>&gt; &gt=
; These OOM debug options are some of the options we&#39;ve created.<br>&gt=
; &gt; I didn&#39;t port all of them to 5.3 but these are representative.<b=
r>&gt; &gt; Our latest is kernel is a bit behind 5.3.<br>&gt; &gt;<br>&gt; =
&gt; &gt;<br>&gt; &gt; &gt;<br>&gt; &gt; &gt; [...]<br>&gt; &gt; &gt;<br>&g=
t; &gt; &gt; &gt; Use of debugfs to allow dynamic controls<br>&gt; &gt; &gt=
; &gt; ----------------------------------------<br>&gt; &gt; &gt; &gt; By p=
roviding a debugfs interface that allows options to be configured,<br>&gt; =
&gt; &gt; &gt; enabled and where appropriate to set a minimum size for sele=
cting<br>&gt; &gt; &gt; &gt; entries to print, the output produced when an =
OOM event occurs can be<br>&gt; &gt; &gt; &gt; dynamically adjusted to prod=
uce as little or as much detail as needed<br>&gt; &gt; &gt; &gt; for a give=
n system.<br>&gt; &gt; &gt;<br>&gt; &gt; &gt; Who is going to consume this =
information and why would that consumer be<br>&gt; &gt; &gt; unreasonable t=
o demand further maintenance of that information in future<br>&gt; &gt; &gt=
; releases? In other words debugfs is not considered a stableAPI which is<b=
r>&gt; &gt; &gt; OK here but the side effect of any change to these files r=
esults in user<br>&gt; &gt; &gt; visible behavior and we consider that more=
 or less a stable as long as<br>&gt; &gt; &gt; there are consumers.<br>&gt;=
 &gt; &gt;<br>&gt; &gt; &gt; &gt; OOM debug options can be added to the bas=
e code as needed.<br>&gt; &gt; &gt; &gt;<br>&gt; &gt; &gt; &gt; Currently w=
e have the following OOM debug options defined:<br>&gt; &gt; &gt; &gt;<br>&=
gt; &gt; &gt; &gt; * System State Summary<br>&gt; &gt; &gt; &gt; =C2=A0 ---=
-----------------<br>&gt; &gt; &gt; &gt; =C2=A0 One line of output that inc=
ludes:<br>&gt; &gt; &gt; &gt; =C2=A0 - Uptime (days, hour, minutes, seconds=
)<br>&gt; &gt; &gt;<br>&gt; &gt; &gt; We do have timestamps in the log so w=
hy is this needed?<br>&gt; &gt;<br>&gt; &gt;<br>&gt; &gt; Here is how an OO=
M report looks when we get it to look at:<br>&gt; &gt;<br>&gt; &gt; Aug 26 =
09:06:34 coronado kernel: oomprocs invoked oom-killer:<br>&gt; &gt; gfp_mas=
k=3D0x100dca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), order=3D0,<br>&gt; &gt; oom_=
score_adj=3D1000<br>&gt; &gt; Aug 26 09:06:34 coronado kernel: CPU: 1 PID: =
2795 Comm: oomprocs Not<br>&gt; &gt; tainted 5.3.0-rc6+ #33<br>&gt; &gt; Au=
g 26 09:06:34 coronado kernel: Hardware name: Compulab Ltd.<br>&gt; &gt; IP=
C3/IPC3, BIOS 5.12_IPC3K.PRD.0.25.7 08/09/2018<br>&gt; &gt;<br>&gt; &gt; Th=
is shows the date and time, not time of the last boot. The<br>&gt; &gt; /va=
r/log/messages output is what we often have to look at not raw<br>&gt; &gt;=
 dmesgs.<br>&gt;<br>&gt; This looks more like a configuration of the loggin=
g than a kernel<br>&gt; problem. Kernel does provide timestamps for logs. E=
.g.<br>&gt; $ tail -n1 /var/log/kern.log<br>&gt; Aug 28 08:27:46 tiehlicka =
kernel: &lt;1054&gt;[336340.954345] systemd-udevd[7971]: link_config: auton=
egotiation is unset or enabled, the speed and duplex are not writable.<br>&=
gt;<br>&gt; [...]<br>&gt; &gt; &gt; &gt; =C2=A0 Example output when configu=
red and enabled:<br>&gt; &gt; &gt; &gt;<br>&gt; &gt; &gt; &gt; Jul 22 15:20=
:57 yoursystem kernel: Threads:530 Processes:279 forks_since_boot:2786 proc=
s_runable:2 procs_iowait:0<br>&gt; &gt; &gt; &gt;<br>&gt; &gt; &gt; &gt; * =
ARP Table and/or Neighbour Discovery Table Summary<br>&gt; &gt; &gt; &gt; =
=C2=A0 --------------------------------------------------<br>&gt; &gt; &gt;=
 &gt; =C2=A0 One line of output each for ARP and ND that includes:<br>&gt; =
&gt; &gt; &gt; =C2=A0 - Table name<br>&gt; &gt; &gt; &gt; =C2=A0 - Table si=
ze (max # entries)<br>&gt; &gt; &gt; &gt; =C2=A0 - Key Length<br>&gt; &gt; =
&gt; &gt; =C2=A0 - Entry Size<br>&gt; &gt; &gt; &gt; =C2=A0 - Number of Ent=
ries<br>&gt; &gt; &gt; &gt; =C2=A0 - Last Flush (in seconds)<br>&gt; &gt; &=
gt; &gt; =C2=A0 - hash grows<br>&gt; &gt; &gt; &gt; =C2=A0 - entry allocati=
ons<br>&gt; &gt; &gt; &gt; =C2=A0 - entry destroys<br>&gt; &gt; &gt; &gt; =
=C2=A0 - Number lookups<br>&gt; &gt; &gt; &gt; =C2=A0 - Number of lookup hi=
ts<br>&gt; &gt; &gt; &gt; =C2=A0 - Resolution failures<br>&gt; &gt; &gt; &g=
t; =C2=A0 - Garbage Collection Forced Runs<br>&gt; &gt; &gt; &gt; =C2=A0 - =
Table Full<br>&gt; &gt; &gt; &gt; =C2=A0 - Proxy Queue Length<br>&gt; &gt; =
&gt; &gt;<br>&gt; &gt; &gt; &gt; =C2=A0 Example output when configured and =
enabled (for both):<br>&gt; &gt; &gt; &gt;<br>&gt; &gt; &gt; &gt; ... kerne=
l: neighbour: Table: arp_tbl size: =C2=A0 256 keyLen: =C2=A04 entrySize: 36=
0 entries: =C2=A0 =C2=A0 9 lastFlush: =C2=A01721s hGrows: =C2=A0 =C2=A0 1 a=
llocs: =C2=A0 =C2=A0 9 destroys: =C2=A0 =C2=A0 0 lookups: =C2=A0 204 hits: =
=C2=A0 199 resFailed: =C2=A0 =C2=A038 gcRuns/Forced: 111 / =C2=A00 tblFull:=
 =C2=A00 proxyQlen: =C2=A00<br>&gt; &gt; &gt; &gt;<br>&gt; &gt; &gt; &gt; .=
.. kernel: neighbour: Table: =C2=A0nd_tbl size: =C2=A0 128 keyLen: 16 entry=
Size: 368 entries: =C2=A0 =C2=A0 6 lastFlush: =C2=A01720s hGrows: =C2=A0 =
=C2=A0 0 allocs: =C2=A0 =C2=A0 7 destroys: =C2=A0 =C2=A0 1 lookups: =C2=A0 =
=C2=A0 0 hits: =C2=A0 =C2=A0 0 resFailed: =C2=A0 =C2=A0 0 gcRuns/Forced: 11=
0 / =C2=A00 tblFull: =C2=A00 proxyQlen: =C2=A00<br>&gt; &gt; &gt;<br>&gt; &=
gt; &gt; Again, why is this needed particularly for the OOM event? I do<br>=
&gt; &gt; &gt; understand this might be useful system health diagnostic inf=
ormation but<br>&gt; &gt; &gt; how does this contribute to the OOM?<br>&gt;=
 &gt; &gt;<br>&gt; &gt;<br>&gt; &gt; It is example of some system table inf=
ormation we print.<br>&gt; &gt; Other adjustable table information may be u=
seful as well.<br>&gt; &gt; These table sizes are often adjustable and coll=
ecting stats on usage<br>&gt; &gt; helps determine if settings are appropri=
ate.<br>&gt; &gt; The value during OOM events is very useful as usage varie=
s.<br>&gt; &gt; We also collect the same stats like this from user code per=
iodically<br>&gt; &gt; and can compare these.<br>&gt;<br>&gt; I suspect tha=
t this is a very narrow usecase and there are more like<br>&gt; that and I =
can imagine somebody with a different workload could come up<br>&gt; with y=
et another set of useful information to print. The more I think of these<br=
>&gt; additional modules the more I am convinced that this &quot;plugin&quo=
t; architecture<br>&gt; is a wrong approach. Why? Mostly because all the co=
de maintenance burden<br>&gt; is likely to be not worth all the niche useca=
se. This all has to be more<br>&gt; dynamic and ideally scriptable so that =
the code in the kernel just<br>&gt; provides the basic information and ever=
ybody can just hook in there and<br>&gt; dump whatever additional informati=
on is needed. Sounds like something<br>&gt; that eBPF could fit in, no? Hav=
e you considered that?<br>&gt;<br><br>Just a comment, I have no doubt that =
the people commenting here have felt<br>the pain of trying to root cause OO=
M issues and you know how difficult it can<br>be. Having the information yo=
u need since you can&#39;t easily reproduce the <br>problem is really your =
best hope. As much I wish we could take a full dump<br>of the system when a=
n OOM event occurs that just isn&#39;t practical on production<div>systems =
(would make my job and other people&#39;s jobs easier).<br><br>What we code=
d was quite reasonable given when we started back with 2.6.38<br>and then 3=
.4. We&#39;ve been tailoring OOM to give us the information we need<div>sin=
ce then. It isn&#39;t perfect but it&#39;s a significant improvement. So ag=
ain we&#39;ve=C2=A0</div><div>offered it up to start this discussion, with =
the goal of figuring out &quot;how to get there&quot;</div><div>as Michal s=
ays.=C2=A0</div><div><br></div><div>Going forward we remain flexible as to =
implementation.=C2=A0</div><div>We &quot;just want to get there&quot; too.=
=C2=A0</div><div><br>Yes, we have thought about eBPF.=C2=A0</div><div>Menti=
oned this in the discussion with Qian Cai.</div><div>But with the caveat th=
at running a eBPF script that it isn&#39;t standard Linux</div><div>operati=
ng procedure, at this point in time any way will not be well</div><div>rece=
ived in the data center.</div><div><br>Our belief is if you really think eB=
PF is the preferred mechanism</div><div>then move OOM reporting to an eBPF.=
=C2=A0</div><div>I mentioned this before but I will reiterate this here.<br=
><br>So how do we get there? Let&#39;s look at the existing report which we=
 know</div><div>has issues.</div><div><br>Other than a few essential OOM me=
ssages the OOM code should produce,</div><div>such as the Killed process me=
ssage message sequence being included,</div><div>you could have the=C2=A0en=
tire OOM report moved to an eBPF script and=C2=A0</div><div>therefore make =
it customizable, configurable or if you prefer programmable.</div><div><br>=
Why? Because as we all agree, you&#39;ll never have a perfect OOM Report.</=
div><div>So if you believe this, than if you will, put your money where you=
r mouth</div><div>is (so to speak) and make the entire OOM Report and eBPF =
script.</div><div>We&#39;d be willing to help with this.</div><div><br></di=
v><div>I&#39;ll give specific reasons why you want to do this.</div><div><u=
l><li>Don&#39;t want to maintain a lot of code in the kernel (eBPF code doe=
sn&#39;t count).</li><li>Can&#39;t produce an ideal OOM report.</li><li>Don=
&#39;t like configuring things but favor programmatic solutions.</li><li>Ag=
ree the existing OOM report doesn&#39;t work for all environments.</li><li>=
Want to allow flexibility but can&#39;t support everything people might wan=
t.</li><li>Then installing an eBPF for OOM Reporting isn&#39;t an option, i=
t&#39;s required.</li></ul></div><div>The last reason is huge for people wh=
o live in a world with large data</div><div>centers. Data center managers a=
re very conservative. They don&#39;t want to</div><div>deviate from standar=
d operating procedure unless absolutely necessary.</div><div>If loading an =
OOM Report eBPF is standard to get OOM Reporting output,</div><div>then the=
y&#39;ll accept that.=C2=A0</div><div><br></div><div>For anyone who argues =
that the existing report should remain as is</div><div>with no changes, wel=
l our experience tells us otherwise.</div><div><br></div><div>I can go on a=
bout this for more than you&#39;ll care to read but I&#39;ll</div><div>high=
light a few issues that should be obvious.</div><div><br></div><div>Having =
a choice of all processes dumped as either all user processes or none</div>=
<div>doesn&#39;t work in general. For some environments or situations it ma=
kes sense</div><div>to only dump the largest memory using tasks. As I&#39;v=
e already mentioned you</div><div>can configure this choice or you could ma=
ke a decision based on the number</div><div>of processes on the system or y=
ou can use some other arbitrary decision=C2=A0</div><div>process. This will=
 can help to avoid kernel print rate limiting make print</div><div>decision=
s for you. Having an eBPF script lets you program what you want.</div><div>=
<br></div><div>Printing slabs only when slabs use more memory than user pro=
cesses isn&#39;t</div><div>sufficient. We&#39;ve had a number of cases wher=
e slabs use 30% or 40% of=C2=A0</div><div>system memory and that is abnorma=
l for that system and we want slab usage</div><div>at the time of OOM event=
. Putting that in eBPF script makes that adjustable.</div><div><br></div><d=
iv>We have found printing large Vmalloc allocations helpful and an eBPF scr=
ipt</div><div>would alow us to add that.</div><div><br></div><div>We&#39;d =
like to dump the status of a few kernel tables and we should be able to</di=
v><div>add that to eBPF OOM Reporting script.</div><div><br></div><div>Incl=
uding information as we do about task status of the system is essential</di=
v><div>for us. We&#39;ve debugged so many issues because of this informatio=
n.</div><div>We can add this to the OOM Reporting eBPF script.</div><div><b=
r></div><div>So yeah, we agree with using eBPF if you agree to using it as =
well.</div><div><br></div><div>If you don&#39;t agree, then we want to conf=
igure or otherwise mod your</div><div>code because we know our environment =
way better than you do</div><div>and sadly this stuff matters or we wouldn&=
#39;t be having this discussion.</div><div><br>&gt; [...]<br>&gt;<br>&gt; S=
kipping over many useful stuff. I can reassure you that my experience<br>&g=
t; with OOM debugging has been a real pain at times (e.g. when there is<br>=
&gt; simply no way to find out who has eaten all the memory because it is n=
ot<br>&gt; accounted anywhere) as well and I completely understand where yo=
u are<br>&gt; coming from. There is definitely a room for improvements we j=
ust have to<br>&gt; find a way how to get there.<br>&gt;<br>&gt; Thanks!<br=
>&gt; --<br>&gt; Michal Hocko<br>&gt; SUSE Labs</div></div><div><br></div><=
div>Agreed. What do you think?</div><div><br></div><div>Thank-you,</div><di=
v><br></div><div>Edward Chron</div><div>Arista Networks</div></div>

--000000000000650e78059132a5a6--

