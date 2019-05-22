Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3706FC282CE
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 13:49:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0616020863
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 13:49:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0616020863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8EC026B0005; Wed, 22 May 2019 09:49:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 876966B0006; Wed, 22 May 2019 09:49:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 764596B0007; Wed, 22 May 2019 09:49:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 250916B0005
	for <linux-mm@kvack.org>; Wed, 22 May 2019 09:49:39 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id r20so3743801edp.17
        for <linux-mm@kvack.org>; Wed, 22 May 2019 06:49:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=lghwV3DZCdQQVwKep3uKuy6OHwR31uW6Z4jXaPn6QmM=;
        b=dI+ZgT/oiZNH90tdZGvUQGUErRiJmwfJrMftY1oqZMvVYIf9DNmGEK76bVpf/IJGhp
         8bYg88Jd9xJYPG9eLqnIMwm4R2FWQaNqEmiHuQdzqDUwtOBvDJoFOyDMnTb6ypgZlCdX
         0XvVXC6weVx/f/xYz0813SPF12TOqSaG06JSNNWs8IYl0Hw+HRjxgRwhdx7ZXp0paRPM
         e+0Xj0tZbXi6yy2YUqeaIgWcXpQGlvadHxJXIw0kl1rshXqVaB83cbJzGUbtrR6FLyeI
         AXhvJd6qF8vMYOMFzmsW4/iumYE6p9jcf/mO9oObpfxtWNW3jLnYT/oymM3s4+XUvuXE
         BugQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
X-Gm-Message-State: APjAAAWKW2LOOTKeIMuweKO3/WHDY8DaRBY8ZwDXUvYDOLpUBNfiPRBN
	14ifD/jq2s/3e8g5GONfbr3ZIl9Knd1RcToZTCUdqigr/+dXKWF2XOo95QXbqWOR3D+d0FBbO7P
	5oQSAVYtQoMGaCDlZE0oviQl4I/V0s4zTQ7upiLoWb2wTYUuElKuJrIxAM9WGjFypSQ==
X-Received: by 2002:a17:906:1483:: with SMTP id x3mr39851861ejc.90.1558532978697;
        Wed, 22 May 2019 06:49:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwDq4nbfSlDnhDPtR4q+ZLl6gGARSGscuFj54ruFzKS+iwJLntUB+iD2RQC/LOV5m/1Mdoy
X-Received: by 2002:a17:906:1483:: with SMTP id x3mr39851790ejc.90.1558532977680;
        Wed, 22 May 2019 06:49:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558532977; cv=none;
        d=google.com; s=arc-20160816;
        b=spa5AZHAn25vj1ktzKyqr3iXxbQ+TcrtJGp/p/j/kxxCVGV9ojDj0F+XfLipHA4DpU
         Wf/Xulhips1AK4yq2xs/brdjAMbSkF+CvoPENUViC+pfP3o2CIZmonDOLp6WSIyqs/qN
         0GbtyHpTKyBo8LYqDMe+ozZu3r4kB+ydb9MFPoflpxGddhD5jgWOSNToIyslbMNGFV2V
         e+Jg81c22wzV5J1vSDK3B1PC3XXNDj4yaza7J1jRZ134FzmSUBYUxtsDvGey6fVuS7yo
         sO3Q7tBfbKnjROlhO2YoIdsoAh25sMGsTrucJ7CV/Qkhd3ry9zyuzuEreILinE6GXYtj
         3ypA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=lghwV3DZCdQQVwKep3uKuy6OHwR31uW6Z4jXaPn6QmM=;
        b=l6LgsLly0w6hu3XhtEn2iJYKHsi07x00rh6uad97JFq/UivW/eWowyEJ5DvdeKp5Qn
         kzDMPsBvFBXdIZ/+ZDE+hpGt70aGAmw/bJNGRIJYw6THvkjtX6IUJ18HxEL7Uc86tlv2
         fRmVxzc1cKlwZj5TK5xSgae8SW51xyCKJYqy28FylyowOlQAmMsY+kGNSCW9Io39yDu6
         eMR8vN218aVr5cnON6yj5ouAaJUqsnA7GZ8lQvJl0VfWKCHohw0lMOIUYX+CmU1wxamC
         PkWH7nPBPanaVgXs+T5FTtcF/u3Qrvp+rOTRqASXptBN8Gv3XZJsoEAn8GhRVO5sKVh5
         IGiQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id j17si3143458ejv.3.2019.05.22.06.49.37
        for <linux-mm@kvack.org>;
        Wed, 22 May 2019 06:49:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.martin@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=Dave.Martin@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 5198E80D;
	Wed, 22 May 2019 06:49:36 -0700 (PDT)
Received: from e103592.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 94CFA3F575;
	Wed, 22 May 2019 06:49:30 -0700 (PDT)
Date: Wed, 22 May 2019 14:49:28 +0100
From: Dave Martin <Dave.Martin@arm.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Catalin Marinas <catalin.marinas@arm.com>,
	Mark Rutland <mark.rutland@arm.com>, kvm@vger.kernel.org,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>,
	Will Deacon <will.deacon@arm.com>, dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org, linux-kselftest@vger.kernel.org,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Leon Romanovsky <leon@kernel.org>, linux-rdma@vger.kernel.org,
	amd-gfx@lists.freedesktop.org, Dmitry Vyukov <dvyukov@google.com>,
	Evgeniy Stepanov <eugenis@google.com>, linux-media@vger.kernel.org,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Kees Cook <keescook@chromium.org>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Alex Williamson <alex.williamson@redhat.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	linux-arm-kernel@lists.infradead.org,
	Kostya Serebryany <kcc@google.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Yishai Hadas <yishaih@mellanox.com>, linux-kernel@vger.kernel.org,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Lee Smith <Lee.Smith@arm.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Robin Murphy <robin.murphy@arm.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Subject: Re: [PATCH v15 00/17] arm64: untag user pointers passed to the kernel
Message-ID: <20190522134925.GV28398@e103592.cambridge.arm.com>
References: <cover.1557160186.git.andreyknvl@google.com>
 <20190517144931.GA56186@arrakis.emea.arm.com>
 <20190521184856.GC2922@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190521184856.GC2922@ziepe.ca>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 03:48:56PM -0300, Jason Gunthorpe wrote:
> On Fri, May 17, 2019 at 03:49:31PM +0100, Catalin Marinas wrote:
> 
> > The tagged pointers (whether hwasan or MTE) should ideally be a
> > transparent feature for the application writer but I don't think we can
> > solve it entirely and make it seamless for the multitude of ioctls().
> > I'd say you only opt in to such feature if you know what you are doing
> > and the user code takes care of specific cases like ioctl(), hence the
> > prctl() proposal even for the hwasan.
> 
> I'm not sure such a dire view is warrented.. 
> 
> The ioctl situation is not so bad, other than a few special cases,
> most drivers just take a 'void __user *' and pass it as an argument to
> some function that accepts a 'void __user *'. sparse et al verify
> this. 
> 
> As long as the core functions do the right thing the drivers will be
> OK.
> 
> The only place things get dicy is if someone casts to unsigned long
> (ie for vma work) but I think that reflects that our driver facing
> APIs for VMAs are compatible with static analysis (ie I have no
> earthly idea why get_user_pages() accepts an unsigned long), not that
> this is too hard.

If multiple people will care about this, perhaps we should try to
annotate types more explicitly in SYSCALL_DEFINEx() and ABI data
structures.

For example, we could have a couple of mutually exclusive modifiers

T __object *
T __vaddr * (or U __vaddr)

In the first case the pointer points to an object (in the C sense)
that the call may dereference but not use for any other purpose.

In the latter case the pointer (or other type) is a virtual address
that the call does not dereference but my do other things with.

Also

U __really(T)

to tell static analysers the real type of pointers smuggled through
UAPI disguised as other types (*cough* KVM, etc.)

We could gradually make sparse more strict about the presence of
annotations and allowed conversions, add get/put_user() variants
that demand explicit annotation, etc.

find_vma() wouldn't work with a __object pointer, for example.  A
get_user_pages_for_dereference() might be needed for __object pointers
(embodying a promise from the caller that only the object will be
dereferenced within the mapped pages).

Thoughts?

This kind of thing would need widespread buy-in in order to be viable.

Cheers
---Dave

