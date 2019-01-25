Return-Path: <SRS0=o7Ai=QB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7DFD2C282C0
	for <linux-mm@archiver.kernel.org>; Fri, 25 Jan 2019 21:20:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2C9EF2184C
	for <linux-mm@archiver.kernel.org>; Fri, 25 Jan 2019 21:20:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="gYE31XaQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2C9EF2184C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BB9C58E00F2; Fri, 25 Jan 2019 16:20:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B66988E00EE; Fri, 25 Jan 2019 16:20:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A569A8E00F2; Fri, 25 Jan 2019 16:20:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4C3FB8E00EE
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 16:20:12 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id d6so4174416wrm.19
        for <linux-mm@kvack.org>; Fri, 25 Jan 2019 13:20:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=4AuShI/ZLMzIuyIFpWIZYV2dIaJN3nI2cO3Hf3dXoPA=;
        b=RQNzVvzVrgqjbnFTDbFjay9QIP2+DECr0oaPcme8zz4wtGWPWXyTChVFqKiSJiOn7N
         VvzLsTxmUsWxgJBG3/Xbtc6GUXjqghbPrNyemfQFi62umpa9mB1Xj+YkRtk2qBDFjD+R
         4qyB0IAoaD86db1UqMb0eY9ksY53f5k8Jv0XSwKXl6WDjQ/9QtoiQ+F0Nd2w11wbcntM
         0daBzur/TeLBTDhtkQLuK/hKas4/mgLOF8MOwCRvM3WQ4WLzQzbR++w8tCG6dZEOvbC4
         Fi6+ozlRxbDNNXFYB0yoaBoXvT7TPyGpEKNQ/8Sl+khxmDlspJPN3MIaoG4oCYtC8rxS
         WVdg==
X-Gm-Message-State: AJcUukcFkMKLn/VziUSSoPYf7EQeULB+YE8eaeceQ30skKY6ZLbp2K7Z
	TixA6QxFi0O7RkZTXw7eMldKqxC6ekKay7s0X4amO4/DBz9bH7K1v+SKK4uBPPw15lTocWbcxyl
	9NUIkTssZkRElVRSgBFMKjySdRQaMAtrGguRpW3uK/F5+n2WpUm9Kw1gMX1WgKxSrS4QAC4aB70
	dzopi+FVdp3Xed6acOx4F1bSU/V/UFl7MKCm6/c0sN6JUOA9mEUDKYiIlr58KweaIlFOdg9UNcX
	bvKRnk/9RUvflC8geczoQ9z/AxuPpwwrAYOFho0QmdMKati9SJsGlKa6FX4UCOlR7DAHt4hqLSa
	BXSYFiSZWDFBLRzrSn4tnxoiGAUbhJbtUVgSYYoOXwVdlYyvOHDfyg00XsroOJ8NnkY7BZ6ia6F
	F
X-Received: by 2002:a1c:3c06:: with SMTP id j6mr7592127wma.27.1548451211783;
        Fri, 25 Jan 2019 13:20:11 -0800 (PST)
X-Received: by 2002:a1c:3c06:: with SMTP id j6mr7592085wma.27.1548451211016;
        Fri, 25 Jan 2019 13:20:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548451211; cv=none;
        d=google.com; s=arc-20160816;
        b=JmZzxv0LVB1aegDkFJBZk1x4LmR/rdqHf0SSiz6HvJrF8Zqygc6u/xx5G60Po1b2S6
         gC3oDxI6WzvxenIAasTsvjgXCqx+VqLVnDlMgKme6xt/7rp3srsZDP9lCgt0LWm5RS2R
         aHX39uSii2Q16VcFa1+j/jI9lM3Svn3/udrynegg/eomejxmt9N6pbZeKeOB4dnktbV0
         ddg7ujy5bHrBAXwDhFwGTsyRe3/hVANCQGdAexNH8ssEpwtSkaAb1dl+4nXizs0vdCge
         Aqlga6cUO8akbBpNPq72MgRqRS3RzDb+RsjQnW5bPhzhp8Cb+ZdfL9n9uKlYF2qwzPbD
         mDVQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=4AuShI/ZLMzIuyIFpWIZYV2dIaJN3nI2cO3Hf3dXoPA=;
        b=RZNGLx4yvsquHOTdODX/ujm4kTBt04+vncCI6X6OqvJHJCjNZvoSnEH313uD1Qc5v+
         dwqk4HMh345chETagkn6ddiN45S5rXEJLxIKzfwIY3RbBZ1S1h/EnNv74aoJBrs7RLla
         eiAh4fvBunRMwd1gvpGitR3XZUdhvesSXgMdBXFZYYtklUezgH58JMkbu8T3k/BD6LTf
         80mY9bGg88TDDWv5Y7iCOAOjLHH8LRh46n+0lu97kuI7Ogm1Arp6TTGYb58fniDIX/tf
         q4Xg/omzPbaIIJIePPR3rZrckB8zLrB55OdmWop9z0AsONRMFckdPX2OceK2z0m1mzet
         GQBg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=gYE31XaQ;
       spf=pass (google.com: domain of bhelgaas@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bhelgaas@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f20sor41015939wml.10.2019.01.25.13.20.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 25 Jan 2019 13:20:11 -0800 (PST)
Received-SPF: pass (google.com: domain of bhelgaas@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=gYE31XaQ;
       spf=pass (google.com: domain of bhelgaas@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bhelgaas@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=4AuShI/ZLMzIuyIFpWIZYV2dIaJN3nI2cO3Hf3dXoPA=;
        b=gYE31XaQs/N6mpZngKb6iRa2tcC954UOspCPeBL1CCs5J73VQJVLS4zC9ObIn6AcWf
         hrWTdIQHRxqZmWDht1oj6dtg6Dd6wtWyZG/g9Q7uTjhqdczsjQ5O0JErgtq0mOM20Ess
         cZCUWI7/t2VcU7+8J3AxuFvam5Sx0zrxr0LIll2gn5hSTC/jioH4xAfZVzturBI74cWP
         GYK+gg6h0qfj2JqkuwYXyFIwdB4ig5zHicIbNOJZHclTBW5KDvxPdOX/TkuAPlNiDNst
         kUspTcHJMjAIHByL8yu91MUe7/A7oFMH6y4sMflkzVfuZC++sCDgGK9hVrYXX6YbjB0Z
         PAlg==
X-Google-Smtp-Source: ALg8bN6EdE6TpDEV7m3+3V8X9LXezFN+6KYlM3bDM8zvOhfMdVlhxvm8+vry9ShrZwpuRdrUVENiKew7WK/Xge2rXpA=
X-Received: by 2002:a1c:5984:: with SMTP id n126mr7962569wmb.62.1548451210486;
 Fri, 25 Jan 2019 13:20:10 -0800 (PST)
MIME-Version: 1.0
References: <20190124231441.37A4A305@viggo.jf.intel.com> <20190124231442.EFD29EE0@viggo.jf.intel.com>
 <CAErSpo7kMjfi-1r8ZyGbheWzo+JCFkDZ1zpVhyNV7VVy8NOV7g@mail.gmail.com> <4898e064-5298-6a82-83ea-23d16f3dfb3d@intel.com>
In-Reply-To: <4898e064-5298-6a82-83ea-23d16f3dfb3d@intel.com>
From: Bjorn Helgaas <bhelgaas@google.com>
Date: Fri, 25 Jan 2019 15:19:58 -0600
Message-ID:
 <CAErSpo5pAQs-SJRKc-ie15zpSqf9FsPWnHeSpggU-EeZDg=AYQ@mail.gmail.com>
Subject: Re: [PATCH 1/5] mm/resource: return real error codes from walk failures
To: Dave Hansen <dave.hansen@intel.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Dan Williams <dan.j.williams@intel.com>, 
	Dave Jiang <dave.jiang@intel.com>, zwisler@kernel.org, vishal.l.verma@intel.com, 
	thomas.lendacky@amd.com, Andrew Morton <akpm@linux-foundation.org>, mhocko@suse.com, 
	linux-nvdimm@lists.01.org, linux-mm@kvack.org, 
	Huang Ying <ying.huang@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, 
	Borislav Petkov <bp@suse.de>, baiyaowei@cmss.chinamobile.com, Takashi Iwai <tiwai@suse.de>, 
	Jerome Glisse <jglisse@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, 
	Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190125211958.N31Cy98HIZ0Z2o3SNfC6pN_imQ6Elu-raupZEQTMSAI@z>

On Fri, Jan 25, 2019 at 3:10 PM Dave Hansen <dave.hansen@intel.com> wrote:
>
> On 1/25/19 1:02 PM, Bjorn Helgaas wrote:
> >> @@ -453,7 +453,7 @@ int walk_system_ram_range(unsigned long
> >>         unsigned long flags;
> >>         struct resource res;
> >>         unsigned long pfn, end_pfn;
> >> -       int ret = -1;
> >> +       int ret = -EINVAL;
> > Can you either make a similar change to the powerpc version of
> > walk_system_ram_range() in arch/powerpc/mm/mem.c or explain why it's
> > not needed?  It *seems* like we'd want both versions of
> > walk_system_ram_range() to behave similarly in this respect.
>
> Sure.  A quick grep shows powerpc being the only other implementation.
> I'll just add this hunk:
>
> > diff -puN arch/powerpc/mm/mem.c~memory-hotplug-walk_system_ram_range-returns-neg-1 arch/powerpc/mm/mem.c
> > --- a/arch/powerpc/mm/mem.c~memory-hotplug-walk_system_ram_range-returns-neg-1  2019-01-25 12:57:00.000004446 -0800
> > +++ b/arch/powerpc/mm/mem.c     2019-01-25 12:58:13.215004263 -0800
> > @@ -188,7 +188,7 @@ walk_system_ram_range(unsigned long star
> >         struct memblock_region *reg;
> >         unsigned long end_pfn = start_pfn + nr_pages;
> >         unsigned long tstart, tend;
> > -       int ret = -1;
> > +       int ret = -EINVAL;
>
> I'll also dust off the ol' cross-compiler and make sure I didn't
> fat-finger anything.

Sounds good.  Then add my

Reviewed-by: Bjorn Helgaas <bhelgaas@google.com>

