Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62B16C3A5A1
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 22:25:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2631E23403
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 22:25:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=arista.com header.i=@arista.com header.b="CSPe5oLS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2631E23403
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=arista.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B5876B02B3; Wed, 21 Aug 2019 18:25:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9662C6B02B4; Wed, 21 Aug 2019 18:25:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8A4AD6B02B5; Wed, 21 Aug 2019 18:25:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0052.hostedemail.com [216.40.44.52])
	by kanga.kvack.org (Postfix) with ESMTP id 68A2D6B02B3
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 18:25:27 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 1E016180AD803
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 22:25:27 +0000 (UTC)
X-FDA: 75847867494.03.net98_2f831f1b91a59
X-HE-Tag: net98_2f831f1b91a59
X-Filterd-Recvd-Size: 6565
Received: from mail-io1-f68.google.com (mail-io1-f68.google.com [209.85.166.68])
	by imf22.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 22:25:26 +0000 (UTC)
Received: by mail-io1-f68.google.com with SMTP id x4so7809735iog.13
        for <linux-mm@kvack.org>; Wed, 21 Aug 2019 15:25:25 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=arista.com; s=googlenew;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Oy2sEaeUKQmIQDPnRHPvhcv2oR+KrijeR8lZYw8C0/k=;
        b=CSPe5oLS5GCxhgWQHq7yG/45Wg9e/dcWfFbvVFUOIsEVMJdZpfA/aKz+r7CI1beOsg
         86MdsJUsnV+wsOxFltJkf3VxoPs3AeT+rO9MHIufSAnfPYcJGgCo9VCu3C791QS2ksW8
         fnVsI6EvzYRseYPoUwiicdAuYpiIrE3mZ4LUbeQYrGq+ffvzPF1WozYb9yFaPKcDXFlt
         VuF0CNfyYEmTcstqpLwpCtL6a1vV4HLPjueD8ZFRQAECGw5vNqbeZn/Sdt/LBlFb/FlP
         BykJ83k8VyhtKxLpHT1xX3wXOfcpZR2LPiidgFv/MpUnsXkVKkuChZE46KTAO+DgvcFq
         KKJg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=Oy2sEaeUKQmIQDPnRHPvhcv2oR+KrijeR8lZYw8C0/k=;
        b=n+4Xd14PuSkjnv45mLGqaXDZYaHVloYa6wRsLxx0WbzwPb2tqQMt6BkvbeeXiAjv9Q
         ltNl/xdcXebVP69TT6pPoJ91NpI9uR8AugLYPQ5mkv0nBMZWQIljCD65Y7W+deVpMRLE
         pUPKs4T7C3Qxs3ts5/7ecTCenDRDpgBNNqG7/T6Vz4KOP3o5sowbtxs2cjwPYZ3k2aSl
         emROSfXsDVLMXnuEUrWrY2hZ7JOCGaBPx2AIqrCsTRS8FTCOmqYnoxwrcs/i6oFywwI0
         NphbtPd+bvBbUQlDCA+PZjJNYwi/iRJn1rZeaNS29THhEe97rTF4XQUbNK8LcKjYHJZX
         FR1A==
X-Gm-Message-State: APjAAAVFFWZWRmnZ9K3OIqEQxiexdG48ZG2CFqFFexdE1enkIv+GM1r0
	j26ByO9t7xeyvcmYJCszXzaRfIE4p6z5Z+4xOmoTlw==
X-Google-Smtp-Source: APXvYqxogVj5UGWnLw3ZYO4+aHd3dAgmuZTb+9ASSNDaOafz38TIIp6+hr7TuauJyMcZe39gLj9RHKEIQTyQ3LHEXRE=
X-Received: by 2002:a5e:8e0d:: with SMTP id a13mr38379962ion.28.1566426325439;
 Wed, 21 Aug 2019 15:25:25 -0700 (PDT)
MIME-Version: 1.0
References: <20190821001445.32114-1-echron@arista.com> <alpine.DEB.2.21.1908202024300.141379@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.21.1908202024300.141379@chino.kir.corp.google.com>
From: Edward Chron <echron@arista.com>
Date: Wed, 21 Aug 2019 15:25:13 -0700
Message-ID: <CAM3twVSfO7Z-fgHxy0CDgnJ33X6OgRzbrF+210QSGfPF4mxEuQ@mail.gmail.com>
Subject: Re: [PATCH] mm/oom: Add oom_score_adj value to oom Killed process message
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
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

On Tue, Aug 20, 2019 at 8:25 PM David Rientjes <rientjes@google.com> wrote:
>
> On Tue, 20 Aug 2019, Edward Chron wrote:
>
> > For an OOM event: print oom_score_adj value for the OOM Killed process to
> > document what the oom score adjust value was at the time the process was
> > OOM Killed. The adjustment value can be set by user code and it affects
> > the resulting oom_score so it is used to influence kill process selection.
> >
> > When eligible tasks are not printed (sysctl oom_dump_tasks = 0) printing
> > this value is the only documentation of the value for the process being
> > killed. Having this value on the Killed process message documents if a
> > miscconfiguration occurred or it can confirm that the oom_score_adj
> > value applies as expected.
> >
> > An example which illustates both misconfiguration and validation that
> > the oom_score_adj was applied as expected is:
> >
> > Aug 14 23:00:02 testserver kernel: Out of memory: Killed process 2692
> >  (systemd-udevd) total-vm:1056800kB, anon-rss:1052760kB, file-rss:4kB,
> >  shmem-rss:0kB oom_score_adj:1000
> >
> > The systemd-udevd is a critical system application that should have an
> > oom_score_adj of -1000. Here it was misconfigured to have a adjustment
> > of 1000 making it a highly favored OOM kill target process. The output
> > documents both the misconfiguration and the fact that the process
> > was correctly targeted by OOM due to the miconfiguration. Having
> > the oom_score_adj on the Killed message ensures that it is documented.
> >
> > Signed-off-by: Edward Chron <echron@arista.com>
> > Acked-by: Michal Hocko <mhocko@suse.com>
>
> Acked-by: David Rientjes <rientjes@google.com>
>
> vm.oom_dump_tasks is pretty useful, however, so it's curious why you
> haven't left it enabled :/
>
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index eda2e2a0bdc6..c781f73b6cd6 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -884,12 +884,13 @@ static void __oom_kill_process(struct task_struct *victim, const char *message)
> >        */
> >       do_send_sig_info(SIGKILL, SEND_SIG_PRIV, victim, PIDTYPE_TGID);
> >       mark_oom_victim(victim);
> > -     pr_err("%s: Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
> > +     pr_err("%s: Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB oom_score_adj:%ld\n",
> >               message, task_pid_nr(victim), victim->comm,
> >               K(victim->mm->total_vm),
> >               K(get_mm_counter(victim->mm, MM_ANONPAGES)),
> >               K(get_mm_counter(victim->mm, MM_FILEPAGES)),
> > -             K(get_mm_counter(victim->mm, MM_SHMEMPAGES)));
> > +             K(get_mm_counter(victim->mm, MM_SHMEMPAGES)),
> > +             (long)victim->signal->oom_score_adj);
> >       task_unlock(victim);
> >
> >       /*
>
> Nit: why not just use %hd and avoid the cast to long?

Sorry I may have accidently top posted my response to this. Here is
where my response should go:
-----------------------------------------------------------------------------------------------------------------------------------

Good point, I can post this with your correction.

I will add your Acked-by: David Rientjes <rientjes@google.com>

I am adding your Acked-by to the revised patch as this is what Michal
asked me to do (so I assume that is what I should do).

Should I post as a separate fix again or simply post here?

I'll post here and if you prefer a fresh submission, let me know and
I'll do that.

Thank-you for reviewing this patch.

