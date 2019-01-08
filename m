Return-Path: <SRS0=RE7g=PQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0021BC43387
	for <linux-mm@archiver.kernel.org>; Tue,  8 Jan 2019 23:24:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 82F4F20665
	for <linux-mm@archiver.kernel.org>; Tue,  8 Jan 2019 23:24:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="ACC7emwD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 82F4F20665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F29FF8E009D; Tue,  8 Jan 2019 18:24:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED96E8E0038; Tue,  8 Jan 2019 18:24:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA1A08E009D; Tue,  8 Jan 2019 18:24:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f70.google.com (mail-vs1-f70.google.com [209.85.217.70])
	by kanga.kvack.org (Postfix) with ESMTP id B05DC8E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 18:24:30 -0500 (EST)
Received: by mail-vs1-f70.google.com with SMTP id a82so2327976vsd.19
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 15:24:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=9zeA7wPbvu4atpqM4sPM6IAShi6Cxo/Ri1A2df3T19k=;
        b=exw/iKDf19vMkj9saF3p8HI+Cj/BIWtk38SvxeJuwD1aOqY+X4jN8QNcJRnxS++G3/
         EiszKEV+qJfircZVpqLoFQcogATHfHVW6uZuAGRS2pjqtx5e/3+raTYWDweza/wVacdI
         4XPmKHt0jPb23hSU2AVnSV9fnugyRPq85LA0oUymLZRLkFvY7+kZ5lSWphZ5agzJIGO9
         GBoX2E5bjgEFKcNvViF9TW5nMcoMdS1iXxniCBV7ClR35RqQ3vJVoD70klwIUCoZDMVZ
         aCwCIVJSIkQdxaaLhOoJ/w4bk5Ka2zXjpfZwiF737gBPXKjYJab9steBptpJGECQ7pgD
         7D1w==
X-Gm-Message-State: AJcUuke6XP9+HozqbFAY6ylePqYCxotSuQ61xGvrP3pEDZCDQB1bI59W
	2wfbFO/2cP5LJHYr4j0v7x+s2x/YadUuKOzeshyErczp+ObXYRA+xOVrWPoGVxLxFhrLZjAZ7dP
	yffcR/yfKdwuBRjCMU77GfSSX5+9jcv5fe5q8/rcuv9+a/UOOK1mMt6ySrbaQKahYcXADpfahVp
	fQAlNdoFbgcFxLlB/vx9N38upo5I0Xh4F7rSLlOUIfiBolAYbhNVhlkykapR3hB00T7yJ8TCgLP
	7fnWdo4Gj9yax96qMJrHBYB4kv0JJDH9gs4KxftknzDKuzGmj/cx+kpqHvS2aERGM9jK2Aj28DU
	iw+LqSE6D0ptmA+UsnwOpOHIcsknAIthiDhAsQrNhSYhYZSUqotso2E2pt1QvzO3JLR1l5iy3ib
	D
X-Received: by 2002:ab0:13d3:: with SMTP id n19mr1317884uae.37.1546989868856;
        Tue, 08 Jan 2019 15:24:28 -0800 (PST)
X-Received: by 2002:ab0:13d3:: with SMTP id n19mr1317851uae.37.1546989866209;
        Tue, 08 Jan 2019 15:24:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546989866; cv=none;
        d=google.com; s=arc-20160816;
        b=nKIBuuM12Z+Ft0w5J2XUHfkenZ0hvPsqAce26bGxu+Wh7mA3LStEFBiWcj7muTlxEs
         CSZPEGh7SXv4JKzO1g3vdS0P/39Boovz7FakTLQgbCANUXacBR0yH3ryN60tn2xL27Y6
         0o2VimnVcZayJKSa6AiIlp3kYkduQlpFt0QMvaR0Z20Tcwsnp6onfGPx1nEKck/Jgydr
         oJOkIZSHVfJLiQEDxhW+QF5UYTCC+DHCBrPLujMPpb6xObRTv2i/r1ayW8pYaeJnUala
         6fJQ/12LOZP3ElX7kebcv34tfc0suIbkPYH+5utioOGbGd5BXZ75fuJ0bRaKWfoDRU44
         4vZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=9zeA7wPbvu4atpqM4sPM6IAShi6Cxo/Ri1A2df3T19k=;
        b=XB8UA/JDXs36t+2K67/jAoElvFvVfd/DOP/Yk8f+RIv8iiggiBxqdQM/5PxNirp0z/
         WnU9kXe/aLyccCeDL1osrBnkeey5Y9Vl/iJPj5Btr8rW0xrjMK5UmUY2eIwiK35B8tZk
         n5T/p32TQ5o9LpRdxD9uvC1xHWgBGDVv+RpotnREUfWOl/1GAPy2mgi2y1uzDgcYb84b
         5KB6PFt4odb6H95IUEs6rMNGsCVAv+jxSMPPi/xDhLoZjWWiUZQJ0z1nP7ZmlC2qzl3m
         X7BJZ/DW9qAP1+R2jnM/oQ1TyvS3wIrm2ikYJ9N9SXj6W1hfXbCm5OTxVHgB5RWGFDGP
         jGQg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=ACC7emwD;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 79sor33612423vkv.73.2019.01.08.15.24.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 Jan 2019 15:24:26 -0800 (PST)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=ACC7emwD;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=9zeA7wPbvu4atpqM4sPM6IAShi6Cxo/Ri1A2df3T19k=;
        b=ACC7emwD/V6b0oJqwIt2mcqlaZ1wsVmLYiqliHX5EQSKAlJMJ7VKN0C2cbqScS+fxq
         z1KBrNKpm0NlIO0dTlWg9OQj3Q8tbMs9Lv940Ng/nxXJfuKCuu/5xqdoSO5Rs94B+MQa
         nU94b4lM3XNDqPAkvbzaTTIjWkgiEfSLwGI64=
X-Google-Smtp-Source: ALg8bN7U3H/wshpiBducg8zPTFJqXSX78g2WoEPF4o0kTkraQKmd4tSKofu8ZFYMtWrjgalwpF/kPg==
X-Received: by 2002:a1f:9604:: with SMTP id y4mr1372875vkd.28.1546989865590;
        Tue, 08 Jan 2019 15:24:25 -0800 (PST)
Received: from mail-vk1-f179.google.com (mail-vk1-f179.google.com. [209.85.221.179])
        by smtp.gmail.com with ESMTPSA id x132sm23037330vsc.34.2019.01.08.15.24.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 15:24:23 -0800 (PST)
Received: by mail-vk1-f179.google.com with SMTP id h128so1263857vkg.11
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 15:24:23 -0800 (PST)
X-Received: by 2002:a1f:e7c5:: with SMTP id e188mr1289532vkh.92.1546989862868;
 Tue, 08 Jan 2019 15:24:22 -0800 (PST)
MIME-Version: 1.0
References: <154690326478.676627.103843791978176914.stgit@dwillia2-desk3.amr.corp.intel.com>
 <154690327057.676627.18166704439241470885.stgit@dwillia2-desk3.amr.corp.intel.com>
 <CAGXu5jLGkfHax86C-M9ya05ojPwwKrpDL90k3gfAqxKc_emKpA@mail.gmail.com> <CAPcyv4h-Qce3-+Ragh5+0hzDvhCbV5YhNhzsnT0+dqnxR0bSzQ@mail.gmail.com>
In-Reply-To: <CAPcyv4h-Qce3-+Ragh5+0hzDvhCbV5YhNhzsnT0+dqnxR0bSzQ@mail.gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 8 Jan 2019 15:24:11 -0800
X-Gmail-Original-Message-ID: <CAGXu5jLVB6EKETqnKAwjtDYYXj9kjccb6HbFcghmxt8E1Qxq=g@mail.gmail.com>
Message-ID:
 <CAGXu5jLVB6EKETqnKAwjtDYYXj9kjccb6HbFcghmxt8E1Qxq=g@mail.gmail.com>
Subject: Re: [PATCH v7 1/3] mm: Shuffle initial free memory to improve
 memory-side-cache utilization
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Dave Hansen <dave.hansen@linux.intel.com>, Mike Rapoport <rppt@linux.ibm.com>, 
	Keith Busch <keith.busch@intel.com>, Linux-MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190108232411.eGst_Qt5cEAfEa5vMBjdxMWa1UmaIA4hwaFkfoetSr4@z>

On Mon, Jan 7, 2019 at 5:48 PM Dan Williams <dan.j.williams@intel.com> wrote:
>
> On Mon, Jan 7, 2019 at 4:19 PM Kees Cook <keescook@chromium.org> wrote:
> > Why does this need ACPI_NUMA? (e.g. why can't I use this on a non-ACPI
> > arm64 system?)
>
> I was thinking this would be expanded for each platform-type that will
> implement the auto-detect capability. However, there really is no
> direct dependency and if you wanted to just use the command line
> switch that should be allowed on any platform.
>
> I'll delete this dependency for v8, but I'll hold off on that posting
> awaiting feedback from mm folks.

Okay, cool. I'm glad there wasn't a real dep. :)

> > > +static bool shuffle_param;
> > > +extern int shuffle_show(char *buffer, const struct kernel_param *kp)
> > > +{
> > > +       return sprintf(buffer, "%c\n", test_bit(SHUFFLE_ENABLE, &shuffle_state)
> > > +                       ? 'Y' : 'N');
> > > +}
> > > +static int shuffle_store(const char *val, const struct kernel_param *kp)
> > > +{
> > > +       int rc = param_set_bool(val, kp);
> > > +
> > > +       if (rc < 0)
> > > +               return rc;
> > > +       if (shuffle_param)
> > > +               page_alloc_shuffle(SHUFFLE_ENABLE);
> > > +       else
> > > +               page_alloc_shuffle(SHUFFLE_FORCE_DISABLE);
> > > +       return 0;
> > > +}
> > > +module_param_call(shuffle, shuffle_store, shuffle_show, &shuffle_param, 0400);
> >
> > If this is 0400, you don't intend it to be changed after boot. If it's
> > supposed to be immutable, why not make these __init calls?
>
> It's not changeable after boot, but it's still readable after boot.
> This is there to allow interrogation of whether shuffling is in-effect
> at runtime.

In that case, can you make all the runtime-immutable things __ro_after_init?

> > > +                               ALIGN_DOWN(get_random_long() % z->spanned_pages,
> > > +                                               order_pages);
> >
> > How late in the boot process does this happen, btw?
>
> This happens early at mem_init() before the software rng is initialized.
>
> > Do we get warnings
> > from the RNG about early usage?
>
> Yes, it would trigger on some platforms. It does not on my test system
> because I'm running on an arch_get_random_long() enabled system.

Okay, cool. :)

-- 
Kees Cook

