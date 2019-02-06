Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D6B3C282C2
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 20:02:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC7E4217F9
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 20:02:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="dj/gJrDa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC7E4217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 826FF8E00F2; Wed,  6 Feb 2019 15:02:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7B0F58E00EE; Wed,  6 Feb 2019 15:02:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6779C8E00F2; Wed,  6 Feb 2019 15:02:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 39B878E00EE
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 15:02:54 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id f8so4215323ybj.13
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 12:02:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=k0CqLn4RmwyP4v+EH3CC7Wy9XequpyzTFjmrIxpm28w=;
        b=qRLuA7Xr/Skcr4Z/FhsEbr+Tt0ppHfr0eqnGnza1V3Ol4n1IJM+fjekdf5v6eOSPzy
         Z0xX9cmAb+5P3qil6UGCDgnGRivzHA7uDrLa2DSPpWIY6AwpJuAoZKfuybY3R9KAxrXv
         sC7gKcjeNSZkpDVOrz34QwzGsS1TEVYyyuWW03ZTjF2cUbRWVtpUkoMqt/fosoYFKR2F
         qRk1dmmEqgctElLBw09SmujWST3noXJud7Mxc1GdWubwh5k489F5YEY3W8jZpCVqz1Tu
         Z/TGw13ZdOMG3VuHz1Ee7GyaFEBaemD/jMQFsyfh7UjpFMiuJcUwzU/uMLitIr+nboZx
         ALKg==
X-Gm-Message-State: AHQUAuY4sRD2OSPR/4G3B/KGx6ANBUZEgXJyJVj8+ZC8N3g0WccKzcN6
	Ga4bj0ek6W9q/IE5vdr9VqxS6N90r6w3mo5qhenC5jtq1oes4gilmkf6KTQN7wlfFr+sKSjqkEB
	MAk1sL7pxv7hLrih5Pt/e+Z2UuI+UHrMsrxq1IMepYqbTyODqPgn+hjzPJU6fKmLOm5AQVJyFYN
	N3oDUbdwLeTnnnogUriwYggykk8S/jA5S+cqfwgZ+JCwsREeL0oY+bSyUcLvxiJUcsdKSthyOWZ
	tcHqbpGtzT672/3y0LJgUSBt5xw8SxtNEou30OXCYi+rofs8mpalR35WvabIRXATB/UXbd0g5la
	+D8eVzu5jTwB7Bf5KLw5mxtPkqe8LSaNCz7kH9zLRcTX8D5gwL7ImcYUI7WaVDluxvO2Zbse7JH
	p
X-Received: by 2002:a81:87c2:: with SMTP id x185mr9798889ywf.379.1549483373725;
        Wed, 06 Feb 2019 12:02:53 -0800 (PST)
X-Received: by 2002:a81:87c2:: with SMTP id x185mr9798822ywf.379.1549483372881;
        Wed, 06 Feb 2019 12:02:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549483372; cv=none;
        d=google.com; s=arc-20160816;
        b=ACB3FaAFW+h6j7qsliILR8sa/UIKC+3j3xnIMpahauF8eG8ojTNLD/FZCdu3aOrGUX
         6CCJHplOjsUZNMN5QcjmxqjOhPd+o8owP5OZToY/q2pOz9hK0byt1MU4QSSHwvBg2+kF
         aXaKHvRgllP4XpOycCkEZebw28s+RH4Ph3LEgB9kAUm8Vs6Qbm4BlU0swk5WAHrY1Cl5
         uBcwPC/atHlWE4Q/hwVZQwHe8WAbRww9Pi+S7TUW8bCV8PFQKZxnBd0uhVbLAeqnGdkU
         XeK8Y1hGdzcXg41wGo6Wc3koYy1o/eabqILPool4Y1/+09nW/DLP9LudzUKGw+BCtItP
         UC7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=k0CqLn4RmwyP4v+EH3CC7Wy9XequpyzTFjmrIxpm28w=;
        b=qKCXSjLWbWYbUqPb728gl888yf47PcVa2fGov+zj7bCRP0aORVGCdCsNfgmCoVSlUp
         zJvid1IBdJBsPAcSKwJ6FHzki7N4vAWBoIMbv7YP49uM1QHjidrMXt9Ps8Tsm3NxDTCB
         CVmcCbPKkoiJX6GkswO/agIdnp6UMz4b97FJRlDI1lTCjhKWR0mLcEo+emLICnf6UePe
         17+Clv8e9/cNNKzc87ByL8tP3/Jo0F3CHMx7ltCtJUrZPUNVZW7L6PgmyYCDryoDqTIq
         vAfPLgmxb0JIF/UTdvqKGCyxitNjI++GcscEkJFAS0FnuYo5ym5Twj2vmIwXTi3CkMOJ
         daVg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="dj/gJrDa";
       spf=pass (google.com: domain of amir73il@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=amir73il@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t4sor1376159ywa.78.2019.02.06.12.02.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Feb 2019 12:02:52 -0800 (PST)
Received-SPF: pass (google.com: domain of amir73il@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="dj/gJrDa";
       spf=pass (google.com: domain of amir73il@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=amir73il@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=k0CqLn4RmwyP4v+EH3CC7Wy9XequpyzTFjmrIxpm28w=;
        b=dj/gJrDa8zw3vtVYnHJd/t+pYYFJQDxEXu4PjdcePhS7VBpCcJm8+upK6P941DgWvr
         QqiuHGezcDgQOUeZIFJmxqpif362kZ8leWojlB6bAxtC4RxYpUZZyET4osW8TEY2KLBc
         QJNd0D01wcMi9KbFhZKSUYA00IVE9jvDiP+HE2YYLZfNx7TB8rjeMTN71rZnaQ0kcstM
         rz8PdWsj6tr+jgXVgfDt+7kYnJI/APEIWiyZiwqJTObkLkgE6C7DRP4ceJM68LKzscIc
         +9adB4RS44yagYD1PSHJPx5MvAeoMXJYI3piRn0vzubv6YV1yXH9IPoMUb9SU6KgDlR2
         2ExQ==
X-Google-Smtp-Source: AHgI3IaBTPP//bgYeedw+uvGhvGlZhkhp40MfBbDsRSYtirCoaL3vAqqbCyHK036ef79w+N3U3HfEeROQZ9yuHYFenw=
X-Received: by 2002:a81:274e:: with SMTP id n75mr10117588ywn.404.1549483372445;
 Wed, 06 Feb 2019 12:02:52 -0800 (PST)
MIME-Version: 1.0
References: <CAJfpeguq60X745NnYDAKZhodLEvFRha2QTpAu6g63vJxq8SvaQ@mail.gmail.com>
In-Reply-To: <CAJfpeguq60X745NnYDAKZhodLEvFRha2QTpAu6g63vJxq8SvaQ@mail.gmail.com>
From: Amir Goldstein <amir73il@gmail.com>
Date: Wed, 6 Feb 2019 22:02:40 +0200
Message-ID: <CAOQ4uxgYKdCcqEu8i_+h3Cu3CPJu4v4MDusK8S8auQi=fS0vxQ@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] filesystem virtualization
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: lsf-pc@lists.linux-foundation.org, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	Vivek Goyal <vgoyal@redhat.com>, Stefan Hajnoczi <stefanha@redhat.com>, 
	"Dr. David Alan Gilbert" <dgilbert@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 6, 2019 at 3:06 PM Miklos Szeredi <miklos@szeredi.hu> wrote:
>
> This is a joint topic proposal with Vivek Goyal.
>
> Discuss remaining issues related to exporting a filesystem from host to
> guest (see virtio-fs prototype posting[1] for more background):
>
> * How to provide strong coherency guarantees?
>
>    - Fsnotify synchronous post op notification
>    - Extend lease (delegation) API to userspace

There are some commonalities here with userspace networking
file servers. I am interested in samba in particular and things
that we can do to improve Linux interfaces for samba.
SMB3 directory leases for example.

Thanks,
Amir.

>    - Multi-component path revalidation
>
> * Issues related to c/m/atime handling:
>
>    - Clock synchronization between host and guest (not an fs issue, but f=
s
>      has to deal with lack of it)
>
>    - Could we have O_NOCMTIME open flag?
>
> * Shared access to file data:
>
>    - Use DAX in guest to access host page cache (mmap/munmap sections of
>      file in guest address space; happens dynamically on a need basis); i=
s
>      this design reasonable?
>
>    - Avoids memory copies and cache duplication, but host page table setu=
p
>      may have high cost.  Can that be improved?  (E.g. fault-ahead)
>
>    - Too many VMA=E2=80=99s on host per qemu instance?
>
> * File locking:
>
>    - Host API for POSIX lock sharing?
>
> * Ideas for the future:
>
>    - Buffering directory operations (e.g. "tar xfz ..." with as few
>      synchronous ops as possible)
>
> [1] https://lore.kernel.org/lkml/20181210171318.16998-1-vgoyal@redhat.com=
/

