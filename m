Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 989A0C41514
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 06:25:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5079A2133F
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 06:25:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=arista.com header.i=@arista.com header.b="kh07Irpz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5079A2133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=arista.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D90F66B0003; Thu, 15 Aug 2019 02:25:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D415B6B0005; Thu, 15 Aug 2019 02:25:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C2F0F6B0007; Thu, 15 Aug 2019 02:25:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0194.hostedemail.com [216.40.44.194])
	by kanga.kvack.org (Postfix) with ESMTP id 940516B0003
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 02:25:05 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 3EE208248AA6
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 06:25:05 +0000 (UTC)
X-FDA: 75823674570.05.cave59_2c54d4a0ba619
X-HE-Tag: cave59_2c54d4a0ba619
X-Filterd-Recvd-Size: 13453
Received: from mail-ot1-f68.google.com (mail-ot1-f68.google.com [209.85.210.68])
	by imf19.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 06:25:04 +0000 (UTC)
Received: by mail-ot1-f68.google.com with SMTP id r20so3769549ota.5
        for <linux-mm@kvack.org>; Wed, 14 Aug 2019 23:25:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=arista.com; s=googlenew;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=mb+M26McHMvpEXZSGP1QgdcAoELMWhV+ZuFZvUwvw2E=;
        b=kh07Irpz/UwZNdH/fUZYB9dl6IEtkN1LQBMC7RjUbK72alpIA6aRk2+6c43XAK/G3W
         AkZkKt7C5UlDX0iZrXoyi051suCOhgWlHsJcx1U2Wypyt5aHZkKuIJIvJjKZh4/XrwG7
         qubf8MnI+5HF5Wdrox+bMnlmo8yEef3bHmlzE0tlwaWHFyBgFQ4nO2OnUlrURIoEonY1
         SjI7tjTK79eKdECaxkDcvocStVMzRX27bTKJLAmEomEi8yoXlHIh3HH4Ml05AFufvt/G
         mwjDM4gCDsZBPim5F/O0hABOmR37DSCoY8f192cfGgClT7T7mSqH6dBURNJf8MFECcEb
         itQg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=mb+M26McHMvpEXZSGP1QgdcAoELMWhV+ZuFZvUwvw2E=;
        b=fq5mS9oU/BAnJG326rJ3MCKmpPCdp4Lf4ebqIRLt2ktQYThKOdncSIeRwuvrz56Yym
         Ids0obcf3KKQ1mVEXIgQ+NMSHnSLS+LwmDWKlE8sK+iQIytqN4DPfReXswE5N/36b2Si
         QQ93FVJgkuDfkJkMGN2fSMo1hXOmM1Ohuly+uYuWpBa6U1DCYYy1YmHYgRO1cV17M2qu
         +3F+0JIXx/crhCDiuMxwmpl9VHSQb6ooZ7FhWA70IQR8ypMF0rSWZ4958iR2iwIINvl8
         RX3ZVUhLhsqJ7aS/l3pJhQXOUk4OJ9FplsTYe9MixLWubajYIf7E21WQPahBKL3GnWgr
         /J4Q==
X-Gm-Message-State: APjAAAUNmCB1D48/FQETxbREo0ll0bTVZxBDRKcpsuoGB4b63t0IjEfz
	FCZLcDt3bUw159TEalAy3hUjY82Es6toXYGaHUGKBw==
X-Google-Smtp-Source: APXvYqyYB+xC/oMD1B7owIitzZeWWHNioHrNFF2R3rnysZjbb/hRsU95DpP2tCtlzhgreIyrxP3mJ30O87UnDydtBrw=
X-Received: by 2002:a6b:3ed4:: with SMTP id l203mr3866145ioa.275.1565850303144;
 Wed, 14 Aug 2019 23:25:03 -0700 (PDT)
MIME-Version: 1.0
References: <20190808183247.28206-1-echron@arista.com> <20190808185119.GF18351@dhcp22.suse.cz>
 <CAM3twVT0_f++p1jkvGuyMYtaYtzgEiaUtb8aYNCmNScirE4=og@mail.gmail.com>
 <20190808200715.GI18351@dhcp22.suse.cz> <CAM3twVS7tqcHmHqjzJqO5DEsxzLfBaYF0FjVP+Jjb1ZS4rA9qA@mail.gmail.com>
 <20190809064032.GJ18351@dhcp22.suse.cz> <CAM3twVRCTLdn+Lhcr+4ZdY3nYVvXFe1O19UR9H121W34H=oV7g@mail.gmail.com>
 <20190812114256.GG5117@dhcp22.suse.cz>
In-Reply-To: <20190812114256.GG5117@dhcp22.suse.cz>
From: Edward Chron <echron@arista.com>
Date: Wed, 14 Aug 2019 23:24:51 -0700
Message-ID: <CAM3twVSXEwN+r8YG=z3fmnN0G55N5HD-Bnh6g=MVk75qB1kpWQ@mail.gmail.com>
Subject: Re: [PATCH] mm/oom: Add killed process selection information
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

On Mon, Aug 12, 2019 at 4:42 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Fri 09-08-19 15:15:18, Edward Chron wrote:
> [...]
> > So it is optimal if you only have to go and find the correct log and search
> > or run your script(s) when you absolutely need to, not on every OOM event.
>
> OK, understood.
>
> > That is the whole point of triage and triage is easier when you have
> > relevant information to decide which events require action and with what
> > priority.
> >
> > The OOM Killed message is the one message that we have go to
> > the console and or is sent as SNMP alert to the Admin to let the
> > Admin know that a server or switch has suffered a low memory OOM
> > event.
> >
> > Maybe a few examples would be helpful to show why the few extra
> > bits of information would be helpful in such an environment.
> >
> > For example if we see serverA and serverB are taking oom events
> > with the fooWidget being killed, something along the lines of
> > the following you will get message likes this:
> >
> > Jul 21 20:07:48 serverA kernel: Out of memory: Killed process 2826
> >  (fooWidget) total-vm:10493400kB, anon-rss:10492996kB, file-rss:128kB,
> >  shmem-rss:0kB memory-usage:32.0% oom_score: 320 oom_score_adj:0
> >  total-pages: 32791748kB
> >
> > Jul 21 20:13:51 serverB kernel: Out of memory: Killed process 2911
> >  (fooWidget) total-vm:11149196kB, anon-rss:11148508kB, file-rss:128kB,
> >  shmem-rss:0kB memory-usage:34.0% oom_score: 340 oom_score_adj:0
> >  total-pages: 32791748kB
> >
> > It is often possible to recognize that fooWidget is using more memory than
> > expected on those systems and you can act on that possibly without ever
> > having to hunt down the log and run a script or otherwise analyze the
> > log. The % of memory and memory size can often be helpful to understand
> > if the numbers look reasonable or not. Maybe the application was updated
> > on just the those systems which explains why we don't see issues on the
> > other servers running that application, possible application memory leak.
>
> This is all quite vague and requires a lot of guessing. Also your
> trained guess eye might easily get confused for constrained OOMs (e.g.
> due to NUMA or memcg). So I am not really sold to the percentage idea.
> And likewise the oom_score.
>
> [...]
>

Actually totalpages is used by oom control and is set to the appropriate
value for a memcg OOM event or to totalram_pages + totalswap if it is
a system wide OOM event.

The percentage coupled with the totalpages is how we know what we're
looking at and for our environments. Seems to work fine, but maybe there are
some environments where that is not the case.

I must be missing something here so I need to go back and study this.

> > You can also imagine that if for example systemd-udev gets OOM killed,
> > well that should really grab your attention:
> >
> > Jul 21 20:08:11 serverX kernel: Out of memory: Killed process 2911
> >  (systemd-udevd) total-vm:83128kB, anon-rss:80520kB, file-rss:128kB,
> >  shmem-rss:0kB memory-usage:0.1% oom_score: 1001 oom_score_adj:1000
> >  total-pages: 8312512kB
> >
> > Here we see an obvious issue: systemd-udevd is a critical system app
> > and it should not have an oom_score_adj: 1000 that clearly has been changed
> > it should be -1000.
>
> I do agree here. As I've said in the previous email oom_score_adj indeed
> has some value, and this is a nice example of that. So I am completely
> fine with a patch that adds this part to the changelog.
>
> [...]
> > > > The oom_score tells us how Linux calculated the score for the task,
> > > > the oom_score_adj effects this so it is helpful to have that in
> > > > conjunction with the oom_score.
> > > > If the adjust is high it can tell us that the task was acting as a
> > > > canary and so it's oom_score is high even though it's memory
> > > > utilization can be modest or low.
> > >
> > > I am sorry but I still do not get it. How are you going to use that
> > > information without seeing other eligible tasks. oom_score is just a
> > > normalized memory usage + some heuristics potentially (we have given a
> > > discount to root processes until just recently). So this value only
> > > makes sense to the kernel oom killer implementation. Note that the
> > > equation might change in the future (that has happen in the past several
> > > times) so looking at the value in isolation might be quite misleading.
> >
> > We've been through the change where oom_scores went from -17 to 16
> > to -1000 to 1000. This was the change David Rientjes from Google made
> > back around 2010.
> >
> > This was not a problem for us then and if you change again in the future
> > (though the current implementation seems quite reasonable) it shouldn't
> > be an issue for us going forward or for anyone else that can use the
> > additional information in the OOM Kill message we're proposing.
>
> While I appreciate that you are flexible enough to cope with those
> changes there are other users which might be less so and there is a
> strong "no regressions" rule which might get us into the corner so we
> are trying hard to not export to much of an internal information so that
> userspace doesn't start depending on them.
>
> [...]
>
> > Now what about the oom_score value changing that you mentioned?
> > What if you toss David's OOM Kill algorithm for a new algorithm?
> > That could happen. What happens to the message and how do we
> > tell things have changed?
> >
> > A different oom_score requires a different oom adjustment variable.
> > I hope we can agree on that and history supports this.
>
> The idea is that we would have to try to fit oom_score_adj semantic into
> a new algoritm and -1000..1000 value range would be hopefully good
> enough. That doesn't really dictate the internal calculation of the
> badness, if such a theretical alg. would use at all.
>
> > As you recall when David's algorithm was brought in, the Kernel OOM
> > team took good care of us. They added a new adjustment value:
> > oom_score_adj. As you'll recall the previous oom adjustment variable
> > was oom_adj. To keep user level code from breaking the Kernel OOM
> > developers provided a conversion so that if your application set
> > oom_adj = -17 the Linux OOM code internally set oom_score_adj = -1000.
> > They had a conversion that handled all the values. Eventually the
> > deprecated oom_adj field was removed, but it was around for several years.
>
> Yes, the scaling just happened to work back then.
>
> [...]
>
> > Further, you export oom_score through the /proc/pid/oom_score
> > interface. How the score is calculated could change but it is
> > accessible. It's accessible for a reason, it's useful to know how
> > the OOM algorithm scores a task and that can be used to help
> > set appropriate oom adjustment values. This because what the
> > oom_score means is in fact well documented. It needs to.
> > Otherwise, the oom adjustment value becomes impossible to
> > use intelligently. Thanks to David Rientjes et al for making this so.
>
> The point I am trying to push through is that the score (exported via
> proc or displayed via dump_tasks) is valuable only as far as you have a
> meaningful comparision to make - aka compare to scores of other tasks.
> The value on its own cannot tell you really much without a deep
> understanding of how it is calculated. And I absolutely do not want
> userspace to hardcode that alg. and rely on it being stable. You really
> do not need this internal knowledge when comparing scores of different
> tasks, though so it is quite safe and robust from future changes.
>
> We have made those mistakes when exporting way to much internal details
> to userspace in the past and got burnt.
>

Interesting. Knowing how the OOM code works and what oom_score means
allows us set a meaning oom_score_adj. When you provide an interface that
allows adjustment it is helpful to know as much as you can about the
impact it will have so you can set an appropriate value, at least that is how
I think about it. We reference source code as needed but of course
documentation is always appreciated and as you point out code changes
as needed.

> > One of the really nice design points of David Rientjes implementation
> > is that it is very straight forward to use and understand. So hopefully
> > if there is a change in the future it's to something that is just as easy
> > to use and to understand.
> >
> > >
> > > I can see some point in printing oom_score_adj, though. Seeing biased -
> > > one way or the other - tasks being selected might confirm the setting is
> > > reasonable or otherwise (e.g. seeing tasks with negative scores will
> > > give an indication that they might be not biased enough). Then you can
> > > go and check the eligible tasks dump and see what happened. So this part
> > > makes some sense to me.
> >
> > Agreed, the oom_score_adj is sorely needed and should be included.
>
> I am willing to ack a patch to add oom_score_adj on the grounds that
> this information is helpful to pinpoint misconfigurations and it is not
> generally available when dump_tasks is disabled.
>
> > In Summary:
> > ----------------
> > I hope I have presented a reasonable enough argument for the proposed
> > additional parameters.
>
> I am not convinced on oom_score and percentage part because score on its
> own is an implementation detail that makes sense when comparing tasks
> but on on its own and percentage might be even confusing as explained
> above.
>
> Thanks for your detailed information!

OK, Thank-you Michal.

I've coded up the small change to add the oom_score_adj to the OOM
Killed message and sent that up for your review.

I will go back and study constrained cases and try and figure out what
I'm missing there.
We're doing a lot of memcg processing now on our systems so I want to
make sure I understand this.
The OOM code has improved it's memcg processing in more recent releases.

Thanks again for your help!

Edward Chron
Arista Networks

> --
> Michal Hocko
> SUSE Labs

