Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED060C43219
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 14:57:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AC755206E0
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 14:57:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hansenpartnership.com header.i=@hansenpartnership.com header.b="qaIDOuC8";
	dkim=pass (1024-bit key) header.d=hansenpartnership.com header.i=@hansenpartnership.com header.b="IIFGf7Gv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AC755206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=HansenPartnership.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4932A6B0005; Fri, 26 Apr 2019 10:57:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 443486B000C; Fri, 26 Apr 2019 10:57:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 333306B000D; Fri, 26 Apr 2019 10:57:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1642B6B0005
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 10:57:44 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id n203so2685435ywd.20
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 07:57:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:message-id:subject
         :from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=6p8CjruhjRNbBQYEm03bK5FWvpGTt1RHALQOrOT1VD4=;
        b=rLZ0MhT3T1amCvXIc5TabiEPNH4STOyvbFDSVM0isEqCTgeoIMuGopdZObshetBrw2
         3EXhuLDn73tqbtBzUgSnDuhVobtebBY3GYP71E6bAEJRp+Pg5ZEKNIIWvVGwQUmkuEbT
         HTaUoceHr4dIl7e+Hqa63afsucCVM5rsm0wUnFFWtZJ1JoJLPCLgizAqKHNR4WjTgM7I
         zx5i5eh+qMtva3jMWRrh2f+/+umLeKR4BBU4mUNsykA9+vgn18ZtwOEAgiroRNmBK2Cw
         eUAlnP5ybwrsDCy7L9RmLoeG9HfqOzVFGxLnCFqjkLYZ1j+G4v3dz3BHM/ME7cKO44gw
         qRaA==
X-Gm-Message-State: APjAAAXfNDEbPN2rpbwu0U4BSldSSjOVMkPfDvPaB+zpm84hJvnMxXn4
	D+Lh9yhv5hjDFa8b4awoxr1MLJtIDvZFsw41nFL3TmMwOx97B1+PKIxWZrFoafIDvlaLxmWIDmr
	wD4ojDi6bx6Li0mYQran+k0fj8kJXsi45anlHKp/SIRKzAFc83vadxn2wFESUEjYr6A==
X-Received: by 2002:a25:10d6:: with SMTP id 205mr37662646ybq.59.1556290663791;
        Fri, 26 Apr 2019 07:57:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwsZlOyoXKZUxk3HpVp1joVFU0XCEa5LFHF4do4R9p5YaYGcdBigod2yt1UWM/Ncog0m758
X-Received: by 2002:a25:10d6:: with SMTP id 205mr37662599ybq.59.1556290663214;
        Fri, 26 Apr 2019 07:57:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556290663; cv=none;
        d=google.com; s=arc-20160816;
        b=BVwawnwajaTX9JBD0Y6Ojorgr4qcHqhs4uhJ/MNIr459tk5sD8+xrFigs2rSsmsrJB
         M0HQeErKybsQWEAP3hSr+UF1vbxBXBR2cskZbh+3WtlTMiQPnl6PCqcnQnXnyytQjYNx
         FS1JGXfDRMWmXTnsWfXGw9QrNyh50pomYrHC7Z5GGKk6iXIhDHCRkhJPsKa7EAdtM37F
         otraFl7bU/5IJVXGfYcP4pOG6Wu5oPi4Y1tD/TE9R6u/tt7dy0I3cCEejPj0M0KTse5i
         CKOp/TZx4fM52CogFMGFuESEvoA5MV4vv54Jb416x6DQYOPIc/Xj9OG/LFxxlUQ8tTe4
         MVNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature:dkim-signature;
        bh=6p8CjruhjRNbBQYEm03bK5FWvpGTt1RHALQOrOT1VD4=;
        b=Z2MOxrqZisWd7e0PbozUfdmVbrm79hHTxeziSArB5w54NNxg9fTHoyhF+oTuGHvhOI
         JWJYeHRBEdBfrXO8cuCyWLAW/1xLNtOuPqioCBNLPI2XL2RTgrNNY5TGQCMdBcpT8nq2
         Eyp8n5hQyP2sWZskphxWQzigzIIgxKI4Zpcu0kLo7/gUhPTguRO3UvEj5ELUsbvuJLC4
         FPBq+nYyCvt2fek4OJbqu56OprEf3ewouadw8sJPk5MHHL+p8tEwrqiT6Rt5R+4YK9u3
         HSOyCgeUE9ZoX1fZJn7PWtmyNzqGtspEDflgnixmhSz63OMNq2uCOp/Hy5QrruJIPWTQ
         q7rg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=qaIDOuC8;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=IIFGf7Gv;
       spf=pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) smtp.mailfrom=James.Bottomley@hansenpartnership.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=hansenpartnership.com
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id v124si17076312ywv.383.2019.04.26.07.57.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 26 Apr 2019 07:57:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) client-ip=66.63.167.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=qaIDOuC8;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=IIFGf7Gv;
       spf=pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) smtp.mailfrom=James.Bottomley@hansenpartnership.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=hansenpartnership.com
Received: from localhost (localhost [127.0.0.1])
	by bedivere.hansenpartnership.com (Postfix) with ESMTP id 1D8068EE121;
	Fri, 26 Apr 2019 07:57:40 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=hansenpartnership.com;
	s=20151216; t=1556290660;
	bh=MZ013Ph+lwQOoeohYQwwAPYLitvi2p0CBYiqPPjHpqI=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=qaIDOuC8aei1p/7IP9m9Fe7r3xqglUB9MVs7PdBCgZ558WNyEKGsDorTWf6PNNGxB
	 BTCy/bnugUhZTtol9nQJKxUOW5moxnmy6Gtwb+BQs14FYokmStzrgIUIm+keNdtkd3
	 r5f9oNC6yUkycIj3GOuPJLi7exfOyTK4AX48QUlM=
Received: from bedivere.hansenpartnership.com ([127.0.0.1])
	by localhost (bedivere.hansenpartnership.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id hitVsonP8-dL; Fri, 26 Apr 2019 07:57:39 -0700 (PDT)
Received: from [153.66.254.194] (unknown [50.35.68.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by bedivere.hansenpartnership.com (Postfix) with ESMTPSA id 2A3368EE079;
	Fri, 26 Apr 2019 07:57:39 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=hansenpartnership.com;
	s=20151216; t=1556290659;
	bh=MZ013Ph+lwQOoeohYQwwAPYLitvi2p0CBYiqPPjHpqI=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=IIFGf7GvQu8MCRHZXr1XtGW4XmqGJGBhgBm0P/VIYkiYQnktRNLrbXtK7lNWiswf4
	 CKM8fUqVlquzGGDbVl94Z804nFWX6K13cOYwj/7elY9L73iANUBV0998IYN5LsYoUi
	 OS2d0wMqqxyLuYMsxisTCzOk+GuvidU3cUz4dVWY=
Message-ID: <1556290658.2833.28.camel@HansenPartnership.com>
Subject: Re: [RFC PATCH 2/7] x86/sci: add core implementation for system
 call isolation
From: James Bottomley <James.Bottomley@HansenPartnership.com>
To: Dave Hansen <dave.hansen@intel.com>, Mike Rapoport <rppt@linux.ibm.com>,
  linux-kernel@vger.kernel.org
Cc: Alexandre Chartre <alexandre.chartre@oracle.com>, Andy Lutomirski
 <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Dave Hansen
 <dave.hansen@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo
 Molnar <mingo@redhat.com>, Jonathan Adams <jwadams@google.com>, Kees Cook
 <keescook@chromium.org>, Paul Turner <pjt@google.com>, Peter Zijlstra
 <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, 
 linux-mm@kvack.org, linux-security-module@vger.kernel.org, x86@kernel.org
Date: Fri, 26 Apr 2019 07:57:38 -0700
In-Reply-To: <627d9321-466f-c4ed-c658-6b8567648dc6@intel.com>
References: <1556228754-12996-1-git-send-email-rppt@linux.ibm.com>
	 <1556228754-12996-3-git-send-email-rppt@linux.ibm.com>
	 <627d9321-466f-c4ed-c658-6b8567648dc6@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.6 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-04-26 at 07:46 -0700, Dave Hansen wrote:
> On 4/25/19 2:45 PM, Mike Rapoport wrote:
> > After the isolated system call finishes, the mappings created
> > during its execution are cleared.
> 
> Yikes.  I guess that stops someone from calling write() a bunch of
> times on every filesystem using every block device driver and all the
> DM code to get a lot of code/data faulted in.  But, it also means not
> even long-running processes will ever have a chance of behaving
> anything close to normally.
> 
> Is this something you think can be rectified or is there something
> fundamental that would keep SCI page tables from being cached across
> different invocations of the same syscall?

There is some work being done to look at pre-populating the isolated
address space with the expected execution footprint of the system call,
yes.  It lessens the ROP gadget protection slightly because you might
find a gadget in the pre-populated code, but it solves a lot of the
overhead problem.

James

