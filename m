Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15478C10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 16:47:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BD443217D4
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 16:47:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="HsUA/mVq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BD443217D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5C1C96B026B; Thu, 11 Apr 2019 12:47:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5487F6B026C; Thu, 11 Apr 2019 12:47:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3E9DE6B026D; Thu, 11 Apr 2019 12:47:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id DFC106B026B
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 12:47:44 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id k81so4161112wmf.1
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 09:47:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=dv8W0uSuhruB6Ow9v6QugrS+DKPFo5aGlRKpFpwFspQ=;
        b=SHDYAB58ebjW9o0A7CCO93ze6YeG0zqOKp5iZPc8uN7f88RLvO1UrZfX+Vp1nBy11t
         Rt40fyZ7YrQdkfXRLY4HlXhpVpuI9LIBcIVZ6zkSiH+LtBA8TNZWpFVcvarJga2DuxXQ
         vrafzKEw7bp03oTyMYbrWEXf0xPRJ3Y4+6X4acKvC6hAEXWG/6smssKn6771a9JR6RMw
         1Z1lMRYSVHoQnRjIqRYGIdAG2ubD9vcREkyl5MnALracMPGxYKtb1yDpGnV//avi+5XT
         aumFDuXrXEmo2kEyjBRc8cfFYMe89vC7x23ogb1S4iATiO86wQv2dbOnS0IAAL/A5796
         v4kA==
X-Gm-Message-State: APjAAAX1vpdr/clFLYDNmVYSRcSxF0w7J3hacTEOLD5xSsx8NXwqtcIS
	lnXHRIYLzk7Gpt4R1XDOLN1/N9HR3ukIdvz/TjNaGti+TJsoUpQc4Z6GGXJZP+Mm2/wcCzggUV7
	e42paM1JIrcWOihU1lt9I0ModcJ2o+F3bFmg4ipq/5h5L3g3jBYgFqPVahuVfaBOiCQ==
X-Received: by 2002:adf:f1cc:: with SMTP id z12mr18033594wro.180.1555001264455;
        Thu, 11 Apr 2019 09:47:44 -0700 (PDT)
X-Received: by 2002:adf:f1cc:: with SMTP id z12mr18033542wro.180.1555001263581;
        Thu, 11 Apr 2019 09:47:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555001263; cv=none;
        d=google.com; s=arc-20160816;
        b=bD7h3DYwOYGT1HWeVDY1lObIIGxZy7ByfIg0Qb1DJgC0WsFAHpoZ4hzqxbeJFK9kXo
         V+j7tGhZOUWZdvIJ1M6QFZz0mM3dvWGeWPFsc9vFO4A+PmmeN449nwVzjNtp2UGuYGLh
         UMaedMrMl6M9oO6i0Va60sVz3CedwcDrwnng24PdypJd94BNo+cYZAPc4TIjsUtrR3QL
         2+X6MWDrQkeb06Fh8w2a/G+KOnl2vhUGigDrBqIBqjQ7aBmr8XHZS6hFfR81qPU6zUSk
         Q0TrCNnYLmjcCCIYD4cPXgv7Hysd3Ge70UvkyhwkSexDLBuRc24hv5aU33vyk3e+A4b7
         WVmg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=dv8W0uSuhruB6Ow9v6QugrS+DKPFo5aGlRKpFpwFspQ=;
        b=UheZGSd4e1ckpaoxlajuztn7Il3YM0vd0SfZoHA8+W4Iw2kJz/4lG3sMlvGlqAzUqV
         xGCC/l/3ldl4Nhw+UmRpTEI4QUfvhm0upqc8FRSiNczezpOqLgSv2zKG1bVay5xyu5Ik
         U9ZJfv8eG5MVHqbtAGDwC64CWYKlKs75zoePkyX19SiAwEqerbMqSfHZqXRyJA45fFB1
         U16smgvSAAkN/FeHeHtC4SMiVan0q+PzaH/Iw7y3zgTRwU6XYfTuUdEbcXMB+9XH06F1
         Eaxt9oIT/ApK4VU6bLapp3rzdIi1Ed+JpaGKTADxASUDEmQFUoVS3o5UHePZ/3S+83j1
         RogQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="HsUA/mVq";
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v125sor3980790wma.2.2019.04.11.09.47.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Apr 2019 09:47:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="HsUA/mVq";
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=dv8W0uSuhruB6Ow9v6QugrS+DKPFo5aGlRKpFpwFspQ=;
        b=HsUA/mVqT8CymoEiQoNg0/Gf38OXb3WUWxUJmy731gBB6WpUMaeudGZ4f19nZXlzTl
         TUgarR5hli10/HNcDwnIEshjO+2nNAFiloYql2j0uI0K/AoJsk3UPhZTXucSG4WRnEOg
         b+Il+Beep7TnFFCGGSx4kjhDo3oX+C9KtOhYm28Z4VzCPAZ4T7E1dqOerdtTOdSEY3XP
         JJfMLdH0fnD2qW/y71NuWz56BnewagU2COLoblBvdKnf+8j2h3vkpG1NBCiZEB8z7cAV
         Y7Stz4CxTNVZsbh40Maxh/sVRF1QdfRvGGs+1yHavzdRPA/5mwwAna8t5/lHibGm49Sa
         EqbA==
X-Google-Smtp-Source: APXvYqyUhP38IRLUvPR0RERwVmyTMwrFXW5LElNnjZkqnR1nruiB0aChEoQo7d8r3XG4O0l8VEhObtZBwb3LreblKDU=
X-Received: by 2002:a1c:7512:: with SMTP id o18mr7772122wmc.68.1555001262701;
 Thu, 11 Apr 2019 09:47:42 -0700 (PDT)
MIME-Version: 1.0
References: <20190411014353.113252-1-surenb@google.com> <20190411105111.GR10383@dhcp22.suse.cz>
In-Reply-To: <20190411105111.GR10383@dhcp22.suse.cz>
From: Suren Baghdasaryan <surenb@google.com>
Date: Thu, 11 Apr 2019 09:47:31 -0700
Message-ID: <CAJuCfpEqCKSHwAmR_TR3FaQzb=jkPH1nvzvkhAG57=Pb09GVrA@mail.gmail.com>
Subject: Re: [RFC 0/2] opportunistic memory reclaim of a killed process
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, 
	Matthew Wilcox <willy@infradead.org>, yuzhoujian@didichuxing.com, 
	Souptick Joarder <jrdr.linux@gmail.com>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, ebiederm@xmission.com, 
	Shakeel Butt <shakeelb@google.com>, Christian Brauner <christian@brauner.io>, 
	Minchan Kim <minchan@kernel.org>, Tim Murray <timmurray@google.com>, 
	Daniel Colascione <dancol@google.com>, Joel Fernandes <joel@joelfernandes.org>, Jann Horn <jannh@google.com>, 
	linux-mm <linux-mm@kvack.org>, lsf-pc@lists.linux-foundation.org, 
	LKML <linux-kernel@vger.kernel.org>, kernel-team <kernel-team@android.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Thanks for the feedback!

On Thu, Apr 11, 2019 at 3:51 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Wed 10-04-19 18:43:51, Suren Baghdasaryan wrote:
> [...]
> > Proposed solution uses existing oom-reaper thread to increase memory
> > reclaim rate of a killed process and to make this rate more determinist=
ic.
> > By no means the proposed solution is considered the best and was chosen
> > because it was simple to implement and allowed for test data collection=
.
> > The downside of this solution is that it requires additional =E2=80=9Ce=
xpedite=E2=80=9D
> > hint for something which has to be fast in all cases. Would be great to
> > find a way that does not require additional hints.
>
> I have to say I do not like this much. It is abusing an implementation
> detail of the OOM implementation and makes it an official API.

I agree with you that this particular implementation is abusing oom
internal machinery and I don't think it is acceptable as is (hence
this is sent as an RFC). I would like to discuss the viability of the
idea of reaping kill victim's mm asynchronously. If we agree that this
is worth our time, only then I would love to get into more details on
how to implement it. The implementation in this RFC is a convenient
way to illustrate the idea and to collect test data.

> Also
> there are some non trivial assumptions to be fullfilled to use the
> current oom_reaper. First of all all the process groups that share the
> address space have to be killed. How do you want to guarantee/implement
> that with a simply kill to a thread/process group?
>

I'm not sure I understood this correctly but if you are asking how do
we know that the mm we are reaping is not shared with processes that
are not being killed then I think your task_will_free_mem() checks for
that. Or have I misunderstood your question?

> > Other possible approaches include:
> > - Implementing a dedicated syscall to perform opportunistic reclaim in =
the
> > context of the process waiting for the victim=E2=80=99s death. A natura=
l boost
> > bonus occurs if the waiting process has high or RT priority and is not
> > limited by cpuset cgroup in its CPU choices.
> > - Implement a mechanism that would perform opportunistic reclaim if it=
=E2=80=99s
> > possible unconditionally (similar to checks in task_will_free_mem()).
> > - Implement opportunistic reclaim that uses shrinker interface, PSI or
> > other memory pressure indications as a hint to engage.
>
> I would question whether we really need this at all? Relying on the exit
> speed sounds like a fundamental design problem of anything that relies
> on it.

Relying on it is wrong, I agree. There are protections like allocation
throttling that we can fall back to stop memory depletion. However
having a way to free up resources that are not needed by a dying
process quickly would help to avoid throttling which hurts user
experience.
I agree that this is an optimization which is beneficial in a specific
case - when we kill to free up resources. However this is an important
optimization for systems with low memory resources like embedded
systems, phones, etc. The only way to prevent being cornered into
throttling is to increase the free memory margin that system needs to
maintain (I describe this in my cover letter). And with limited
overall memory resources memory space is at a premium, so we try to
decrease that margin.
I think the other and arguably even more important issue than the
speed of memory reclaim is that this speed depends on what the victim
is doing at the time of a kill. This introduces non-determinism in how
fast we can free up resource and at this point we don't even know how
much safety margin we need.

> Sure task exit might be slow, but async mm tear down is just a
> mere optimization this is not guaranteed to really help in speading
> things up. OOM killer uses it as a guarantee for a forward progress in a
> finite time rather than as soon as possible.
>
> --
> Michal Hocko
> SUSE Labs
>
> --
> You received this message because you are subscribed to the Google Groups=
 "kernel-team" group.
> To unsubscribe from this group and stop receiving emails from it, send an=
 email to kernel-team+unsubscribe@android.com.
>

