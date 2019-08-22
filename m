Return-Path: <SRS0=SaVu=WS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 485B1C3A5A3
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 14:58:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 01A7B2133F
	for <linux-mm@archiver.kernel.org>; Thu, 22 Aug 2019 14:58:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=arista.com header.i=@arista.com header.b="UM0OClov"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 01A7B2133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=arista.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8F01D6B0328; Thu, 22 Aug 2019 10:58:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8C6326B0329; Thu, 22 Aug 2019 10:58:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 801996B032A; Thu, 22 Aug 2019 10:58:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0019.hostedemail.com [216.40.44.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5C4056B0328
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 10:58:28 -0400 (EDT)
Received: from smtpin28.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id D98CE52DE
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 14:58:27 +0000 (UTC)
X-FDA: 75850369854.28.magic91_83fadd0b97527
X-HE-Tag: magic91_83fadd0b97527
X-Filterd-Recvd-Size: 7288
Received: from mail-io1-f66.google.com (mail-io1-f66.google.com [209.85.166.66])
	by imf08.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 22 Aug 2019 14:58:26 +0000 (UTC)
Received: by mail-io1-f66.google.com with SMTP id 18so12389688ioe.10
        for <linux-mm@kvack.org>; Thu, 22 Aug 2019 07:58:26 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=arista.com; s=googlenew;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=jgVoa6JwoQi1MhP2MERTT+YwIetb6XqJZqnbSBRQqeE=;
        b=UM0OClovJAsZK4SVLI1W4PgjS2pT/T8mrHC4mQWrjc0jWG6IJsR8B6yLSF7yPWulii
         5PoRKbue+ENmfo989CL9UxQZd6j7QmUOvG/PuRod18Ja/Cvuy4oCg3+206ACJ4xvox9F
         DvzLli9csfXGygCScGWG52zuXpIvSMH8SjXQjr/OfwAbt/qkTgSA+zcl8fdrLNRPphiF
         zhFqgK5W1b83D/ux08SM7k5Ku9+um8hRS8VkIGYsnBswPiyimkbgNkXKf+LRkadKZ8ny
         bpDRD+rQhL6gXGYAEdplx2XLSu664wpl+Qc1ymxKokLYzf1kXiNsiSBsAGYs5CR76W6/
         DNbg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=jgVoa6JwoQi1MhP2MERTT+YwIetb6XqJZqnbSBRQqeE=;
        b=RGcqqo0OIkKGqSw3TJ1PuO724lBOu7UPJHDAOYRR47+dRG71eSGbcM9dQ5Xvae/kvR
         wPX/ChAS0Wf38utzy5amWnk1NI1G7EyGc71x8h2J3SnGJ4b44tumlX49jZPp40wKb0CQ
         r/PZ3VC/DKKZwIG5e8q1pZgdj6DwCWzkYhD1pY65yKXzfkC8m+alTAZY1nR90mgzzefm
         IoYAGucSJWkrkVgkCyYGf4iyZ1OXrgBgnb2UyZruDIap1Ah8EiRXjKvmn+safuD4U4g7
         6IbPTm2I1kRKGvnXrITEPSYrbR7GmmBUhmx2YhZWIJbRiHzZTxMHSY1k9wL0QVLPlmDt
         YCDw==
X-Gm-Message-State: APjAAAW7bUeS2Hr+36A26FDRn8AdUNeFx05/T+DKn3D51kNdmrnIVAVD
	PhfrJvvDGnkO0OSYnMuPcT+tENJ2JeMLQO7ZxM9QRw==
X-Google-Smtp-Source: APXvYqyhPymqerIa6Hnr50UU3poy7ET151y90rI4PRdzYA75GiqXE5ORZAVET2+3oP3axlwGQZfJoWnTVs2yqTXqfjA=
X-Received: by 2002:a6b:8b0b:: with SMTP id n11mr62379iod.101.1566485906276;
 Thu, 22 Aug 2019 07:58:26 -0700 (PDT)
MIME-Version: 1.0
References: <20190821001445.32114-1-echron@arista.com> <alpine.DEB.2.21.1908202024300.141379@chino.kir.corp.google.com>
 <CAM3twVSfO7Z-fgHxy0CDgnJ33X6OgRzbrF+210QSGfPF4mxEuQ@mail.gmail.com> <20190822070919.GB12785@dhcp22.suse.cz>
In-Reply-To: <20190822070919.GB12785@dhcp22.suse.cz>
From: Edward Chron <echron@arista.com>
Date: Thu, 22 Aug 2019 07:58:14 -0700
Message-ID: <CAM3twVQofTYg40YtntCkkss9G7Ha9aOBvw2aERi6PBH-isjr=g@mail.gmail.com>
Subject: Re: [PATCH] mm/oom: Add oom_score_adj value to oom Killed process message
To: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Shakeel Butt <shakeelb@google.com>, 
	linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
	Ivan Delalande <colona@arista.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 22, 2019 at 12:09 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Wed 21-08-19 15:25:13, Edward Chron wrote:
> > On Tue, Aug 20, 2019 at 8:25 PM David Rientjes <rientjes@google.com> wrote:
> > >
> > > On Tue, 20 Aug 2019, Edward Chron wrote:
> > >
> > > > For an OOM event: print oom_score_adj value for the OOM Killed process to
> > > > document what the oom score adjust value was at the time the process was
> > > > OOM Killed. The adjustment value can be set by user code and it affects
> > > > the resulting oom_score so it is used to influence kill process selection.
> > > >
> > > > When eligible tasks are not printed (sysctl oom_dump_tasks = 0) printing
> > > > this value is the only documentation of the value for the process being
> > > > killed. Having this value on the Killed process message documents if a
> > > > miscconfiguration occurred or it can confirm that the oom_score_adj
> > > > value applies as expected.
> > > >
> > > > An example which illustates both misconfiguration and validation that
> > > > the oom_score_adj was applied as expected is:
> > > >
> > > > Aug 14 23:00:02 testserver kernel: Out of memory: Killed process 2692
> > > >  (systemd-udevd) total-vm:1056800kB, anon-rss:1052760kB, file-rss:4kB,
> > > >  shmem-rss:0kB oom_score_adj:1000
> > > >
> > > > The systemd-udevd is a critical system application that should have an
> > > > oom_score_adj of -1000. Here it was misconfigured to have a adjustment
> > > > of 1000 making it a highly favored OOM kill target process. The output
> > > > documents both the misconfiguration and the fact that the process
> > > > was correctly targeted by OOM due to the miconfiguration. Having
> > > > the oom_score_adj on the Killed message ensures that it is documented.
> > > >
> > > > Signed-off-by: Edward Chron <echron@arista.com>
> > > > Acked-by: Michal Hocko <mhocko@suse.com>
> > >
> > > Acked-by: David Rientjes <rientjes@google.com>
> > >
> > > vm.oom_dump_tasks is pretty useful, however, so it's curious why you
> > > haven't left it enabled :/
> > >
> > > > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > > > index eda2e2a0bdc6..c781f73b6cd6 100644
> > > > --- a/mm/oom_kill.c
> > > > +++ b/mm/oom_kill.c
> > > > @@ -884,12 +884,13 @@ static void __oom_kill_process(struct task_struct *victim, const char *message)
> > > >        */
> > > >       do_send_sig_info(SIGKILL, SEND_SIG_PRIV, victim, PIDTYPE_TGID);
> > > >       mark_oom_victim(victim);
> > > > -     pr_err("%s: Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
> > > > +     pr_err("%s: Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB oom_score_adj:%ld\n",
> > > >               message, task_pid_nr(victim), victim->comm,
> > > >               K(victim->mm->total_vm),
> > > >               K(get_mm_counter(victim->mm, MM_ANONPAGES)),
> > > >               K(get_mm_counter(victim->mm, MM_FILEPAGES)),
> > > > -             K(get_mm_counter(victim->mm, MM_SHMEMPAGES)));
> > > > +             K(get_mm_counter(victim->mm, MM_SHMEMPAGES)),
> > > > +             (long)victim->signal->oom_score_adj);
> > > >       task_unlock(victim);
> > > >
> > > >       /*
> > >
> > > Nit: why not just use %hd and avoid the cast to long?
> >
> > Sorry I may have accidently top posted my response to this. Here is
> > where my response should go:
> > -----------------------------------------------------------------------------------------------------------------------------------
> >
> > Good point, I can post this with your correction.
> >
> > I will add your Acked-by: David Rientjes <rientjes@google.com>
> >
> > I am adding your Acked-by to the revised patch as this is what Michal
> > asked me to do (so I assume that is what I should do).
> >
> > Should I post as a separate fix again or simply post here?
>
> Andrew usually folds these small fixups automagically. If that doesn't
> happen here for some reason then just repost with acks and the fixup.
>

OK I will resubmit, wasn't sure if I should use --subject-prefix
"PATCH v2" or -v 2
or just resubmit but sounds like it should work either way.

> Thanks!
>
> --
> Michal Hocko
> SUSE Labs

