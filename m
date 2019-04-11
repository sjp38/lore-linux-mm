Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1A69C10F14
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 16:54:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 711872133D
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 16:54:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="fNWDni2W"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 711872133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 100D46B026C; Thu, 11 Apr 2019 12:54:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0AEF76B026D; Thu, 11 Apr 2019 12:54:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F06826B026E; Thu, 11 Apr 2019 12:54:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id A6A476B026C
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 12:54:27 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id n11so4391494wmh.2
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 09:54:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Otu8oQ57F7UNmqh12Qrt5qvVebAwqh7zepUUOR2psCw=;
        b=tW+5ol9tocqQtWQQKpQ54Ha/W9OtnuI2QWFoQJC9rmDc4D6dBDbw3l8I8TeFkRWBaT
         Gyyy3g+MDU/vQBxkvVL7SLnaQZxCdPX7KNxttJ1OicICNuTzmqMpDu4Qm0sTvSXP+A1Z
         lIU8A+FztaFxyFirtmrcuP2ekeCCWBGEhYHI6DlkEVo0Py4kXN2vSfOb6ZlY3xNYe5z8
         CJ2jpWJRoc5QyDTPkixu1vlRWrX3KwAK4gE4vBCb6gUnPMrU9dO7iKFJUIMtVVgsYiYz
         Ue0o9ChknPADqj61ZB+ZlJiPWg3iyecRSxhA0VZaWRYPVHfrmSOr/+eWoV3dqGZ0PWsA
         1m+g==
X-Gm-Message-State: APjAAAU+CinyUiSaKhqA78JvwudgRtXqRUuRf6Ch+S2BjRPT7rYw0kyz
	s5kCp+eCZpMsc5eJrjuvWa1Xf6k0vutfVbXdq4PQGpScwYwmstjLWrEn8dCsORs8oSFEK2QQcuy
	piBlptP0fqhdFx492hYh0R3HZbq/5jk7+FqGU6SBi6007GMNopxruPEjK7lm4vbGM1A==
X-Received: by 2002:a7b:cbd6:: with SMTP id n22mr7988948wmi.57.1555001667157;
        Thu, 11 Apr 2019 09:54:27 -0700 (PDT)
X-Received: by 2002:a7b:cbd6:: with SMTP id n22mr7988652wmi.57.1555001661496;
        Thu, 11 Apr 2019 09:54:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555001661; cv=none;
        d=google.com; s=arc-20160816;
        b=mvdFNG50TNB7+VnZcx/AqAspeyD7h13jByhb5DXwudyyfaExmTw5JeJZz6+woKAgDy
         K8B74S5ltemG3+vbTB23tIsO/YdJuKU8PMyyJQG+/nnAtvYuX0mFok3ktuplcMHmezeE
         gTguWxKYWLSIyket85NOKjrRHxQx/N+jfT4dw4flOcfEWc5h4dLsuCo37qDOXEQC11HA
         pYfCx5kveVeSL81BAcRfgfUtjAbybNK2vNE/k3uPT4++PQKI/D3PhrHGNvqExKeYx5uv
         Fl4X1Zxg/0AvRSgruk4NQlrX/FNKdHbqgaM56TCSjfMqFI3jfo7uMKiQTyAEGtM3KsVP
         EkQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Otu8oQ57F7UNmqh12Qrt5qvVebAwqh7zepUUOR2psCw=;
        b=XuIMKa6zEnLiWjvhu1GZI1lrivq79GiwuN56FEwdIozQo8BO1rWdlv+TXgRCQf9kpe
         38T4saNUOCunwRI5cZyDfybFd/cMxnuuFBk64+jSjali4rthWsIaPvdupBqE6YKejrat
         ZN6lhQJLQJ8n49bmLgp5ZnHaj6Gfyx2o4rY3eqKOpQURehe8XVW+RwlcaxQdsFJWJROT
         I7642jwXIxZ+LDjIOxpI6nILop2ZHBEUEL+m0ONV4diby8ydK48P5X3H/TjOCdsV7O66
         PWlW2mnHhQZeXYDy+XAK02akT+Sw/CyBQJ1GOUxPog1TH53gzt5Ben/1ogeqma9HElKV
         47yg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=fNWDni2W;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x19sor14145443wrd.13.2019.04.11.09.54.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Apr 2019 09:54:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=fNWDni2W;
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Otu8oQ57F7UNmqh12Qrt5qvVebAwqh7zepUUOR2psCw=;
        b=fNWDni2WBHljHOFUUJspzmpa63RWuYdVIS0I3zOyBS2lLLO6KySQ51cmWNiO7hc2Zl
         ECt/C5Ky670bJQ5Y/0J0LhOCfc0Lt2Iwpob0TZ7SIP5kv9C9NNRB1wStqN/N2tYLuIKw
         wZg0KFFK27GJ1pbKVFkdVwDqOyreBFZk/jafrt6UExSb4bI4BAkAjcPUss8hpIGyWHct
         5ikRIfAdd9LNMlN4QIMJoanmN2oiEoSZWVAINnP8ESOpbf1mzxDB7iVXd9gmjJZUG9zF
         Ju866VB9mBqZkVotHQnuvZKKWpWRfOzBfvhObdATWC3h+6KUBTdrH/MXs5IMpClUYU84
         G7mQ==
X-Google-Smtp-Source: APXvYqwj1boQo/nBHeqnGk+RcSMgv151Qay/U+p6/XYdYT7weeYhs8WiIbKmtBlUigIKITxE7cnT6zBNx7yHx2o6yRk=
X-Received: by 2002:adf:cf0c:: with SMTP id o12mr12832082wrj.16.1555001660732;
 Thu, 11 Apr 2019 09:54:20 -0700 (PDT)
MIME-Version: 1.0
References: <20190411014353.113252-1-surenb@google.com> <e1fc2c84f5ef2e1408f6fee7228a52a458990b31.camel@surriel.com>
 <20190411121633.GV10383@dhcp22.suse.cz>
In-Reply-To: <20190411121633.GV10383@dhcp22.suse.cz>
From: Suren Baghdasaryan <surenb@google.com>
Date: Thu, 11 Apr 2019 09:54:09 -0700
Message-ID: <CAJuCfpG0qE4LCq78UzT-Bh0Q+iYL0yaMByqeaNDwmXgrXCVZVQ@mail.gmail.com>
Subject: Re: [Lsf-pc] [RFC 0/2] opportunistic memory reclaim of a killed process
To: Michal Hocko <mhocko@kernel.org>
Cc: Rik van Riel <riel@surriel.com>, Suren Baghdasaryan <surenb@google.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Daniel Colascione <dancol@google.com>, 
	Jann Horn <jannh@google.com>, Minchan Kim <minchan@kernel.org>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, kernel-team <kernel-team@android.com>, 
	David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, 
	Matthew Wilcox <willy@infradead.org>, linux-mm <linux-mm@kvack.org>, 
	Johannes Weiner <hannes@cmpxchg.org>, Shakeel Butt <shakeelb@google.com>, 
	Souptick Joarder <jrdr.linux@gmail.com>, yuzhoujian@didichuxing.com, 
	Joel Fernandes <joel@joelfernandes.org>, Tim Murray <timmurray@google.com>, 
	lsf-pc@lists.linux-foundation.org, Roman Gushchin <guro@fb.com>, 
	Christian Brauner <christian@brauner.io>, ebiederm@xmission.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2019 at 5:16 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Thu 11-04-19 07:51:21, Rik van Riel wrote:
> > On Wed, 2019-04-10 at 18:43 -0700, Suren Baghdasaryan via Lsf-pc wrote:
> > > The time to kill a process and free its memory can be critical when
> > > the
> > > killing was done to prevent memory shortages affecting system
> > > responsiveness.
> >
> > The OOM killer is fickle, and often takes a fairly
> > long time to trigger. Speeding up what happens after
> > that seems like the wrong thing to optimize.
> >
> > Have you considered using something like oomd to
> > proactively kill tasks when memory gets low, so
> > you do not have to wait for an OOM kill?
>
> AFAIU, this is the point here. They probably have a user space OOM
> killer implementation and want to achieve killing to be as swift as
> possible.

That is correct. Android has a userspace daemon called lmkd (low
memory killer daemon) to respond to memory pressure before things get
bad enough for kernel oom-killer to get involved. So this asynchronous
reclaim optimization would allow lmkd do its job more efficiently.

> --
> Michal Hocko
> SUSE Labs
>
> --
> You received this message because you are subscribed to the Google Groups "kernel-team" group.
> To unsubscribe from this group and stop receiving emails from it, send an email to kernel-team+unsubscribe@android.com.
>

