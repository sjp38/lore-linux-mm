Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA433C31E4C
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 14:21:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7212D20866
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 14:21:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7212D20866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 246256B0270; Fri, 14 Jun 2019 10:21:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F5D36B0271; Fri, 14 Jun 2019 10:21:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 10D7E6B0273; Fri, 14 Jun 2019 10:21:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id B92FE6B0270
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 10:21:53 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id q16so1113486wrx.5
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 07:21:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=5pRKRIqd7WWU3KLjTcf+yzyAMGL4kf3UwpHpLS5Hwks=;
        b=geJSOSPFeESidtBsi0rDiXV5CyuvnlTm/WgsXs3aarNKt6D7H4whe8C3QlkZGBSPBi
         41lIWmFRVMdHjVMge+YHifXQC9Jq/1Gze23vNtSEljdy/txV3y6NTyF+X2JpIrNNsHNW
         i/e1uB/9aQaZhAmvgFIfPgy9p0G2z9O6mx5RnlDJ/BE66WfsW7QRNk0EVnlzLlSnE3ns
         WNw9zoZtITcGM6z4t6ExAeAeRyFBEVDUDT2GlmAw2MgLwIxvexsF1e/D0GbAxitN/que
         0QAANxV1sB3neI9boBGajZxlelMcpHGqY7TnGQCKr/0PU7BD5SeECXNJliP9Eb92Us6n
         VM5A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAVVnAokOMSbdJAhqIf8EXbVuKvA9P5VWfrkXknPhLMI+JepSTkP
	MvqtdSjvdiXiGCbmdZ5ejQ96PgVHEeqY0ccBsXvIWBhqc07Ipb9ZO+fs1BiY0Dno8EksW8mYNBL
	dYG4HwhWVZrMHeCIUOzyASTDCUJvCfPVqnwSD7Hqlslhn2HTcrKnhNaDwIsJYg8Kcbw==
X-Received: by 2002:a1c:c003:: with SMTP id q3mr8221594wmf.42.1560522113250;
        Fri, 14 Jun 2019 07:21:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz9kboj49XAu/Nt1ZoZoYHSue1WghVoMnn/HkCyBKzzRBw+N/OW4ic0Hoz0VLUY2Ji0mEV3
X-Received: by 2002:a1c:c003:: with SMTP id q3mr8221543wmf.42.1560522112459;
        Fri, 14 Jun 2019 07:21:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560522112; cv=none;
        d=google.com; s=arc-20160816;
        b=Y5gm558lzfqYbd++oiJTcvLFM06YzmwOrhPEXpbXtJzQ3f2Ze/MIGsr5e5xtZvBxev
         mJBZfQBfNaigZDck5oJ0dNgjyy0zxmax3Avi41B/I3lbUyYCaI4Fpw8Lzoh23B2esHvj
         uCIIe6Q9EQBJPsSn3KYbK7t8KE2RlTofOujHkZF7dPNrfeNKzJq+8n/+LEGc9h4NF+AB
         59+cD1cDACFZStmyF7Lauchz7u9iS8B9KIrL5+25mJjfyflL5ukO3m7Z6FM31APcRLoj
         wHKQI6lULzgyvI7cy/yu+eib1NZPX/p3xxlFv328Bc9bzPbf2f6mptic6DccscJ7+sWP
         PVyg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=5pRKRIqd7WWU3KLjTcf+yzyAMGL4kf3UwpHpLS5Hwks=;
        b=pFjW+YUb9okMEjBSIm+OluyHJZSsnUcIiIPJN7PvEc/yuxMLuNZ422jCgDlbYG8JCe
         eYRxxfBK/scgKvXwEr3y+mj2mzwgSjQJz98J3SaJivws8+KD2QrPlox0r3H8LZDtRK2V
         N2Q2sCQRdwZ21eG81nvOsp9oxs4axduUsLzSmwGnpHaMIUmxf3sjnGryF6AFru/eiFSc
         9VWYP0Gi3Oo28OMztAi2Y/sKRmUh9NQr2Pppq8OP4dcaJ2ew9zSL7cY+XTG9lOMgcO7z
         h1jNw1XlqwMnyPIQ05fPp6WjaaKz40bEMjD1u/7ILneI7gTyxA88Nqw7Y/OWaFmDyyn9
         VwSw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id v10si2574627wrn.34.2019.06.14.07.21.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 14 Jun 2019 07:21:52 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from [5.158.153.52] (helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hbn5M-0007a1-1S; Fri, 14 Jun 2019 16:21:44 +0200
Date: Fri, 14 Jun 2019 16:21:43 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Andy Lutomirski <luto@amacapital.net>
cc: Dave Hansen <dave.hansen@intel.com>, 
    Marius Hillenbrand <mhillenb@amazon.de>, kvm@vger.kernel.org, 
    linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, 
    linux-mm@kvack.org, Alexander Graf <graf@amazon.de>, 
    David Woodhouse <dwmw@amazon.co.uk>, 
    the arch/x86 maintainers <x86@kernel.org>, 
    Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC 00/10] Process-local memory allocations for hiding KVM
 secrets
In-Reply-To: <A542C98B-486C-4849-9DAC-2355F0F89A20@amacapital.net>
Message-ID: <alpine.DEB.2.21.1906141618000.1722@nanos.tec.linutronix.de>
References: <20190612170834.14855-1-mhillenb@amazon.de> <eecc856f-7f3f-ed11-3457-ea832351e963@intel.com> <A542C98B-486C-4849-9DAC-2355F0F89A20@amacapital.net>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="8323329-1104140577-1560522104=:1722"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000503, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1104140577-1560522104=:1722
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT

On Wed, 12 Jun 2019, Andy Lutomirski wrote:
> > On Jun 12, 2019, at 12:55 PM, Dave Hansen <dave.hansen@intel.com> wrote:
> > 
> >> On 6/12/19 10:08 AM, Marius Hillenbrand wrote:
> >> This patch series proposes to introduce a region for what we call
> >> process-local memory into the kernel's virtual address space. 
> > 
> > It might be fun to cc some x86 folks on this series.  They might have
> > some relevant opinions. ;)
> > 
> > A few high-level questions:
> > 
> > Why go to all this trouble to hide guest state like registers if all the
> > guest data itself is still mapped?
> > 
> > Where's the context-switching code?  Did I just miss it?
> > 
> > We've discussed having per-cpu page tables where a given PGD is only in
> > use from one CPU at a time.  I *think* this scheme still works in such a
> > case, it just adds one more PGD entry that would have to context-switched.
>
> Fair warning: Linus is on record as absolutely hating this idea. He might
> change his mind, but it’s an uphill battle.

Yes I know, but as a benefit we could get rid of all the GSBASE horrors in
the entry code as we could just put the percpu space into the local PGD.

Thanks,

	tglx
--8323329-1104140577-1560522104=:1722--

