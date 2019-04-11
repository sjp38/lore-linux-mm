Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1744AC10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 17:33:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B6B312084D
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 17:33:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="dkPzNjXO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B6B312084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3EF886B026D; Thu, 11 Apr 2019 13:33:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3A0196B026E; Thu, 11 Apr 2019 13:33:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 28F896B026F; Thu, 11 Apr 2019 13:33:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f69.google.com (mail-ua1-f69.google.com [209.85.222.69])
	by kanga.kvack.org (Postfix) with ESMTP id 001A46B026D
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 13:33:46 -0400 (EDT)
Received: by mail-ua1-f69.google.com with SMTP id 63so855090uat.14
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 10:33:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=OSeB4tqmSiQUf8xagvhoDocOkuTqy8cOj2EPyNoK+Hk=;
        b=ZmoLiz9nNuwygZUNiysX7Z0xXGtwEnkT36xeGGJzU0hwvOytno6l9JTnD+SG7R3Xjf
         iGGAyl1pnbafh2/dg55bzd2hyeHd11RHGxXKc3fpOu31tWMuN6t2uwb3vb+kNP9FrNew
         KNr17+n2wPm9kIQho8u4LnCwtk1JClUygCrYSdR2EmYFSrT8fRXNO3CDtOsKPfQ+mYYq
         K1rRxL8cz7tJvUT9Q4e1wivydo9oD+vLYKdkf4487btZmGANKkhdxZWQB+YF5XG7FgBQ
         OmThuzoZ5AG37/67ug7Pa3fYjrbvUisZiZ5e4RCZ0DV0w2LwB+KFb7/cdGFWkf9Ngs6a
         sX0w==
X-Gm-Message-State: APjAAAV+A/QOzAzsSPB1PbSzCFh910nQ0axe1PMLS8P7Y64CRZthaLbr
	b9hc0o5o/yNw4NrXdGfcM4XKhET1wKS0nBbqlbnsJEtBkicwFng4+UCMPcIeITGBGcpACnFfULz
	9gAeVwzebhhobst7YciDo2SoyHxO/wMnAsCeCTgszb9HIYOjyCbDSm9cOYFQVVM8OvQ==
X-Received: by 2002:ab0:20a6:: with SMTP id y6mr4034614ual.98.1555004026619;
        Thu, 11 Apr 2019 10:33:46 -0700 (PDT)
X-Received: by 2002:ab0:20a6:: with SMTP id y6mr4034588ual.98.1555004026035;
        Thu, 11 Apr 2019 10:33:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555004026; cv=none;
        d=google.com; s=arc-20160816;
        b=Id8QtKWL50wDxiZq9ui4FFTVG68cJO4TNOADuGEX9v4QO+MEMJFqUsy9CNSOgui82Y
         v6mMJyWkZzs0HJb9a842qtmUyPw/StAYL7DFsVsrdqruZGLkFlY5RIlqZXnzV5YwyzNg
         uI/Pi+SGsHGNYisun4pv7lFFyE+gGOmeUpBeVkuUhba9o3q8aZ6OlQdlgaiwp+V74ymb
         UR4bemlL+2599nx66/5dz6JEPsFwN2o/BRdupU5cYeEwllOtNWAsXtu1mDSS3TrHpQxx
         nvxV2WGUuXyhO7l1l3hiKUK++s3BR7MQjImbF8IXTHAvjFEIvPey1pp20kLyPPewsa3e
         38Cw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=OSeB4tqmSiQUf8xagvhoDocOkuTqy8cOj2EPyNoK+Hk=;
        b=ofP2N0f3c59CdcSa9NLovpzHvGwRar/WWgaOy0dtY+aMQjTxG9FnxKn2QtcGUMd/CP
         kuofNo4EA8aoJKIb0/9pEbJKzcafnh98fWBIfAemEkuL0KLbAYmu/8rAfz0O8TlnPWTm
         LW3wOO6LjWA2E9coGW6XeiEZdbWel+qAlnNFPKsKGTbVjdjI9Ps8kc605dVgdc4MFkLr
         6grtA0hH63zhF+Y+Xcs4pkWGKF6Qul6GUEkr1tj3xKaVaD9nKI3Ck6HQxXp7+GlNNB4w
         95Hrp9BsrrvPCFKBOqxWunrkd+D1hcxnPxXaxss5DDdw0Rpb4By3QHh3jARx8hfQLIsG
         Ue7w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=dkPzNjXO;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l16sor17011946uad.37.2019.04.11.10.33.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Apr 2019 10:33:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=dkPzNjXO;
       spf=pass (google.com: domain of dancol@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dancol@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=OSeB4tqmSiQUf8xagvhoDocOkuTqy8cOj2EPyNoK+Hk=;
        b=dkPzNjXOPXQj+xsCF+38A/HaY6qh0VHusVhAJKzysy47FbNOhUUCIcbwMydUH/VcZQ
         xreBFmJY6sDonha4AADF2FbS3h+SgPFvzvSs+PHAAcTEHIbJn9kqveFOtA9RcplWKd14
         lYxptEgekXVtBHwpDoalLAK3qtKwsItHBa9NyZ/MaJj6UoYmNAjWlwbVPzOb1lX8qie5
         i++9R1GRweh3laQur+vNb29rB0E8zRVJjyF3KfYxGH302nAAAJcboqi80HRvJ6Yf/yE6
         EL+xH3ITdEoKNtoQQcPwilYKEvWXaeoW/7txYVxkVLOexAiCr3feFP4UAP0bDQDG1/Tu
         FAww==
X-Google-Smtp-Source: APXvYqxqDK+UTWOrRe6VZKjRV9FXctB6pwjbwfPyvjf+G7uJso/BwQnnEQ9arJ5o/fbzju80DfACs+85KGLVnqMuDMw=
X-Received: by 2002:ab0:3b8:: with SMTP id 53mr4991933uau.118.1555004024530;
 Thu, 11 Apr 2019 10:33:44 -0700 (PDT)
MIME-Version: 1.0
References: <20190411014353.113252-1-surenb@google.com> <20190411014353.113252-3-surenb@google.com>
 <20190411153313.GE22763@bombadil.infradead.org> <CAJuCfpGQ8c-OCws-zxZyqKGy1CfZpjxDKMH__qAm5FFXBcnWOw@mail.gmail.com>
In-Reply-To: <CAJuCfpGQ8c-OCws-zxZyqKGy1CfZpjxDKMH__qAm5FFXBcnWOw@mail.gmail.com>
From: Daniel Colascione <dancol@google.com>
Date: Thu, 11 Apr 2019 10:33:32 -0700
Message-ID: <CAKOZuetFU4tXE27bxA86zzDfNSCbw83p8fPxfkQ_d_Em0C04Sg@mail.gmail.com>
Subject: Re: [RFC 2/2] signal: extend pidfd_send_signal() to allow expedited
 process killing
To: Suren Baghdasaryan <surenb@google.com>
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, yuzhoujian@didichuxing.com, 
	Souptick Joarder <jrdr.linux@gmail.com>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, 
	"Eric W. Biederman" <ebiederm@xmission.com>, Shakeel Butt <shakeelb@google.com>, 
	Christian Brauner <christian@brauner.io>, Minchan Kim <minchan@kernel.org>, 
	Tim Murray <timmurray@google.com>, Daniel Colascione <dancol@google.com>, 
	Joel Fernandes <joel@joelfernandes.org>, Jann Horn <jannh@google.com>, linux-mm <linux-mm@kvack.org>, 
	lsf-pc@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, 
	kernel-team <kernel-team@android.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2019 at 10:09 AM Suren Baghdasaryan <surenb@google.com> wrote:
>
> On Thu, Apr 11, 2019 at 8:33 AM Matthew Wilcox <willy@infradead.org> wrote:
> >
> > On Wed, Apr 10, 2019 at 06:43:53PM -0700, Suren Baghdasaryan wrote:
> > > Add new SS_EXPEDITE flag to be used when sending SIGKILL via
> > > pidfd_send_signal() syscall to allow expedited memory reclaim of the
> > > victim process. The usage of this flag is currently limited to SIGKILL
> > > signal and only to privileged users.
> >
> > What is the downside of doing expedited memory reclaim?  ie why not do it
> > every time a process is going to die?
>
> I think with an implementation that does not use/abuse oom-reaper
> thread this could be done for any kill. As I mentioned oom-reaper is a
> limited resource which has access to memory reserves and should not be
> abused in the way I do in this reference implementation.
> While there might be downsides that I don't know of, I'm not sure it's
> required to hurry every kill's memory reclaim. I think there are cases
> when resource deallocation is critical, for example when we kill to
> relieve resource shortage and there are kills when reclaim speed is
> not essential. It would be great if we can identify urgent cases
> without userspace hints, so I'm open to suggestions that do not
> involve additional flags.

I was imagining a PI-ish approach where we'd reap in case an RT
process was waiting on the death of some other process. I'd still
prefer the API I proposed in the other message because it gets the
kernel out of the business of deciding what the right signal is. I'm a
huge believer in "mechanism, not policy".

