Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EDBF9C3A5A1
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 07:08:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8E7CF20828
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 07:08:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8E7CF20828
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 23B166B0008; Wed, 28 Aug 2019 03:08:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1EB506B000C; Wed, 28 Aug 2019 03:08:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 101FE6B000D; Wed, 28 Aug 2019 03:08:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0059.hostedemail.com [216.40.44.59])
	by kanga.kvack.org (Postfix) with ESMTP id E4B2C6B0008
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 03:08:49 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 7A373181AC9AE
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 07:08:49 +0000 (UTC)
X-FDA: 75870959178.03.day23_12c5774c41c18
X-HE-Tag: day23_12c5774c41c18
X-Filterd-Recvd-Size: 7266
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf22.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 07:08:48 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 5A944B06B;
	Wed, 28 Aug 2019 07:08:47 +0000 (UTC)
Date: Wed, 28 Aug 2019 09:08:45 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Edward Chron <echron@arista.com>
Cc: Qian Cai <cai@lca.pw>, Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>,
	David Rientjes <rientjes@google.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Ivan Delalande <colona@arista.com>
Subject: Re: [PATCH 00/10] OOM Debug print selection and additional
 information
Message-ID: <20190828070845.GC7386@dhcp22.suse.cz>
References: <20190826193638.6638-1-echron@arista.com>
 <1566909632.5576.14.camel@lca.pw>
 <CAM3twVQEMGWMQEC0dduri0JWt3gH6F2YsSqOmk55VQz+CZDVKg@mail.gmail.com>
 <79FC3DA1-47F0-4FFC-A92B-9A7EBCE3F15F@lca.pw>
 <CAM3twVSdxJaEpmWXu2m_F1MxFMB58C6=LWWCDYNn5yT3Ns+0sQ@mail.gmail.com>
 <2A1D8FFC-9E9E-4D86-9A0E-28F8263CC508@lca.pw>
 <CAM3twVR5TVuuZSLM2qRJYnkCEKVZmA3XDNREaB+wdKH2Ne9vVA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAM3twVR5TVuuZSLM2qRJYnkCEKVZmA3XDNREaB+wdKH2Ne9vVA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 27-08-19 19:47:22, Edward Chron wrote:
> On Tue, Aug 27, 2019 at 6:32 PM Qian Cai <cai@lca.pw> wrote:
> >
> >
> >
> > > On Aug 27, 2019, at 9:13 PM, Edward Chron <echron@arista.com> wrote=
:
> > >
> > > On Tue, Aug 27, 2019 at 5:50 PM Qian Cai <cai@lca.pw> wrote:
> > >>
> > >>
> > >>
> > >>> On Aug 27, 2019, at 8:23 PM, Edward Chron <echron@arista.com> wro=
te:
> > >>>
> > >>>
> > >>>
> > >>> On Tue, Aug 27, 2019 at 5:40 AM Qian Cai <cai@lca.pw> wrote:
> > >>> On Mon, 2019-08-26 at 12:36 -0700, Edward Chron wrote:
> > >>>> This patch series provides code that works as a debug option thr=
ough
> > >>>> debugfs to provide additional controls to limit how much informa=
tion
> > >>>> gets printed when an OOM event occurs and or optionally print ad=
ditional
> > >>>> information about slab usage, vmalloc allocations, user process =
memory
> > >>>> usage, the number of processes / tasks and some summary informat=
ion
> > >>>> about these tasks (number runable, i/o wait), system information
> > >>>> (#CPUs, Kernel Version and other useful state of the system),
> > >>>> ARP and ND Cache entry information.
> > >>>>
> > >>>> Linux OOM can optionally provide a lot of information, what's mi=
ssing?
> > >>>> ----------------------------------------------------------------=
------
> > >>>> Linux provides a variety of detailed information when an OOM eve=
nt occurs
> > >>>> but has limited options to control how much output is produced. =
The
> > >>>> system related information is produced unconditionally and limit=
ed per
> > >>>> user process information is produced as a default enabled option=
. The
> > >>>> per user process information may be disabled.
> > >>>>
> > >>>> Slab usage information was recently added and is output only if =
slab
> > >>>> usage exceeds user memory usage.
> > >>>>
> > >>>> Many OOM events are due to user application memory usage sometim=
es in
> > >>>> combination with the use of kernel resource usage that exceeds w=
hat is
> > >>>> expected memory usage. Detailed information about how memory was=
 being
> > >>>> used when the event occurred may be required to identify the roo=
t cause
> > >>>> of the OOM event.
> > >>>>
> > >>>> However, some environments are very large and printing all of th=
e
> > >>>> information about processes, slabs and or vmalloc allocations ma=
y
> > >>>> not be feasible. For other environments printing as much informa=
tion
> > >>>> about these as possible may be needed to root cause OOM events.
> > >>>>
> > >>>
> > >>> For more in-depth analysis of OOM events, people could use kdump =
to save a
> > >>> vmcore by setting "panic_on_oom", and then use the crash utility =
to analysis the
> > >>> vmcore which contains pretty much all the information you need.
> > >>>
> > >>> Certainly, this is the ideal. A full system dump would give you t=
he maximum amount of
> > >>> information.
> > >>>
> > >>> Unfortunately some environments may lack space to store the dump,
> > >>
> > >> Kdump usually also support dumping to a remote target via NFS, SSH=
 etc
> > >>
> > >>> let alone the time to dump the storage contents and restart the s=
ystem. Some
> > >>
> > >> There is also =E2=80=9Cmakedumpfile=E2=80=9D that could compress a=
nd filter unwanted memory to reduce
> > >> the vmcore size and speed up the dumping process by utilizing mult=
i-threads.
> > >>
> > >>> systems can take many minutes to fully boot up, to reset and rein=
itialize all the
> > >>> devices. So unfortunately this is not always an option, and we ne=
ed an OOM Report.
> > >>
> > >> I am not sure how the system needs some minutes to reboot would be=
 relevant  for the
> > >> discussion here. The idea is to save a vmcore and it can be analyz=
ed offline even on
> > >> another system as long as it having a matching =E2=80=9Cvmlinux.".
> > >>
> > >>
> > >
> > > If selecting a dump on an OOM event doesn't reboot the system and i=
f
> > > it runs fast enough such
> > > that it doesn't slow processing enough to appreciably effect the
> > > system's responsiveness then
> > > then it would be ideal solution. For some it would be over kill but
> > > since it is an option it is a
> > > choice to consider or not.
> >
> > It sounds like you are looking for more of this,
>=20
> If you want to supplement the OOM Report and keep the information
> together than you could use EBPF to do that. If that really is the
> preference it might make sense to put the entire report as an EBPF
> script than you can modify the script however you choose. That would
> be very flexible. You can change your configuration on the fly. As
> long as it has access to everything you need it should work.
>=20
> Michal would know what direction OOM is headed and if he thinks that fi=
ts with
> where things are headed.

It seems we have landed in the similar thinking here. As mentioned in my
earlier email in this thread I can see the extensibility to be achieved
by eBPF. Essentially we would have a base form of the oom report like
now and scripts would then hook in there to provide whatever a specific
usecase needs. My practical experience with eBPF is close to zero so I
have no idea how that would actually work out though.

[...]
> For production systems installing and updating EBPF scripts may someday
> be very common, but I wonder how data center managers feel about it now=
?
> Developers are very excited about it and it is a very powerful tool but=
 can I
> get permission to add or replace an existing EBPF on production systems=
?

I am not sure I understand. There must be somebody trusted to take care
of systems, right?
--=20
Michal Hocko
SUSE Labs

