Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5F8FC10F0B
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 17:18:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6B2E821848
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 17:18:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="jKQxnJ/2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6B2E821848
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 857418E0003; Tue, 26 Feb 2019 12:18:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 805848E0001; Tue, 26 Feb 2019 12:18:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6F6948E0003; Tue, 26 Feb 2019 12:18:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2E9888E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 12:18:39 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id 71so10231866plf.19
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 09:18:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=OOLLQFuNWZNcLbvoTKuul2PBnwLCZZV2yl5Rkby6ik0=;
        b=hTm/KN2axNf/ThqGY1E8PHEg3NGXmUWXQ5x1ahs9UALjUBB9a5ds4a+3J9CLpi9WsV
         6VDEJGV1PmhKbi81kUjsekG2vDO3GVlJuw42g/c3huhb11m+uxeadJ+ZbJGLyKWcyBeJ
         dS0aUFk1cvkY9PSgCOpZHVlcV8LqpY15ZmXA2yK7s4hqtpsagS1FHc6wNGuxB4Ar3Oo0
         unAPjKq9Jbhd5+UQzyRQIuTBbKVqEmtM77PmMaxh4O2/Lx85cBBY612XQ7x44+8WmZsf
         6s24yuuTAv+cbaD/aabPMzmRRqyzTg6EuhZBm+R81Q+RC253dUX5ejCRAIgyRuVBBXpF
         FcMQ==
X-Gm-Message-State: AHQUAuaePoGbkCZ898YlDYqmPgdjW+PDwDa6RagR+/RG1OOvjXZHuW0K
	viWI4ALWYOT0GtIUgzfFuoEemh/ct6BVH8y5sPZK6KGxDG+a4JzEM30AKX+BYTM5wdVmFmG1G2d
	rbOODTxp3nFuZ4fMx0tr6nY8cHBiDYq7QdqTA7V0ltRrlae90QyAWyvpae7cYmNzutPQXYg0/iL
	7odBusoIAgsOP86VVMgVbCd0N1f4eEpXL0CBWQS7ZKwSM1mg+pA1l/9DlJUbTQrc/lGPbw7wSR+
	S8MeN0QFbQUPGhWssXDhYjE7aVgjO1yaS8WY04CF/06110CYmJyR2I02ms/RSeHcZvGKW2WTb3c
	KJvItzpyPHnuWrZluFoSDMp0Q/WiFZFJvHoLoZ8ishQ6kIW1W0o+/q0ncpEEi9nEVUVgoq7VD8S
	R
X-Received: by 2002:aa7:83cb:: with SMTP id j11mr18432072pfn.117.1551201518810;
        Tue, 26 Feb 2019 09:18:38 -0800 (PST)
X-Received: by 2002:aa7:83cb:: with SMTP id j11mr18431969pfn.117.1551201517525;
        Tue, 26 Feb 2019 09:18:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551201517; cv=none;
        d=google.com; s=arc-20160816;
        b=QWR4eseiRh5F+wuZRaIMS7+p4lL9E0wMZ5u3dBjCdjJAxlXJzK2nvYyfneVU3SpN7d
         I1rM23I84b83sGP90n+nCxqno97Mk3IGWudrFAUhH2fTyXW3QTnmi4SpYiveuYjKG6Em
         cO/MlRAiqx6GeM26I3btpEkkRPA0XPWr06anK2P1eBsTdw8VzX0034WSi63HHho8m4nd
         q+pW2DXwadTWdZFpGRjc4jerUIqSZO7U6oDEEKdYwfNSRpSAedh4Ncch/Zxt29FP6yfL
         ih/mQnhH+cZbts6biaVkzNyuOfLN/5cp+3qF8knkUZnUo4weJs1nzhjhfKI6hZPmenO8
         kgpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=OOLLQFuNWZNcLbvoTKuul2PBnwLCZZV2yl5Rkby6ik0=;
        b=ZpjriWbvr5EnXy8oqx6fKBZIFtbpLXFrX6CqjNSUVyb7JdtmNzMO+592Zcp3jY/OBM
         hADk516BuVo9murUGHa1NVO3fgCb+K5Hu7gHjkrKmAkP3a84KHFPhOFsGIPc8rbmYlWT
         jsvS1jA0z+OGnQBlZ2/nQWz1Jfz4Mb6qZQiCtjkM77fYZ7LgjztZZeI3PcasyghHJsot
         2kAgMhgrGs6prSNrDSbE8QzpQxIPMtVzwfI9WKAw4c6EB0lO1YP7wp3bS1HMo1Rn1K3x
         XjbmmrFwGBRc1wToye9ozYOnYwqQEX0Xg4zw7j3Bru6I2daMZ5FxFMfHEgoX9vP66dXE
         FFow==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="jKQxnJ/2";
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e3sor19669551pgs.12.2019.02.26.09.18.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 26 Feb 2019 09:18:37 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="jKQxnJ/2";
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=OOLLQFuNWZNcLbvoTKuul2PBnwLCZZV2yl5Rkby6ik0=;
        b=jKQxnJ/2x4dghTfRCCMI3Ml+fWRz4qrTqCcicLGZ011UNcos0yKVjUpXrkbq1VSVeW
         thw1sbzK7pCfkew2gQKrUI4Um5IJtqCZYZl1rRF7/8YMUzhpPVGNh8aOoaGrih+yhLcy
         LCoJSquWccU9cGAkJnes4V09W4/XvNYzxNcibfJSCuI99Gg6RPHY5pmjvUZ1DuZqFDit
         ziJwyd/cyIJEi3eTWqcjGCyQMJaZAOTApXtCDMV5IOpvOaGfw5zzajED6bFcBJNSmM3I
         YcDKPQPB7vjE9vMtguW2z7/5cxVHfa+F/TkDtfCUR0jZU+bpcDyeyF4vkjHEHWHZXTfm
         OCaA==
X-Google-Smtp-Source: AHgI3IaXslkW65Krggxq02hHR+yQdwUvqf+Fm8usmvuxZoEAwJCPo0+6iEl0097nd7G7eW84XOO0Y0ABXCeIR1f9/5I=
X-Received: by 2002:a63:d80b:: with SMTP id b11mr25226432pgh.168.1551201516864;
 Tue, 26 Feb 2019 09:18:36 -0800 (PST)
MIME-Version: 1.0
References: <cover.1550839937.git.andreyknvl@google.com> <2ad5f897-25c0-90cf-f54f-827876873a0a@intel.com>
In-Reply-To: <2ad5f897-25c0-90cf-f54f-827876873a0a@intel.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 26 Feb 2019 18:18:25 +0100
Message-ID: <CAAeHK+xCi2MxaykYWCz9mwbOzNpjrFcHex7B-VXektNNWBT+Hw@mail.gmail.com>
Subject: Re: [PATCH v10 00/12] arm64: untag user pointers passed to the kernel
To: Dave Hansen <dave.hansen@intel.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, 
	Shuah Khan <shuah@kernel.org>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Chintan Pandya <cpandya@codeaurora.org>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 22, 2019 at 11:55 PM Dave Hansen <dave.hansen@intel.com> wrote:
>
> On 2/22/19 4:53 AM, Andrey Konovalov wrote:
> > The following testing approaches has been taken to find potential issues
> > with user pointer untagging:
> >
> > 1. Static testing (with sparse [3] and separately with a custom static
> >    analyzer based on Clang) to track casts of __user pointers to integer
> >    types to find places where untagging needs to be done.
>
> First of all, it's really cool that you took this approach.  Sounds like
> there was a lot of systematic work to fix up the sites in the existing
> codebase.
>
> But, isn't this a _bit_ fragile going forward?  Folks can't just "make
> sparse" to find issues with missing untags.

Yes, this static approach can only be used as a hint to find some
places where untagging is needed, but certainly not all.

> This seems like something
> where we would ideally add an __tagged annotation (or something) to the
> source tree and then have sparse rules that can look for missed untags.

This has been suggested before, search for __untagged here [1].
However there are many places in the kernel where a __user pointer is
casted into unsigned long and passed further. I'm not sure if it's
possible apply a __tagged/__untagged kind of attribute to non-pointer
types, is it?

[1] https://patchwork.kernel.org/patch/10581535/

