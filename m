Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E88FCC10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 17:09:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A6E9C2082E
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 17:09:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="RuVYDtl/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A6E9C2082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 476AF6B026D; Thu, 11 Apr 2019 13:09:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 424DD6B026E; Thu, 11 Apr 2019 13:09:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 33D1B6B026F; Thu, 11 Apr 2019 13:09:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id DAD4D6B026D
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 13:09:19 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id f67so4416945wme.3
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 10:09:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=8IUsO6EPkitkkKfslQlrk9jdhyI8ls4f5Jkizx1ufco=;
        b=BScqMVR1ewRrkt/CuGTHFBcB+RoSLhqJnNxlJkfcs3R7H3BdsH/ZIjlrEFmbfdF+Bz
         9NpG8Y6nBfzCvZ2JiTEfUjdKqt9reHmSNOGMU9ffv40W3PtSL+gnkidaNBKefw5LrPZx
         IRMyuzX5wf1dbEomBtmmHCHOlC50FVwbl1Nn+czdvVr6yqDKdZfe0Wzv4zypn8bWqq6S
         t+Sa8b1xOuXXCLreQbEuvIcQUwuwMz0daokF0STwyPNCZ8VmrGN4DCklojmlVizDQ6IZ
         gfXvhFJ4IHouclYHiqZ+tRYhTDzELGpIGMtZ1YNJXvbKhsvIRy/FSLIzL2BJAEdP2of0
         acRw==
X-Gm-Message-State: APjAAAXDG+C/2oVuDlbMvQy0iFofnzuagXHfJEiHPDzTf33mhDqFeGcC
	42BWcwOcUzOMfueYjxCUq5uPqb+/HgKTMDcr9LdNKvGvAMPsNCmpiJIRcS1/+DnWIdogS4VE74z
	8VzxacijDvWSkldIamXe/tqSedaBqkhVpkKFylaMq7/TtXYZixQOnjhxloe0Ltm7mig==
X-Received: by 2002:a7b:c111:: with SMTP id w17mr7479279wmi.6.1555002559465;
        Thu, 11 Apr 2019 10:09:19 -0700 (PDT)
X-Received: by 2002:a7b:c111:: with SMTP id w17mr7479243wmi.6.1555002558725;
        Thu, 11 Apr 2019 10:09:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555002558; cv=none;
        d=google.com; s=arc-20160816;
        b=cTDwzDhwSV++az2192lvVaoxCNG/rAORtDXcJIJ77bDE9vfrcwy5VHPZl3bjsn7KuY
         ovMUs1j6Sz9QmzqAwq0Sb9FSVuDe2XHfBa/4e0T0udPq6iTRP2YbLaAFwIjDTaTVuXSy
         vBAEc3Fe8+Yo3LNBYAEShX0dC3CiqPkPxMv2pqO2BvMWRHytBaGY9fVD6BeKRviKHRnQ
         9Mafx84x4aCkGshDb1ycnXNRA+sE5exlB+SlToiBcl22aa9vWK9fJq6UPeq+koEzo26g
         5sm52mJy0b48Zz4qOn74gGbv9PfoZFEbUsDa7XpSOQLiroQUPVMqIy/Ymygf6Y6ym2Ri
         yrkg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=8IUsO6EPkitkkKfslQlrk9jdhyI8ls4f5Jkizx1ufco=;
        b=FLw7NtELjc3rmSwe7EdrOA+sFyAoC2cjMqeUWFOI9aDLmPA7RBsXfYVAEXyCFFX/Wu
         IHBGpaJBYhlWRuSwytOZDQ3Ebr4W5q+GJY2Pl3KKXhB7hRGTo9sKHqeO5xjOXF/UXmFL
         sdhS3F+CLsJIz7EwdPyL0Wjo1g4+IcikjwYYkYK0vWSWQmP/maTY9K/lsd5QimGTTe15
         4ik8e0jjXLifbbB5lmN0x9B6mIJ0ZIZz71Ftqq41WVFuysMNTjM7lKpwf7R2s6Ye/tnz
         H2u+RxQUlhwZUpVDlr7y6CveEtMGXBMQRe7v4TXoBuxugA3pUTeRsj+v7VUqqvesKTRP
         0tBw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="RuVYDtl/";
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t25sor4196465wmh.10.2019.04.11.10.09.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 11 Apr 2019 10:09:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="RuVYDtl/";
       spf=pass (google.com: domain of surenb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=surenb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=8IUsO6EPkitkkKfslQlrk9jdhyI8ls4f5Jkizx1ufco=;
        b=RuVYDtl/y7612dj4+IKeQW/slL0xo/AO6Znlwf7Hk3P2RrSWmjQpRS6ixXs2G8hWnM
         5vNuGTVOdUPuWKgMoRIQuxNiBv180LSi9UhCLLCvBuYRUxBZU7hgts7AytfwciBQfvID
         jNGtv1XyjoNg3XEeUO4Lm+sNUnngJXrgwttFghcHeGnyP7g3J54xsvTnfdAXR7TSq13V
         /eHOw3id/WZuF8E0KF/QLG4QrEmm8VM0Pt/cWI3F5or+WfokXQI5ztNCx5QllAG4A8C1
         /XUA0jFNJ7OFtjlKRcbiK+3MEx7G65bNVtOWntS+GPkswQlfwl03iFmFUz0AI42MD7NW
         ErQA==
X-Google-Smtp-Source: APXvYqxCOHI/Gb4CSvdUX/vm83ezHcctTmbLcpiwE5HrPevLzsRkqOTIvPC7LtxSX6FYCDdaSzHtCjw1Y83jhMor1P0=
X-Received: by 2002:a1c:c00b:: with SMTP id q11mr7791999wmf.38.1555002557981;
 Thu, 11 Apr 2019 10:09:17 -0700 (PDT)
MIME-Version: 1.0
References: <20190411014353.113252-1-surenb@google.com> <20190411014353.113252-3-surenb@google.com>
 <20190411153313.GE22763@bombadil.infradead.org>
In-Reply-To: <20190411153313.GE22763@bombadil.infradead.org>
From: Suren Baghdasaryan <surenb@google.com>
Date: Thu, 11 Apr 2019 10:09:06 -0700
Message-ID: <CAJuCfpGQ8c-OCws-zxZyqKGy1CfZpjxDKMH__qAm5FFXBcnWOw@mail.gmail.com>
Subject: Re: [RFC 2/2] signal: extend pidfd_send_signal() to allow expedited
 process killing
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, mhocko@suse.com, 
	David Rientjes <rientjes@google.com>, yuzhoujian@didichuxing.com, 
	Souptick Joarder <jrdr.linux@gmail.com>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, ebiederm@xmission.com, 
	Shakeel Butt <shakeelb@google.com>, Christian Brauner <christian@brauner.io>, 
	Minchan Kim <minchan@kernel.org>, Tim Murray <timmurray@google.com>, 
	Daniel Colascione <dancol@google.com>, Joel Fernandes <joel@joelfernandes.org>, Jann Horn <jannh@google.com>, 
	linux-mm <linux-mm@kvack.org>, lsf-pc@lists.linux-foundation.org, 
	LKML <linux-kernel@vger.kernel.org>, kernel-team <kernel-team@android.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2019 at 8:33 AM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Wed, Apr 10, 2019 at 06:43:53PM -0700, Suren Baghdasaryan wrote:
> > Add new SS_EXPEDITE flag to be used when sending SIGKILL via
> > pidfd_send_signal() syscall to allow expedited memory reclaim of the
> > victim process. The usage of this flag is currently limited to SIGKILL
> > signal and only to privileged users.
>
> What is the downside of doing expedited memory reclaim?  ie why not do it
> every time a process is going to die?

I think with an implementation that does not use/abuse oom-reaper
thread this could be done for any kill. As I mentioned oom-reaper is a
limited resource which has access to memory reserves and should not be
abused in the way I do in this reference implementation.
While there might be downsides that I don't know of, I'm not sure it's
required to hurry every kill's memory reclaim. I think there are cases
when resource deallocation is critical, for example when we kill to
relieve resource shortage and there are kills when reclaim speed is
not essential. It would be great if we can identify urgent cases
without userspace hints, so I'm open to suggestions that do not
involve additional flags.

