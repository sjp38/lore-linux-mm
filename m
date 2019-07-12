Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8374DC742C8
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 15:17:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 54654206B8
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 15:17:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 54654206B8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E9BA58E0159; Fri, 12 Jul 2019 11:17:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E72188E00DB; Fri, 12 Jul 2019 11:17:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DAFE38E0159; Fri, 12 Jul 2019 11:17:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8905C8E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 11:17:20 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id l24so4446188wrb.0
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 08:17:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=dUrm3Ydn4da4L3iFFJKbK3HWpFnArI2Iu5wL4ttC9+0=;
        b=HydoCL0o4uWS4vrtKXXCvfcohkcoMLfI9dB03v8AQ3iH3A99fvJWhb4993f8YLy3bw
         bRqw2qcKFpPix1MZpJz567eYR/PPFbvENCiXWYU/ZJPQketSem0ZBicCnZszUU7lgB9k
         +M1sJJ+lugT1659RDwNGpoyh3xu+t/HQzNpLNihdvl9b4QU77bd3OZzaT/kBuKkCx+z1
         jggZUh22o/o1hGCsbbTv0wVd1r24/HIwBOUNm+4ohVgjmnhnhl8PTmY9XXiPG+UkvWBd
         snrrFzyj0JvNOp947BDsEAJNExCpG1APLoKdljcGNAnqwrF71fpZk6pfASxdP8vhY/bV
         E7eA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAWFFDyWJxumvPMY88g90+Y64Gt8Z/2DaJXMJQ5o7QRjgt6eACY0
	pyBctxNuTB8lhLUvjAK5eoKwPnUSchlXmQP3YoEVAdQIUQaHIs6sP0ailesGx3pI7laFUeU70bK
	///7NoyiHlLDSDRdf+ewHqSNYnaG1gsliVzAUzAUezsaJLiWwKmfpX72V+QPSgN6njg==
X-Received: by 2002:adf:da4d:: with SMTP id r13mr5687587wrl.281.1562944640027;
        Fri, 12 Jul 2019 08:17:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzwKVFA1tw1MBzw7MZj85GrPUr0Ep1oSha6tZdKtTzICD2auC5w1uc79vDj33LSKI83bth1
X-Received: by 2002:adf:da4d:: with SMTP id r13mr5687527wrl.281.1562944639209;
        Fri, 12 Jul 2019 08:17:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562944639; cv=none;
        d=google.com; s=arc-20160816;
        b=w1bRCAxQBQ9C10NBx+zsGhuBCI/51SSCl94Zm3aNnVWSrOlqVqUVGtaiA347M+vu7k
         hk5965dtuETS56wWo7Hb0YK2VD0fKDxLa8myGOqzzVpIESBa4lA/inv+f+4XX/czWjNn
         NpOKywI1CR9jMaV7mU5co3Ap/zJf5PjT+zksErsCk/1ArKnaihxzgMPSzK5/2aU3CnMp
         D7qKdLLMEhDJ5hzPEiR3dHL5nu8SQNol7Nx8E7xxqz/QO7vReKjRl8tWjiA9qm4jwDlv
         pWqrsj6jYopeVWMzbppyBO8JxHelB+ffTs6XZKtLyGgYoGcaspz84FJiqZ5Z+W2GlPNR
         Icuw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=dUrm3Ydn4da4L3iFFJKbK3HWpFnArI2Iu5wL4ttC9+0=;
        b=NVH5oiBWAFK2PWJElS1mDWoWGN7pJpi77O6mSKj0QI40LNQ4hfSl/Z8WJKWVQQpk4M
         bBU/h31/pIHask8GgH5I41uOXzEbhRrql475kJrXrem0LwPxd4mGCJ4OcfIj2/IC7hnt
         iZ64Vd9WPgjh9tuC+m2+i2q2QA3a7lPG/qQFQLObZPUniDvLGJpUJ6V9PzwngKLRShco
         Cx5lh7gCXzJdWMYZFvd4IWwX2MenJu2IoCgSTWgdKwPUIKvN7q1FuXRM7rCofq8k47bC
         +FJUq6/lcXfCo1Se+hjqpUYwNLXteLvfZKikwdaJWaiobqaHw7PcCVvQWj9aXds6Usk0
         n+Fw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a0a:51c0:0:12e:550::1])
        by mx.google.com with ESMTPS id p5si8834097wrq.214.2019.07.12.08.17.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 12 Jul 2019 08:17:19 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) client-ip=2a0a:51c0:0:12e:550::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from [5.158.153.52] (helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hlxIF-0003Mo-Lj; Fri, 12 Jul 2019 17:17:03 +0200
Date: Fri, 12 Jul 2019 17:16:58 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Peter Zijlstra <peterz@infradead.org>
cc: Alexandre Chartre <alexandre.chartre@oracle.com>, 
    Dave Hansen <dave.hansen@intel.com>, pbonzini@redhat.com, 
    rkrcmar@redhat.com, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, 
    dave.hansen@linux.intel.com, luto@kernel.org, kvm@vger.kernel.org, 
    x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
    konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com, 
    jwadams@google.com, graf@amazon.de, rppt@linux.vnet.ibm.com, 
    Paul Turner <pjt@google.com>
Subject: Re: [RFC v2 00/27] Kernel Address Space Isolation
In-Reply-To: <20190712125059.GP3419@hirez.programming.kicks-ass.net>
Message-ID: <alpine.DEB.2.21.1907121459180.1788@nanos.tec.linutronix.de>
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com> <5cab2a0e-1034-8748-fcbe-a17cf4fa2cd4@intel.com> <alpine.DEB.2.21.1907120911160.11639@nanos.tec.linutronix.de> <61d5851e-a8bf-e25c-e673-b71c8b83042c@oracle.com>
 <20190712125059.GP3419@hirez.programming.kicks-ass.net>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 12 Jul 2019, Peter Zijlstra wrote:
> On Fri, Jul 12, 2019 at 01:56:44PM +0200, Alexandre Chartre wrote:
> 
> > I think that's precisely what makes ASI and PTI different and independent.
> > PTI is just about switching between userland and kernel page-tables, while
> > ASI is about switching page-table inside the kernel. You can have ASI without
> > having PTI. You can also use ASI for kernel threads so for code that won't
> > be triggered from userland and so which won't involve PTI.
> 
> PTI is not mapping         kernel space to avoid             speculation crap (meltdown).
> ASI is not mapping part of kernel space to avoid (different) speculation crap (MDS).
> 
> See how very similar they are?
> 
> Furthermore, to recover SMT for userspace (under MDS) we not only need
> core-scheduling but core-scheduling per address space. And ASI was
> specifically designed to help mitigate the trainwreck just described.
> 
> By explicitly exposing (hopefully harmless) part of the kernel to MDS,
> we reduce the part that needs core-scheduling and thus reduce the rate
> the SMT siblngs need to sync up/schedule.
> 
> But looking at it that way, it makes no sense to retain 3 address
> spaces, namely:
> 
>   user / kernel exposed / kernel private.
> 
> Specifically, it makes no sense to expose part of the kernel through MDS
> but not through Meltdow. Therefore we can merge the user and kernel
> exposed address spaces.
> 
> And then we've fully replaced PTI.
> 
> So no, they're not orthogonal.

Right. If we decide to expose more parts of the kernel mappings then that's
just adding more stuff to the existing user (PTI) map mechanics.

As a consequence the CR3 switching points become different or can be
consolidated and that can be handled right at those switching points
depending on static keys or alternatives as we do today with PTI and other
mitigations.

All of that can do without that obscure "state machine" which is solely
there to duct-tape the complete lack of design. The same applies to that
mapping thing. Just mapping randomly selected parts by sticking them into
an array is a non-maintainable approach. This needs proper separation of
text and data sections, so violations of the mapping constraints can be
statically analyzed. Depending solely on the page fault at run time for
analysis is just bound to lead to hard to diagnose failures in the field.

TBH we all know already that this can be done and that this will solve some
of the issues caused by the speculation mess, so just writing some hastily
cobbled together POC code which explodes just by looking at it, does not
lead to anything else than time waste on all ends.

This first needs a clear definition of protection scope. That scope clearly
defines the required mappings and consequently the transition requirements
which provide the necessary transition points for flipping CR3.

If we have agreed on that, then we can think about the implementation
details.

Thanks,

	tglx

