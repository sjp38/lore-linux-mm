Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F796C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 18:42:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1EBAC21479
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 18:42:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Phfp4mqL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1EBAC21479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 918F58E0004; Tue, 19 Feb 2019 13:42:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8C8158E0002; Tue, 19 Feb 2019 13:42:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7DE8C8E0004; Tue, 19 Feb 2019 13:42:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 545918E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 13:42:38 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id v125so5967038itc.4
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 10:42:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=+uPFuRMyXehXiyDsdkoGpf14gQxB1Rylxb+Cq1M8Po0=;
        b=mYoH6DxRD26rc7JzaL4cgol5pDnTzqBc9ePmNEJsg6sl8cZPEh6+mJKV1RcV/IYTqt
         QZX98XZ4Y1IaKgDFyfbYSe5/W6gQFsqJmef4YLHKxVZpcyKJDoYl1aWJPqQTQxR57xIG
         /cioyWBDXvXJgrDXoiBvh/RLoZRCChdbQ62bqIWG/IJfKL931Q8rhqcfhnLCyw148njx
         oWTNmv97dGI3mdQcHldg9EtTmAsctditEIWZr9xANFR63YTOc8I57Yd8Oc81FbL6WqFn
         nRxjdZJnIn6YS/D2sfFvUyB7v4YkabXPnX/efvkdcDL1fDMc7A9WdNfp6WrktGi3jqB5
         wxXA==
X-Gm-Message-State: AHQUAubtNWuQGs4tFd4Gpgti+YAHDvF3GpLkXb6zRXf4I65d9JCtb6W6
	jpkNYqGzhdZzsAqae/v5zdc9pLHyBUWIxCV1cjcaY8gpjJbsJJfWHQrsVHktptSQSsSp+E45mRa
	bPIw6IehBjkCgNOoZenQbDn/oJtg+WnX3iHzGwpubCloa6pw2ziemPAsqGplPczRrUnlGK5jxLR
	QmlHFB8aNE24RsfVyQgmyPr0lZHP1cZjaL298Axfl0Mo+B0ylEUvndqUEepzVZgVMird/BtxXuf
	kpSkhiiYIi44mNtg56d0KQLOxMSG32omkalTPHTgBfqkX4l/u/hBYx/vH8aL2hDGhHqM9WxkEtR
	VhxTLSB9TspRbPi28gwjSH+nbD7/1zZXzaOp4HXS9Naa040OgZfW1ytijqj70a3R7/ktftFAR9l
	0
X-Received: by 2002:a05:660c:684:: with SMTP id n4mr2729572itk.64.1550601758027;
        Tue, 19 Feb 2019 10:42:38 -0800 (PST)
X-Received: by 2002:a05:660c:684:: with SMTP id n4mr2729545itk.64.1550601757270;
        Tue, 19 Feb 2019 10:42:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550601757; cv=none;
        d=google.com; s=arc-20160816;
        b=DDC3yVP6eJIzsDrCbiboo/XQrUYw7KJPDgKUurzoFxuiXhf2wjI6XcjtU3XNGnZxW6
         1raxQSkAkilxByBbU/jiyyDn+NKXkPNk+ZHhg1zFXcWEB8zbzbkuKM4WvvIAIPYt5c65
         gJHJaEY/uOwgASvZbn709NauAbqjhFxExW+PM2eKLLFPua+Nlsvo7SlCkLY4Ay24RB0t
         fV83ZA3GJyyoysAEls/lhwEFG219cdQlVU/+f25ZS668h7z/BchXjpk415BJAmpkqSvG
         r5ELgnbd83N7WIibjSRuiU0ojceMkxISNCOzCnaEYvLWolMWa/G4yqXp4e274wbOxlLt
         2aAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=+uPFuRMyXehXiyDsdkoGpf14gQxB1Rylxb+Cq1M8Po0=;
        b=HWpviiBOu/y58odeGWryKAC2AXyLsbnXG/dgtcbEO2z27oKAHTOlMaYqI1Aw/dYEkH
         0DIujJY+riPZ8gbksGne2L2kXV4bQdfLIZgehx8BJKQefiCrEjMlrkbs0vucVxJy1wI6
         ZvRvSpc5mbaQBV2FYJf/3uJlI0azDF95EYo+AS89v8HOxNUyNRwxCdnaVkzy6fk7OKC+
         6kl3kQIe+kV0Ta441FfHKCR/z8GzvmROUoU4x2UJ8jQYE8r0o0+Pga/iI/NNylUoqrp8
         5s2j9Ta2sSjdZYfsm997C09SRXJrXfXyRpt8Ihgffyyc+hiUZMiE3JFkqZ8kW0wzGVtN
         rvrg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Phfp4mqL;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q19sor7544659ioj.109.2019.02.19.10.42.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Feb 2019 10:42:37 -0800 (PST)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Phfp4mqL;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=+uPFuRMyXehXiyDsdkoGpf14gQxB1Rylxb+Cq1M8Po0=;
        b=Phfp4mqLUrc7514I8BNCOheyNg8Ea584uSdCamWkcj8OvqhSd7KUg8Kp+N/Q5ZMYu3
         chdPVynxUC0Od8rCSGQkCd+FxNJ8nWV3VqrQ03h1kN2Wg2ogr8kWBxRwQD75TWkKsw0d
         CRFNUhXatl1Sf+wwfccUYErY+Ugi/46uPw5AFoTFNIW5OS7PIL/bvegbKmllYx1uXjus
         enigUU2Gzytecm2Oo6wm5+r69+SuDox9gpBSQ9qd0n7CFYWFjv1nPf+zYpQcWoRfWtYI
         rA1zX+dr3q6g+QlssBy7/z3ltz4m8/NZ/sisSbpCbs8BkE1gfvT5LAVM6twHRX9sjdcH
         PX4A==
X-Google-Smtp-Source: AHgI3IYChhnMliHcxlnejJitz4l+Tal+ydNn/WpEuts6QGgm0+b9c0Uz6/l4oOoR9Im72a+zPyxm0mgnzEU3t6CdLGw=
X-Received: by 2002:a6b:f70a:: with SMTP id k10mr19777857iog.68.1550601756670;
 Tue, 19 Feb 2019 10:42:36 -0800 (PST)
MIME-Version: 1.0
References: <01000168e2f54113-485312aa-7e08-4963-af92-803f8c7d21e6-000000@email.amazonses.com>
 <20190219122609.GN4525@dhcp22.suse.cz> <01000169062262ea-777bfd38-e0f9-4e9c-806f-1c64e507ea2c-000000@email.amazonses.com>
 <20190219173622.GQ4525@dhcp22.suse.cz> <0100016906fdc80b-4471de43-3f22-45ec-8f77-f2ff1b76d9fe-000000@email.amazonses.com>
In-Reply-To: <0100016906fdc80b-4471de43-3f22-45ec-8f77-f2ff1b76d9fe-000000@email.amazonses.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 19 Feb 2019 10:42:25 -0800
Message-ID: <CAKgT0UevknPT5HoQMrGW9Y8Ohpf=9G7tvMwWxYEhiz2fKHS+aQ@mail.gmail.com>
Subject: Re: Memory management facing a 400Gpbs network link
To: Christopher Lameter <cl@linux.com>
Cc: Michal Hocko <mhocko@kernel.org>, lsf-pc@lists.linux-foundation.org, 
	linux-mm <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 19, 2019 at 10:21 AM Christopher Lameter <cl@linux.com> wrote:
>
> On Tue, 19 Feb 2019, Michal Hocko wrote:
>
> > > Well the hardware is one problem. The problem that a single core cannot
> > > handle the full memory bandwidth can be solved by spreading the
> > > processing of the data to multiple processors. So I think the memory
> > > subsystem could be aware of that? How do we load balance between cores so
> > > that we can handle the full bandwidth?
> >
> > Isn't that something that poeple already do from userspace?
>
> Yes. We can certainly do a lot from userspace manually but this is hard
> and involves working around memory management to some extend. The higher
> the I/O bandwidth become the more memory management becomes not that
> useful anymore.
>
> Can we improve the situation? A 2M VM was repeatedly discussed f.e.
>
> Or some kind of memory management extension that allows working with large
> contiguous blocks of memory? Which are problematic in their own
> because large contiguous blocks may not be obtainable due to
> fragmentation. Therefore the need to reboot the system if the
> load changes.
>
> > > The other is that the memory needs to be pinned and all sorts of special
> > > measures and tuning needs to be done to make this actually work. Is there
> > > any way to simplify this?
> > >
> > > Also the need for page pinning becomes a problem since the majority of the
> > > memory of a system would need to be pinned. Actually the application seems
> > > to be doing the memory management then?
> >
> > I am sorry but this still sounds too vague. There are certainly
> > possibilities to handle part the MM functionality in the userspace.
> > But why should we discuss that at the MM track. Do you envision any
> > in kernel changes that would be needed?
>
> Without adapting to these trends memory management may become just a
> part of the system that is mainly useful for running executables, handling
> configuration files etc but not for handling the data going through the
> system.
>
> We end up with data fully bypassing the kernel. Its difficult to handle
> that way.
>
> Sorry this is fuzzy. I wonder if there are other solutions than those
> that I know of for these issues. The solutions mostly mean going directly
> to hardware because the performance is just not available if the kernel is
> involved. If that is unavoidable then we need clean APIs to be able to
> carve out memory for these needs.
>
> I can make this more concrete by listing some of the approaches that I am
> seeing?
>
> F.e.
>
> A 400G NIC has the ability to route traffic to certain endpoints on
> specific cores. Thus traffic volume can be segmented into multiple
> streams that are able to be handled by single cores. However, many
> data streams (video, audio) have implicit ordering constraints between
> packets.

What is the likelihood of a single data stream consuming the full
bandwidth of a 400G NIC though? As far as splitting up the work most
devices have a means of hashing the packet headers and then splitting
up the work based on flows called Receive Side Scaling, aka RSS. That
is the standard for distributing the work for most NICs.

