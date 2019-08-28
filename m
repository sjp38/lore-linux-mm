Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67DE5C3A5A3
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 00:24:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 12A2F20856
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 00:24:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=arista.com header.i=@arista.com header.b="Fe5fewdN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 12A2F20856
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=arista.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9ACC96B0005; Tue, 27 Aug 2019 20:24:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 95DC66B0008; Tue, 27 Aug 2019 20:24:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 84C2F6B000A; Tue, 27 Aug 2019 20:24:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0124.hostedemail.com [216.40.44.124])
	by kanga.kvack.org (Postfix) with ESMTP id 6345C6B0005
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 20:24:08 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 02F0487F2
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 00:24:08 +0000 (UTC)
X-FDA: 75869939376.30.goat45_7b4084fe33c40
X-HE-Tag: goat45_7b4084fe33c40
X-Filterd-Recvd-Size: 9995
Received: from mail-io1-f66.google.com (mail-io1-f66.google.com [209.85.166.66])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 00:24:06 +0000 (UTC)
Received: by mail-io1-f66.google.com with SMTP id 18so2213597ioe.10
        for <linux-mm@kvack.org>; Tue, 27 Aug 2019 17:24:06 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=arista.com; s=googlenew;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=A1X5SlBD1Y17kmFq56o6Inawb1hSfIhR9H9+nbDYmAU=;
        b=Fe5fewdNjKuRwiHP2bO4WKolsahBkD7cBVl1s0fNv28O40Yj70mppFFB1JD9W9RHvt
         esawA7eM7Cq4lQPNuSfWMjqhb+7MYBxujpyxK0jFGTTZd2iNUSPu87EuqOVsRfx0MxDJ
         jv6zis20Xq+gvAsZz5VKi9VQAIjUDY4BqwMtIBr9h5dsVj+iotqkqpovxhG+tAWByiTN
         6jToTvOctK+37rHt25RyqwEFusi7cZC6yHFnd1LkhdhScEqYxIojpZWBBeycVFlW8Gvy
         f9UGZyOkegazemQfvRM0OaI7tGsS++NLsTTA9bSz1+b/cnxAZRRKffC8CXc4cHCQ4mQ5
         3Smg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=A1X5SlBD1Y17kmFq56o6Inawb1hSfIhR9H9+nbDYmAU=;
        b=i4sJOELx1esdtXFKFAZC23aR443gvRwaw2/t/8+wTCEdf0+/gutWYR99i6bnxGvANj
         qNovrtY51kAfUeAH0ey/YW3YMv+dEgSsbZMuI9pIPQqPWaJE/FZNcjFE2ddW/Gp5iMq5
         UTDnjlAIKTiRu6nhCxsIuCzOl8XVYcoAa8jrdMy1uf104X4HSIc6AQkggfbBio8nQP5h
         FIPt3Epc5z3lg60wu5/H+Xa07OW1Z+SlziDnlx6pKyMHPFTJQnoB4ybJk5gJCQEHfdKD
         2qJIhDjZgr8X8waWxFu5fg13qztZheYhxzzgs/4teNsSfDXP0WfgO0Ql7pwvP5V87oiK
         e8fQ==
X-Gm-Message-State: APjAAAWgUM//1id68mRFPvFH0nMyiKDhiMz2ODmMqCbrGho2LIJhv6t7
	16etZWfR/CSX7CqMjMUlcVqbC6D1p2Q7MmwLSsmCWg==
X-Google-Smtp-Source: APXvYqwM+UF8jI1T+aagJDaJfADOGLfCZXElNxEFXucSCBFwMHgqqmRelbabnMwW+oEB2MZSUkQ5OAW1N6NmsNf7+fc=
X-Received: by 2002:a6b:f803:: with SMTP id o3mr1214144ioh.187.1566951846155;
 Tue, 27 Aug 2019 17:24:06 -0700 (PDT)
MIME-Version: 1.0
References: <20190826193638.6638-1-echron@arista.com> <1566909632.5576.14.camel@lca.pw>
In-Reply-To: <1566909632.5576.14.camel@lca.pw>
From: Edward Chron <echron@arista.com>
Date: Tue, 27 Aug 2019 17:23:54 -0700
Message-ID: <CAM3twVQEMGWMQEC0dduri0JWt3gH6F2YsSqOmk55VQz+CZDVKg@mail.gmail.com>
Subject: Re: [PATCH 00/10] OOM Debug print selection and additional information
To: Qian Cai <cai@lca.pw>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Shakeel Butt <shakeelb@google.com>, 
	linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Ivan Delalande <colona@arista.com>
Content-Type: multipart/alternative; boundary="0000000000002bc2d3059122687d"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--0000000000002bc2d3059122687d
Content-Type: text/plain; charset="UTF-8"

On Tue, Aug 27, 2019 at 5:40 AM Qian Cai <cai@lca.pw> wrote:

> On Mon, 2019-08-26 at 12:36 -0700, Edward Chron wrote:
> > This patch series provides code that works as a debug option through
> > debugfs to provide additional controls to limit how much information
> > gets printed when an OOM event occurs and or optionally print additional
> > information about slab usage, vmalloc allocations, user process memory
> > usage, the number of processes / tasks and some summary information
> > about these tasks (number runable, i/o wait), system information
> > (#CPUs, Kernel Version and other useful state of the system),
> > ARP and ND Cache entry information.
> >
> > Linux OOM can optionally provide a lot of information, what's missing?
> > ----------------------------------------------------------------------
> > Linux provides a variety of detailed information when an OOM event occurs
> > but has limited options to control how much output is produced. The
> > system related information is produced unconditionally and limited per
> > user process information is produced as a default enabled option. The
> > per user process information may be disabled.
> >
> > Slab usage information was recently added and is output only if slab
> > usage exceeds user memory usage.
> >
> > Many OOM events are due to user application memory usage sometimes in
> > combination with the use of kernel resource usage that exceeds what is
> > expected memory usage. Detailed information about how memory was being
> > used when the event occurred may be required to identify the root cause
> > of the OOM event.
> >
> > However, some environments are very large and printing all of the
> > information about processes, slabs and or vmalloc allocations may
> > not be feasible. For other environments printing as much information
> > about these as possible may be needed to root cause OOM events.
> >
>
> For more in-depth analysis of OOM events, people could use kdump to save a
> vmcore by setting "panic_on_oom", and then use the crash utility to
> analysis the
>  vmcore which contains pretty much all the information you need.
>

Certainly, this is the ideal. A full system dump would give you the maximum
amount of
information.

Unfortunately some environments may lack space to store the dump,
let alone the time to dump the storage contents and restart the system. Some
systems can take many minutes to fully boot up, to reset and reinitialize
all the
devices. So unfortunately this is not always an option, and we need an OOM
Report.


>
> The downside of that approach is that this is probably only for enterprise
> use-
> cases that kdump/crash may be tested properly on enterprise-level distros
> while
> the combo is more broken for developers on consumer distros due to
> kdump/crash
> could be affected by many kernel subsystems and have a tendency to be
> broken
> fairly quickly where the community testing is pretty much light.
>

--0000000000002bc2d3059122687d
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div dir=3D"ltr"><br></div><br><div class=3D"gmail_quote">=
<div dir=3D"ltr" class=3D"gmail_attr">On Tue, Aug 27, 2019 at 5:40 AM Qian =
Cai &lt;<a href=3D"mailto:cai@lca.pw">cai@lca.pw</a>&gt; wrote:<br></div><b=
lockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-le=
ft:1px solid rgb(204,204,204);padding-left:1ex">On Mon, 2019-08-26 at 12:36=
 -0700, Edward Chron wrote:<br>
&gt; This patch series provides code that works as a debug option through<b=
r>
&gt; debugfs to provide additional controls to limit how much information<b=
r>
&gt; gets printed when an OOM event occurs and or optionally print addition=
al<br>
&gt; information about slab usage, vmalloc allocations, user process memory=
<br>
&gt; usage, the number of processes / tasks and some summary information<br=
>
&gt; about these tasks (number runable, i/o wait), system information<br>
&gt; (#CPUs, Kernel Version and other useful state of the system),<br>
&gt; ARP and ND Cache entry information.<br>
&gt; <br>
&gt; Linux OOM can optionally provide a lot of information, what&#39;s miss=
ing?<br>
&gt; ----------------------------------------------------------------------=
<br>
&gt; Linux provides a variety of detailed information when an OOM event occ=
urs<br>
&gt; but has limited options to control how much output is produced. The<br=
>
&gt; system related information is produced unconditionally and limited per=
<br>
&gt; user process information is produced as a default enabled option. The<=
br>
&gt; per user process information may be disabled.<br>
&gt; <br>
&gt; Slab usage information was recently added and is output only if slab<b=
r>
&gt; usage exceeds user memory usage.<br>
&gt; <br>
&gt; Many OOM events are due to user application memory usage sometimes in<=
br>
&gt; combination with the use of kernel resource usage that exceeds what is=
<br>
&gt; expected memory usage. Detailed information about how memory was being=
<br>
&gt; used when the event occurred may be required to identify the root caus=
e<br>
&gt; of the OOM event.<br>
&gt; <br>
&gt; However, some environments are very large and printing all of the<br>
&gt; information about processes, slabs and or vmalloc allocations may<br>
&gt; not be feasible. For other environments printing as much information<b=
r>
&gt; about these as possible may be needed to root cause OOM events.<br>
&gt; <br>
<br>
For more in-depth analysis of OOM events, people could use kdump to save a<=
br>
vmcore by setting &quot;panic_on_oom&quot;, and then use the crash utility =
to analysis the<br>
=C2=A0vmcore which contains pretty much all the information you need.<br></=
blockquote><div><br></div><div>Certainly, this is the ideal. A full system =
dump would give you the maximum amount of</div><div>information.=C2=A0</div=
><div><br></div><div>Unfortunately some environments may lack space to stor=
e the dump,</div><div>let alone the time to dump the storage contents and r=
estart the system. Some</div><div>systems can take many minutes to fully bo=
ot up, to reset and reinitialize all the</div><div>devices. So unfortunatel=
y this is not always an option, and we need an OOM Report.</div><div>=C2=A0=
</div><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;b=
order-left:1px solid rgb(204,204,204);padding-left:1ex">
<br>
The downside of that approach is that this is probably only for enterprise =
use-<br>
cases that kdump/crash may be tested properly on enterprise-level distros w=
hile<br>
the combo is more broken for developers on consumer distros due to kdump/cr=
ash<br>
could be affected by many kernel subsystems and have a tendency to be broke=
n<br>
fairly quickly where the community testing is pretty much light.<br>
</blockquote></div></div>

--0000000000002bc2d3059122687d--

