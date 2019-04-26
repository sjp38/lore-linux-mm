Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DE17C4321A
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 16:40:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BEC7C208CA
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 16:40:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="YzBchEnw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BEC7C208CA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5AA5F6B0003; Fri, 26 Apr 2019 12:40:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 580AC6B0005; Fri, 26 Apr 2019 12:40:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 46ED86B0006; Fri, 26 Apr 2019 12:40:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 275026B0003
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 12:40:42 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id y5so3029104ioc.22
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 09:40:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=MpfVP/lrM2Q2wBohc8zzCs4q+zAicjTmbOR9EpWu+KM=;
        b=tvVa7gIfkdgyV3yXTiXrGBxvCD8Lbs9n8QI8OadnVbcTEdjKmvHV386728fYTJOWpb
         cHJZM+fCEyvXtCACT/5eDuW5zvq/11otDpxZU5fmMtTAMfsrK2MiV7BWkOGID1ZNYqjD
         qSxEXZlUzdOTeDoCTT0fvEsXHdC1wBzDNOOc3IGvEHMCWrZUHv3UEbVGCIiOncXPbQ1U
         L0eHmcPdP16ng2XouXS+yxx2czka2L69GN9vUfi+pAiqz6magH8Y/b3LwWfRUGsMIr0T
         3DwO7bgkQwAJHqncyyUovOO/kpPWH/Bt6ltbwX8Kk+0s+ZBkTpqR7rK2c+/8FmkgbIXA
         6T0w==
X-Gm-Message-State: APjAAAXo7nkqIvBG0V7SiZgzSIA4M4Ti/rLMgZz7KfT/TsAptpUq2PDz
	3GkPEwEBXGpnZs72AiLL1N4iYgljmBGgOeQHY+tUzzuS3iVkC1LeHAycQo2rR/63nnu/iKO92RO
	+lqRbFeReOSdP9GGF4orOSMIV9DLWhBZtvt+ZFxAMRCcoxFEaFnW3efk3prxX8zUJ3A==
X-Received: by 2002:a24:46cc:: with SMTP id j195mr9435588itb.161.1556296841752;
        Fri, 26 Apr 2019 09:40:41 -0700 (PDT)
X-Received: by 2002:a24:46cc:: with SMTP id j195mr9435545itb.161.1556296841000;
        Fri, 26 Apr 2019 09:40:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556296840; cv=none;
        d=google.com; s=arc-20160816;
        b=qM/tMDCs9iNQU7yAl4+T2ZC3s2CwFePly6bPyxgnay1zlELx0XeebmzW7d/+PZG08h
         dhR/eqTihmRiSWxM3ZJrfl76HKRMh5MW8VdzyU43e4Dqnts5eFSVMv1QfEPfaSDhyiaW
         aXXdBSPJXAxPj5N/hBooQRSPZPn0IWZDR4qoM5uAW77aEmisORysGKVpIqiIvoYUxQ1s
         j3wqhxJd0FUmf1aDJJO0d3OGSRN15OBi/RIL7cGGh2lzcg8HUDIZ7Mdtu97xPonKAj17
         8vPnG41sxIlB08iYpR17PsizFWFyIWs9eSyw4dRWbBYKfl9w0f7sab1rrXkpoipE3CWB
         +zKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=MpfVP/lrM2Q2wBohc8zzCs4q+zAicjTmbOR9EpWu+KM=;
        b=Px6zzhckS5kYkiG+h3cwuhMOaSMH1xSTGH9M4gW9NWFzVUVECygwBlLJINNK5WaiS+
         Dk3KfL3B3YBOzxd6kTun3AOq9eVxJ47JB7855/OuIC6sJLK9kd2jT4tkndHHMWpda63M
         Q7zz9ct0O0Yxk2dwz0VGWo65ufFEhLndKHFDcMk6uWk59hxlRgRynTlFJmExpCLumQ8m
         lQ09jbfEkbKVmDmkQR6eEp18NirRXYSyTYRzKv+BNiObmV3NE+uGmF+VD+ShKb52Y7fL
         UXERqgfWaSrQ3VC8L+mtH2APZubYp9TGZyOOTviLtQwhmsvzkWvld06i3PaHQXEUZQzf
         Mzzg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=YzBchEnw;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l68sor37486692itb.13.2019.04.26.09.40.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 Apr 2019 09:40:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=YzBchEnw;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=MpfVP/lrM2Q2wBohc8zzCs4q+zAicjTmbOR9EpWu+KM=;
        b=YzBchEnw3mtY1YHu5sF33oylYVI3nOfEG4y0HZgQaJs3IGiOAGg2uLSxEMl9Byl9yI
         c0nS4Koilqx/n6yAiEj7u/DZRZpuFI+SF8Q3SwqUJe2sMDyec493TAbUU9pgD0X3cwNm
         0hERY2zqnEvAI+fi+jcfSLT6mHrs2vVPV5/AY=
X-Google-Smtp-Source: APXvYqwW9kSQ5c/BDQ9RuOU9AZc1pvkLKD+0Bxd2Hwf1ST13QGVew2CuHRgH9D9F36FW8jZnvHzXcwE8P2b2WkseHhg=
X-Received: by 2002:a24:198f:: with SMTP id b137mr8812183itb.105.1556296840738;
 Fri, 26 Apr 2019 09:40:40 -0700 (PDT)
MIME-Version: 1.0
References: <20190426001143.4983-1-namit@vmware.com> <20190426001143.4983-15-namit@vmware.com>
In-Reply-To: <20190426001143.4983-15-namit@vmware.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 26 Apr 2019 09:40:29 -0700
Message-ID: <CAADWXX8yZJ9Z4yfqG9wQcb2r+0O7VCk2uQLcOU1=-BOnYhjnow@mail.gmail.com>
Subject: Re: [PATCH v5 14/23] x86/mm/cpa: Add set_direct_map_ functions
To: Nadav Amit <namit@vmware.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, 
	Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@redhat.com>, lkml <linux-kernel@vger.kernel.org>, 
	"the arch/x86 maintainers" <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, 
	Nadav Amit <nadav.amit@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, linux_dti@icloud.com, 
	linux-integrity@vger.kernel.org, 
	LSM List <linux-security-module@vger.kernel.org>, 
	Andrew Morton <akpm@linux-foundation.org>, kernel-hardening@lists.openwall.com, 
	Linux-MM <linux-mm@kvack.org>, Will Deacon <will.deacon@arm.com>, 
	Ard Biesheuvel <ard.biesheuvel@linaro.org>, kristen@linux.intel.com, 
	deneen.t.dock@intel.com, Rick Edgecombe <rick.p.edgecombe@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Nadav,

I get

       dmarc=fail (p=QUARANTINE sp=NONE dis=QUARANTINE) header.from=vmware.com

for these emails, because they lack the vmware DKIM signature.

It clearly did go through some vmware mail servers, but apparently not
the *right* external vmware SMTP gateway.

Please check with vmware MIS what the right SMTP setup for git-send-email is.

                 Linus

On Fri, Apr 26, 2019 at 12:32 AM Nadav Amit <namit@vmware.com> wrote:
>
> From: Rick Edgecombe <rick.p.edgecombe@intel.com>
>
> Add two new functions set_direct_map_default_noflush() and
> set_direct_map_invalid_noflush() for setting the direct map alias for the
> page to its default valid permissions and to an invalid state that cannot
> be cached in a TLB, respectively. These functions do not flush the TLB.
...

