Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A83AEC282D9
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 17:25:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5B84720869
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 17:25:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="dbz7g/io"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5B84720869
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 077F08E0002; Wed, 30 Jan 2019 12:25:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 025EE8E0001; Wed, 30 Jan 2019 12:25:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E80898E0002; Wed, 30 Jan 2019 12:25:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id B91428E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 12:25:34 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id o8so117237otp.16
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 09:25:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=/RI5u1ry/WlG/AE8Bg7DFqe/OOtozjhPffTo+TN90Nc=;
        b=GDBi1JvI1N5r9X4jsALAyobIIe+fpvSiaHGWrnBRpQAb/MqMQDvIoI8auwprY6XHiZ
         bL3mlybucfBexKoMHAUYKACVGogRiQS0NkE3v1Io1Tl8fxxHo1vIpmCXd2cppHDNV9lt
         lZhZKCNE0RW2nOsJlGpHu/FShtIh5EiHziwfuOVUOqeJ9yJfU4Ztc1vyh3jXW/PCnjJb
         5vHLzUHNK/Vp1hsoI2dOo4pMnrW1PgzblgWVdGcCDYqSi/ZgSe12ingCVXq0YOcvL1hX
         jxG4oNMZDz6YAQ682aOeUFXZn7FuahAuajKZj1M7m/DC6ufFf0uuksYVhnSxSJoz8/Rv
         rx4Q==
X-Gm-Message-State: AJcUukfu/11HAYw+WB9i2OclIM6cliFUUR4FuRkPhUXCMoqA4mHXZEUw
	tZlqQ3QuFMjVatCIoEDlJWq0KXfXho2kqZMS2Vap0yF3f21jS2xr1drZ033DYG+wF2QyXbsB9wh
	C6BRml08XZTPJtmRUkmFOYxIgKAiZuYATeiPH/6sMc4wsr1+LHiOzXLN8LYc69NpBJclrfPcVDe
	UPzO+is3o0HY+S9fA2xsTSHMimFQKED5tDf7qF9sxPJGkn4anzeWgvOpDCgqs+YoS9ZcweIsva+
	PzbVTq+7f9ynLX9UR2cSkzYdxdJSVz5vwpYknVzSzUyQcBofcRhoPyBYbRUYcV0F9heXrIrzbKk
	K71FzOkoh8V11T1DrDwIb4cqz2g6DUhqlvfsUJv8LLRih/z/tmyr2oCuHfbjtjTOIWBnYqb5CE0
	M
X-Received: by 2002:a9d:37e1:: with SMTP id x88mr22090500otb.85.1548869134487;
        Wed, 30 Jan 2019 09:25:34 -0800 (PST)
X-Received: by 2002:a9d:37e1:: with SMTP id x88mr22090469otb.85.1548869133661;
        Wed, 30 Jan 2019 09:25:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548869133; cv=none;
        d=google.com; s=arc-20160816;
        b=bi6R4Bcbu/8h6Cm0+3buYIv+U5BFI4v+RJn9/bQHBXtuPYrfAJi5rYAtVz9a8/yXk7
         F2nNuQlEyNlShQQUxQaTGXiUn7j1xtzwRmDpUn7CenTH3qjnPY0V+XmbgDuXSsYh+pCC
         OTl5JtwMc7oVs4NOIBI1Kj2qeFkTrD0oTyLHfZd56nN2Mf7HJ0UHIhXOV5AWGEYI1nKd
         ZVoRZQ02+mReUbrEwLf6f54e44nBUs8jheOqDz6ZI10C/lxv85QfKKYJRgX52dG8VMqI
         OZ0E0QaSXEEZ4A0n3jMzNuNY6UuS9neLDaumw7OUpq5ufULXyZULz4QyJpKiZpL5hzub
         FoCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=/RI5u1ry/WlG/AE8Bg7DFqe/OOtozjhPffTo+TN90Nc=;
        b=M7ZnUnPJq9g89Fam2qJERloXnZgsZ/LQYUZOkgLg26q3ri7VKN4rQmuEvF7dv+Bw4f
         6uLJpP1tnSpF1qHEeUAjq6Fum3cHCijpQTTjKeTFsFqekPKJCk/17eXlsWSBozvSQuU6
         SasieGtMmKNwnjloQbpct3JiefjOICxhOv5OpCwXMVWtxBoO4w47pKuM5COo3QPOEtwt
         Rmfb44WBbyqVDSikxgfPlvwhcFobFR7X4u39kCCWn4l0TPFh2fgji5FYfpoFcupZQPmO
         Nwlt19Rlv81Bqh8HZlzESOyTawIzctRKEGQ1uo2TlZxwxWcYuNj3tPP7t6SYfBmSflT9
         Mldw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="dbz7g/io";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c19sor1085666oto.60.2019.01.30.09.25.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 Jan 2019 09:25:33 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="dbz7g/io";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=/RI5u1ry/WlG/AE8Bg7DFqe/OOtozjhPffTo+TN90Nc=;
        b=dbz7g/ioR13FnWDgB93Qq2fuyGRMpcCqPkdwjznGwfkfUpmGD5O9o1T7e0XnkcgVYh
         Vpy2qewbLbkKlW7awGE9MhOjeKTgo9wL/KZuBTCQekxaVhhA6j9ju2SZjuPC1JTILkv3
         8kTKzeucV6+KN3MNPn11+0d8hztknh8zpIc0kAQSgkKw8EU4n41JwPepW4jrj+WHtgQf
         cyp3A1UmSlLnOeWs3gRLY+raCaNPeoRkA058TWSKoLjNze5aCC7x1IGtM4LtXghnfP4n
         56sCabea/ZgjW0dCQT2255Ywvs1+t1Eb7ioko76RObHQif49/UYosTti+Ot/PLfU/F0Q
         5YaQ==
X-Google-Smtp-Source: ALg8bN5hHnyu38XAc+5NOknji+8fOKhlhb+ajVksD899bqtxMYviYXMvEbJk6Fdzm23g+CeamhPIcwVe0ewtbjQA0ks=
X-Received: by 2002:a9d:7dd5:: with SMTP id k21mr23914805otn.214.1548869133293;
 Wed, 30 Jan 2019 09:25:33 -0800 (PST)
MIME-Version: 1.0
References: <20190129165428.3931-1-jglisse@redhat.com> <20190129165428.3931-10-jglisse@redhat.com>
 <CAPcyv4gNtDQf0mHwhZ8g3nX6ShsjA1tx2KLU_ZzTH1Z1AeA_CA@mail.gmail.com>
 <20190129193123.GF3176@redhat.com> <CAPcyv4gkYTZ-_Et1ZriAcoHwhtPEftOt2LnR_kW+hQM5-0G4HA@mail.gmail.com>
 <20190129212150.GP3176@redhat.com> <CAPcyv4hZMcJ6r0Pw5aJsx37+YKx4qAY0rV4Ascc9LX6eFY8GJg@mail.gmail.com>
 <20190130030317.GC10462@redhat.com>
In-Reply-To: <20190130030317.GC10462@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 30 Jan 2019 09:25:21 -0800
Message-ID: <CAPcyv4jS7Y=DLOjRHbdRfwBEpxe_r7wpv0ixTGmL7kL_ThaQFA@mail.gmail.com>
Subject: Re: [PATCH 09/10] mm/hmm: allow to mirror vma of a file on a DAX
 backed filesystem
To: Jerome Glisse <jglisse@redhat.com>
Cc: Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Ralph Campbell <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 7:03 PM Jerome Glisse <jglisse@redhat.com> wrote:
[..]
> > >     1) Convert ODP to use HMM underneath so that we share code between
> > >     infiniband ODP and GPU drivers. ODP do support DAX today so i can
> > >     not convert ODP to HMM without also supporting DAX in HMM otherwise
> > >     i would regress the ODP features.
> > >
> > >     2) I expect people will be running GPGPU on computer with file that
> > >     use DAX and they will want to use HMM there too, in fact from user-
> > >     space point of view wether the file is DAX or not should only change
> > >     one thing ie for DAX file you will never be able to use GPU memory.
> > >
> > >     3) I want to convert as many user of GUP to HMM (already posted
> > >     several patchset to GPU mailing list for that and i intend to post
> > >     a v2 of those latter on). Using HMM avoids GUP and it will avoid
> > >     the GUP pin as here we abide by mmu notifier hence we do not want to
> > >     inhibit any of the filesystem regular operation. Some of those GPU
> > >     driver do allow GUP on DAX file. So again i can not regress them.
> >
> > Is this really a GUP to HMM conversion, or a GUP to mmu_notifier
> > solution? It would be good to boil this conversion down to the base
> > building blocks. It seems "HMM" can mean several distinct pieces of
> > infrastructure. Is it possible to replace some GUP usage with an
> > mmu_notifier based solution without pulling in all of HMM?
>
> Kind of both, some of the GPU driver i am converting will use HMM for
> more than just this GUP reason. But when and for what hardware they
> will use HMM for is not something i can share (it is up to each vendor
> to announce their hardware and feature on their own timeline).

Typically a spec document precedes specific hardware announcement and
Linux enabling is gated on public spec availability.

> So yes you could do the mmu notifier solution without pulling HMM
> mirror (note that you do not need to pull all of HMM, HMM as many
> kernel config option and for this you only need to use HMM mirror).
> But if you are not using HMM then you will just be duplicating the
> same code as HMM mirror. So i believe it is better to share this
> code and if we want to change core mm then we only have to update
> HMM while keeping the API/contract with device driver intact.

No. Linux should not end up with the HMM-mm as distinct from the
Core-mm. For long term maintainability of Linux, the target should be
one mm.

> This
> is one of the motivation behind HMM ie have it as an impedence layer
> between mm and device drivers so that mm folks do not have to under-
> stand every single device driver but only have to understand the
> contract HMM has with all device driver that uses it.

This gets to heart of my critique of the approach taken with HMM. The
above statement is antithetical to
Documentation/process/stable-api-nonsense.rst. If HMM is trying to set
expectations that device-driver projects can write to a "stable" HMM
api then HMM is setting those device-drivers up for failure.

The possibility of refactoring driver code *across* vendors is a core
tenet of Linux maintainability. If the refactoring requires the API
exported to drivers to change then so be it. The expectation that all
out-of-tree device-drivers should have is that the API they are using
in kernel version X may not be there in version X+1. Having the driver
upstream is the only surefire insurance against that thrash.

HMM seems a bold experiment in trying to violate Linux development norms.

> Also having each driver duplicating this code increase the risk of
> one getting a little detail wrong. The hope is that sharing same
> HMM code with all the driver then everyone benefit from debugging
> the same code (i am hopping i do not have many bugs left :))

"each driver duplicating code" begs for refactoring driver code to
common code and this refactoring is hindered if it must adhere to an
"HMM" api.

