Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1100C48BD5
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 00:28:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D2AA2086D
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 00:28:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="YeX/xFTe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D2AA2086D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC1216B0003; Tue, 25 Jun 2019 20:28:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D71FC8E0003; Tue, 25 Jun 2019 20:28:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C38B28E0002; Tue, 25 Jun 2019 20:28:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id A52356B0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 20:28:42 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id x17so494222iog.8
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 17:28:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=T/uR/4PciUq//wm8VvTrYpqXShwr7/kFFKyCPyP8pcs=;
        b=Y6XCT6v/L0lUjWoi5GupJzjBmeBq7J3BBaHETjNbjJryhhXZIYM+fqvhR6EiF1oySk
         rsPmeyNJw5A85+krL5EFLuFO3lSgCrSjwJ49iVsuViRFAp+DPhFA7DI2YRMsXTa8jJe5
         3xSnGTnqllwU+X+GWdva+G1geqpwpbwAVGEO+X2Qimgl8ApGM9Ud6h3b5OsdKnW1MDhE
         +NKYWAY0auC92M39IT29Pt152ean6pa34JfgBEwNP8pK+3+hAp3+Ul8SmLCg7NqDHZUe
         ICUTjgkCxydyLmochVqLq/h3U8tUUbOAOOlc5se3wRljDZlKZEZSweqX03q77yrpvubL
         lV0Q==
X-Gm-Message-State: APjAAAXqW3sCJYSbwltEyij6YZTiuCqdDEmr4cNa+pVWUrG0I7afWQwV
	vSImYNs50Cyy4lpM+shpaJqZfm1quLcONluGD9qsxq8LFmCfEkcdUHLFGOxqWL1TrrltVVFYA62
	wEc1svpQPVajjfW4rHeF+5To8qwaOjooj01Avkzo8vbzrv+pvjES7MMqOTeHrVTbs+Q==
X-Received: by 2002:a5d:81c6:: with SMTP id t6mr1790254iol.86.1561508922434;
        Tue, 25 Jun 2019 17:28:42 -0700 (PDT)
X-Received: by 2002:a5d:81c6:: with SMTP id t6mr1790212iol.86.1561508921831;
        Tue, 25 Jun 2019 17:28:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561508921; cv=none;
        d=google.com; s=arc-20160816;
        b=I/pp6H5ibjLhZXqHxboMMO0R2W1qa+WvNqnEQW1qyNUqu3tI3+tdtY9MRKQ4Jzq9Pw
         G9i5aG3kMegCDAoJ7mMbPFjOVj8YNzK6pLJygcEq/k2SMML/BSpnn7kv/dh5HIb1SBCR
         l9V/Xc7bOD+diDCQMHwCsfG128H4OyjUSaJ3WekfG3qpXJ9qTkahK+BVc6Y2vxybmAik
         Jk7gyDByUOk4fTTSnTLcRYePTbr1EzimR2yZBrfrOF1l0YoSGVNv0YEZZP/c4hu/HjzI
         EIpZbLZDoCFmCXBMhfblCTWePOf9IpF+5Ui9YiRKKBtno+Q/6wFToILejISjZmifcVUH
         aBUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=T/uR/4PciUq//wm8VvTrYpqXShwr7/kFFKyCPyP8pcs=;
        b=xpJ7Sog/azHT9cPOJvBgPyQi2qnygxWQoTqlNzqREbBs5hsmvMnQc9ExkoaxhG6wK2
         2dT3JbeEdxAleUuas85mHFYwxf88m0HYBewZxBZuKWLUe1je4ZpeU4QP9VAG1fL4sPji
         PnfBKh0mXx3RMwYXCaHVfL69RHlvwapqYgVwcVRE+TWbMD+M5dHJ4eC86LkOrztdOReV
         Ms646OQF3ZvJK0oQh45iziKCoJ22wKA+CIYfaYx2otSzrbH3vAOfmMx3i8yZuCxfecdW
         3ik1AgrzpKw/gtfsq1wbST6/IQHGRoVf0ty5t+EfdeFtWe4+s3L+rWAQiNN5BYxbQ9OV
         LVGA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b="YeX/xFTe";
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a66sor11728374iog.113.2019.06.25.17.28.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Jun 2019 17:28:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b="YeX/xFTe";
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=T/uR/4PciUq//wm8VvTrYpqXShwr7/kFFKyCPyP8pcs=;
        b=YeX/xFTe86cLjtEiwNDGr0CKTn6yvfRoFVYAyjGpJqcjyjOauh0oSms8qNpsPWv76x
         eRvUUgmWL0+6wScBbr8rD2ZZ/RfhNpAX4UKm1peplkD8GmwmOk+8uVKUsB9hanwxe3Dm
         H0krLG+sD5Fzr71HJU1x0kXlYQzuI9cWXt4LY=
X-Google-Smtp-Source: APXvYqxX0Qrt909cJIALCW0svY89PQl3z7r/J2jSYrLO+BEo6+PoMkKF1jAWxKfLc2PBHctF8DPoeOKanHzXan7VOSY=
X-Received: by 2002:a6b:6d07:: with SMTP id a7mr1751422iod.254.1561508921439;
 Tue, 25 Jun 2019 17:28:41 -0700 (PDT)
MIME-Version: 1.0
References: <1561501810-25163-1-git-send-email-Hoan@os.amperecomputing.com>
In-Reply-To: <1561501810-25163-1-git-send-email-Hoan@os.amperecomputing.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 26 Jun 2019 08:28:30 +0800
Message-ID: <CAADWXX8wdEPNZ26SFJUfwrhQson3HPTrZ7D2jju3RhEeMuc+QQ@mail.gmail.com>
Subject: Re: [PATCH 0/5] Enable CONFIG_NODES_SPAN_OTHER_NODES by default for NUMA
To: Hoan Tran OS <hoan@os.amperecomputing.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, 
	Vlastimil Babka <vbabka@suse.cz>, Oscar Salvador <osalvador@suse.de>, 
	Pavel Tatashin <pavel.tatashin@microsoft.com>, Mike Rapoport <rppt@linux.ibm.com>, 
	Alexander Duyck <alexander.h.duyck@linux.intel.com>, 
	Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, 
	Michael Ellerman <mpe@ellerman.id.au>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, 
	Borislav Petkov <bp@alien8.de>, "H . Peter Anvin" <hpa@zytor.com>, "David S . Miller" <davem@davemloft.net>, 
	Heiko Carstens <heiko.carstens@de.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>, 
	Christian Borntraeger <borntraeger@de.ibm.com>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, 
	"linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, 
	"linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>, 
	"sparclinux@vger.kernel.org" <sparclinux@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, 
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, 
	Open Source Submission <patches@amperecomputing.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is not a comment on the patch series itself, it is a comment on the emails.

Your email is mis-configured and ends up all being marked as spam for
me, because you go through the wrong smtp server (or maybe your smtp
server itself is miconfigured)

All your emails fail dmarc, because the "From" header is
os.amperecomputing.com, but the DKIM signature is for
amperemail.onmicrosoft.com.

End result: it wil all go into the spam box of anybody who checks DKIM.

                       Linus

On Wed, Jun 26, 2019 at 6:30 AM Hoan Tran OS
<hoan@os.amperecomputing.com> wrote:
>
> This patch set enables CONFIG_NODES_SPAN_OTHER_NODES by default
> for NUMA. [...]

