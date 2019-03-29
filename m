Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B183DC43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 15:08:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 755372184D
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 15:08:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 755372184D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0043A6B000D; Fri, 29 Mar 2019 11:08:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EF4D56B000E; Fri, 29 Mar 2019 11:08:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE4436B0010; Fri, 29 Mar 2019 11:08:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id BA18F6B000D
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 11:08:53 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id n10so2506349qtk.9
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 08:08:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=Op0S9e4x5Kscr7h7eXmRDVk/JsCI4DJblah3z5xAD5s=;
        b=gPmO2eyI1qm3bzFv2LrcYd2gvjt84XvaFCgdUK2lQkN4IY8ubmUt+InjrU6zKE8St4
         CfRAMtJiyF5EDjnmh8TmMt+rq7n2wx2JorvaBc5K/E08Y2sYiEBJNwIY7VZunuHAIK5C
         qCrC3R0zIsctJ56ejmdKEXuA1MlPyEYejN148aeGm7/bUjMHtvI+uCqRIEyKacvHnvow
         nJhYHRwTYwkrzxg6AMi3VkyzFe6T9DCivB+ztSpr/4PPAzUZRQ5RAI/S7yevHie7H0wD
         ZTBcTjiriebKfhYluVRHv5grNDMlwFYhZICvd/LucVwO2o6J3zcYP8idzGA5KG7eOWr9
         LwfQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUxnEK4Zr4BEtaHykwM9Fs5NGNti208h1efFLInEe4ylVxQJbDo
	NbHKJExFouVRCZoxdd9ukP3UU6InO1vD44RhVZXggfnXVT0l0UU40H+3peLJ1DlFHwztigA8KDa
	7UAZL85hidmcPh0Zjwb0jPesU6HftY/YwRdlarbJrtW1mwxp9jvO+DIVFLvmwydjGZg==
X-Received: by 2002:ac8:65c3:: with SMTP id t3mr41312952qto.12.1553872133334;
        Fri, 29 Mar 2019 08:08:53 -0700 (PDT)
X-Received: by 2002:ac8:65c3:: with SMTP id t3mr41312890qto.12.1553872132547;
        Fri, 29 Mar 2019 08:08:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553872132; cv=none;
        d=google.com; s=arc-20160816;
        b=kXIeREMy0/rWvh7JOtkRyQ5/EGJXn1KoPt4nIxejifq8azkUjMY+0lHWR+u0i4TxwK
         TwBmATCBuRyu8fU2mdKudWn/4a4vZVyMfJxKD+YkGFxnaAO2JmGPwoTBw7hjnTzsyeqb
         ZeK5CLGq9ysYCuzq50j1TcicMHwO+3UdrnjJQC8y/XXwolsYkondfHRPZrUsJcIuamGU
         E2uYBbuVEzSb710GYcu9j4WS24JC0XEW9BGvFyZfYJNRx+7lsp0Fc3oIEYXd71ssm1HT
         FZ8Yw/O3so0ENjEhJA4O5NRwfSK27J22n1XWiyxseuqbgKc9CPw6Stlbk4iYd4tVIOVr
         eblg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=Op0S9e4x5Kscr7h7eXmRDVk/JsCI4DJblah3z5xAD5s=;
        b=Yh4fMZ2h0D0HjJ+f2UCfe0M3+0lx71tkkIYr8tdcI3q58kybAEW4hF+Ohi/UKo5Za3
         7lbj39hBDo6/SlFia5sDg8ENUnzH2my6lXyy4pW8ooe+0HDRDU7hRbMKZEpB8MwMS5lL
         k1+5Ly2mG4FHyyw3exLr0s1gZswrUyS96UbbnzRlMQfmPkf6z7ZYfcdgjWW1tmh17JNX
         ji7iEe6g7Dlr3wE25PyRMXkPxFc1+kLYHolC5EE4ci/bDVuyTv0uhdKaIqyd0h+JbHa9
         hKYreKpoV5OJSNtIt3/5stsVDaM1jKbchKXdtoi/JG8CD8lH+EOWJ6o5QxWVjLtvgf/v
         kw+A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 32sor2905483qtv.24.2019.03.29.08.08.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 29 Mar 2019 08:08:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqwSURTkVA80rMos1Y/SrKKWTM65DCM27okuf26x0TIA02J8JpidaqJbyIfkHE4PLF309IdXWA==
X-Received: by 2002:aed:3f49:: with SMTP id q9mr41973253qtf.279.1553872132003;
        Fri, 29 Mar 2019 08:08:52 -0700 (PDT)
Received: from redhat.com (pool-173-76-246-42.bstnma.fios.verizon.net. [173.76.246.42])
        by smtp.gmail.com with ESMTPSA id k41sm1846322qtc.89.2019.03.29.08.08.49
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 29 Mar 2019 08:08:50 -0700 (PDT)
Date: Fri, 29 Mar 2019 11:08:43 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: David Hildenbrand <david@redhat.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	pbonzini@redhat.com, lcapitulino@redhat.com, pagupta@redhat.com,
	wei.w.wang@intel.com, yang.zhang.wz@gmail.com, riel@surriel.com,
	dodgen@google.com, konrad.wilk@oracle.com, dhildenb@redhat.com,
	aarcange@redhat.com, alexander.duyck@gmail.com
Subject: Re: On guest free page hinting and OOM
Message-ID: <20190329104311-mutt-send-email-mst@kernel.org>
References: <20190329084058-mutt-send-email-mst@kernel.org>
 <f6332928-d6a4-7a75-245d-2c534cf6e710@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f6332928-d6a4-7a75-245d-2c534cf6e710@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 29, 2019 at 03:24:24PM +0100, David Hildenbrand wrote:
> 
> We had a very simple idea in mind: As long as a hinting request is
> pending, don't actually trigger any OOM activity, but wait for it to be
> processed. Can be done using simple atomic variable.
> 
> This is a scenario that will only pop up when already pretty low on
> memory. And the main difference to ballooning is that we *know* we will
> get more memory soon.

No we don't.  If we keep polling we are quite possibly keeping the CPU
busy so delaying the hint request processing.  Again the issue it's a
tradeoff. One performance for the other. Very hard to know which path do
you hit in advance, and in the real world no one has the time to profile
and tune things. By comparison trading memory for performance is well
understood.


> "appended to guest memory", "global list of memory", malicious guests
> always using that memory like what about NUMA?

This can be up to the guest. A good approach would be to take
a chunk out of each node and add to the hints buffer.

> What about different page
> granularity?

Seems like an orthogonal issue to me.

> What about malicious guests?

That's an interesting question.  Host can actually enforce that # of
hinted free pages at least matches the hint buffer size.


> What about more hitning
> requests than the buffer is capable to handle?

The idea is that we don't send more hints than in the buffer.
In this way host can actually control the overhead which
is probably a good thing - host knows how much benefit
can be derived from hinting. Guest doesn't.

> Honestly, requiring page hinting to make use of actual ballooning or
> additional memory makes me shiver. I hope I don't get nightmares ;) In
> the long term we might want to get rid of the inflation/deflation side
> of virtio-balloon, not require it.
> 
> Please don't over-engineer an issue we haven't even see yet.

All hinting patches are very lightly tested as it is. OOM especially is
very hard to test properly.  So *I* will sleep better at night if we
don't have corner cases.  Balloon is already involved in MM for
isolation and somehow we live with that.  So wait until you see actual
code before worrying about nightmares.

> Especially
> not using a mechanism that sounds more involved than actual hinting.

That would depend on the implementation.
It's just moving a page between two lists.


> 
> As always, I might be very wrong, but this sounds way too complicated to
> me, both on the guest and the hypervisor side.

On the hypervisor side it can be literally nothing if we don't
want to enforce buffer size.

> -- 
> 
> Thanks,
> 
> David / dhildenb

