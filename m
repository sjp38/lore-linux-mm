Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19C38C43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 03:32:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C32CF20835
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 03:32:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="DDDpEVSR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C32CF20835
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 609B36B000E; Mon, 29 Apr 2019 23:32:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5BAAE6B026E; Mon, 29 Apr 2019 23:32:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4A9E36B0271; Mon, 29 Apr 2019 23:32:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2B9BE6B000E
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 23:32:55 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id q2so5859035ywd.9
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 20:32:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=dWEKtGsRIMq4v+NhZemcUNWB8/vTGODLsuHGIZCvLns=;
        b=Hn3+QWVzqurdJdVL8hnwHbrgTFCLxImV/owGkbvkHlaSh776C4/Lua54Rg/mPtl5jn
         zfjf1TTk2zfSpdw5pVhKtsw9rdXh+Mr5M6/P/XOKMYZmli6EfzikFq4t2j9e/yaCjEMQ
         b5ytkoKforAglIqMNrFbI0bHg6CcjrLETJdH1JdbHtWpPj2vKjiYTlTGNKgD6ZwfC2/j
         d1LRslCpEF0r66nbUIQFGsWu4lt+tTUgam1x0MH9Bsz0EY0VdAIpO0wCNz/Qj+97mbcm
         ygRJ2HnIwrX5s1Z/LDt7bPtoLDR0zZow+EDpHScOGAjhXj1bqdcqyBTiktvPlfyzxywu
         Q6cg==
X-Gm-Message-State: APjAAAX5/bN1ViGbCIf0tR4IPcmjGbQwGppA1QOyi9Xy5kALeVnC45qH
	gc809v//yOuAE5V+7Ih+28SyKwK6h3yPeIDyBfP/fZPVgIpLQgqH2ldONOaXKgVjlq8F1JIwkxA
	rLJoyXSyDJOQ4ap3T3hFfBVvof0akitwycLqIoaM5rMPrYFFs7b6oR4e6YBaifg0f9w==
X-Received: by 2002:a25:6307:: with SMTP id x7mr53344153ybb.105.1556595174891;
        Mon, 29 Apr 2019 20:32:54 -0700 (PDT)
X-Received: by 2002:a25:6307:: with SMTP id x7mr53344112ybb.105.1556595174265;
        Mon, 29 Apr 2019 20:32:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556595174; cv=none;
        d=google.com; s=arc-20160816;
        b=SeCF9hjVdELn2Ah0yd0PsopZtGl9hMDS7sMYKnypp8+drYGSLleWdMQ9IM8BUUrSYQ
         HYrdXaY82+Xj+ZLDJhLseSMfbP9qtZ3Ue7a/sRiS7OLGcpzSHnCBAD7xKW7uVSAPqVe4
         mzWdtJdBJ8XiVv/oiIrc18dYZUHQHL1NA+jzxyYqg4oyXsmzHlM2K90z/Qfgpds/bMqq
         eGzjKFlx44VBmMswp/xXz3Lk+jDMujYAWfR0sHbNcASMqvyput22+JUKHsKiEyllz6Iy
         74mRitHYknMkQXNUvWDfS2jgttJPzxD4Y+FUSfgb+cmGG2orjcmxx4lnmmQB7Es9bdLM
         9LKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=dWEKtGsRIMq4v+NhZemcUNWB8/vTGODLsuHGIZCvLns=;
        b=O6tI4uDbPcbzq3nPo9UKn1+WO3yl0Ns3bTEu3B6XajWyZNg0bB7hO1tSIA9FuixH8K
         cqkhl3RbvHRlSfndGssX5Yo9DC2N0ze1oNRtUjO4exvfctGePrC83xohhAW9CBjuQoH+
         acKptQj0srgJLnLujfpbtXKGUKM/yUjp9GBjLlr5NnOrAQ4ewGInBhEu0Qy0yvdogxz2
         T9+DfOJrS+ye0GPS04EZwbt3LSb2+sVGRes94LzUyjz0FRjGF4JFRNzT4uWyOcRg18l6
         HsXrh+aVq4c1Qe7bPpSGf3iUZqMOp0wxn5f3ENS/IGXDfMo53eNNZ5GYH011+FHZRPS3
         TzAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=DDDpEVSR;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i125sor4270476ybi.169.2019.04.29.20.32.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Apr 2019 20:32:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=DDDpEVSR;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=dWEKtGsRIMq4v+NhZemcUNWB8/vTGODLsuHGIZCvLns=;
        b=DDDpEVSRE8oPO+cOinkkQ7lINMkV8y8Sp8Tp7Uttz0QF6r5bQ6+/3ePMNmPLDpz7rI
         KPala0XBYAmQ3SePPZ40hYTg86geNQPy2Grc0K4z4RE6whwqluCHezd1NGgB6rfucnUg
         hV0HXKuk9r2hCL9OuhfjFrDv44ufG3YiG18/uldGmxv/21HyO0kCQVr3yLGsWLB7fOC3
         SkopmmTFkLYAnVdS9QIFL6GJf2lX9LAxqwQPzB+5TwzDX+vkYdax3NVP1fpz6XxoBOlo
         7+1lZvseE7ID/p1TWU21NN5jMaEzewo6ONCu/nBDNYNpYsDUS9LKTnK702xr83iKOnNl
         XqIA==
X-Google-Smtp-Source: APXvYqxiTSC6H3uYqE0DoAstpjwFGHHohchbO4x8XQqIAb6J5UkRzE8VEEfSYh/QD37Z8jEdNZRckmYBonsmWkkAg2k=
X-Received: by 2002:a25:f507:: with SMTP id a7mr52256523ybe.164.1556595173714;
 Mon, 29 Apr 2019 20:32:53 -0700 (PDT)
MIME-Version: 1.0
References: <20190429171332.152992-1-shakeelb@google.com> <20190429171332.152992-2-shakeelb@google.com>
 <20190429214123.GA3715@dhcp22.suse.cz>
In-Reply-To: <20190429214123.GA3715@dhcp22.suse.cz>
From: Shakeel Butt <shakeelb@google.com>
Date: Mon, 29 Apr 2019 23:32:42 -0400
Message-ID: <CALvZod5uXOQfeq9_03T5dv104tWwuukL0+vEAVhk-v1_A=skQQ@mail.gmail.com>
Subject: Re: [PATCH 2/2] memcg, fsnotify: no oom-kill for remote memcg charging
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Jan Kara <jack@suse.cz>, 
	Amir Goldstein <amir73il@gmail.com>, Linux MM <linux-mm@kvack.org>, 
	Cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 29, 2019 at 5:41 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Mon 29-04-19 10:13:32, Shakeel Butt wrote:
> [...]
> >       /*
> >        * For queues with unlimited length lost events are not expected and
> >        * can possibly have security implications. Avoid losing events when
> >        * memory is short.
> > +      *
> > +      * Note: __GFP_NOFAIL takes precedence over __GFP_RETRY_MAYFAIL.
> >        */
>
> No, I there is no rule like that. Combining the two is undefined
> currently and I do not think we want to legitimize it. What does it even
> mean?
>

Actually the code is doing that but I agree this is not documented and
weird. I will fix this.

Shakeel

