Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76BBBC7618F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 08:28:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 449EA205F4
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 08:28:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 449EA205F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D5F586B000E; Mon, 15 Jul 2019 04:28:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE96B6B0010; Mon, 15 Jul 2019 04:28:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B64736B0266; Mon, 15 Jul 2019 04:28:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 619436B000E
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 04:28:29 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id v125so3747501wme.5
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 01:28:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=ZI59Obl45UF1mQBOMQqzF1+nbTJngjjz72dAyoLdS2I=;
        b=t6zkvbPh9WgXfi5IqeQ2JTemrFBayOqKnRj6HmeipR03PuZT0Y138Q1QchsslNUXsy
         q3aCk+dKy1B8J15z0FVtrM8dN8m9kVAfUI2bDHXWpEy8TenecjDWanLKp3MF9G7XCKOZ
         IwWVliSg0HkAk9eLCH9qdv5oe3hvap1dwqD9gUli7L7iK97gOVrzgu+65VSlz1idO15I
         Opb+fKq9o+kNXRNFQL6VrsZtLxL0qnHFvKpDaPJdgyQUoqrJYLZj3gcH8gqay9jzes4M
         s4SNa7bA5IGJWpGovKh8pCDtd4aIKovBW+ePMSSMHwkAoivLn8jcSPZ524YgrpGZK/qu
         c13Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAV1g5VGJdppDa/sIFRg/gGtLxMJ4DoxObUWYo9QlV+Fdp9Pa7Dj
	8hnrF9WKxXl86Y/CKGtLz4TydkCBvCDTJTTRN5Sjsw1elCBNXBKniF8CaaJmHKBThYM3tMtgXmb
	WbIh7MqVZOW13GL/QvNPLVSL8FKDIwBGUXHH/DLZPsZ6D3tfCRffbFNWwnLypfTGwuA==
X-Received: by 2002:a1c:f914:: with SMTP id x20mr13716181wmh.142.1563179308841;
        Mon, 15 Jul 2019 01:28:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy3G9d2yUqI1XMaEcYqPCHuG6zECRsjtDa/q25xE7JDeR+B0KQiHzT+UqqDSAepf1ZphbRj
X-Received: by 2002:a1c:f914:: with SMTP id x20mr13716092wmh.142.1563179308056;
        Mon, 15 Jul 2019 01:28:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563179308; cv=none;
        d=google.com; s=arc-20160816;
        b=KNXRQNms7SmoPm5GdBLGeAo2WRQQZjrMtbWl1qUE64fZPiWIKpIYbHR9V2pGygpvT0
         gTeSaARCSvRixfYrZGIxf8LtL30RKOVTY/KWWqzaZLjL0enByDBUbNCwRw/NN61bUTBs
         pi6DxHsU69dOVi8peJ6a1UttzUQi4ZGNRS+hS6AxENRD48pGOwAY+vKEfw7GC9Gp+P9L
         TGznoUYHE8//IMHJ803EjI+1KaH8MS053J7tcQKqNDDaBmcAXbWf4D9rdZhYLL/XaKvf
         ibfWKwUNcR4+/lBAcx7/xuL/78m4Pp7k6XJ4U2t5rJxtTjKEPP+U+kMf+HSHWZpeGhF1
         nYZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=ZI59Obl45UF1mQBOMQqzF1+nbTJngjjz72dAyoLdS2I=;
        b=F61lDZ8USMN4MSk1Ce2cp+zG6dRwYdI0cF2PnFtJ6MhACkntj0zgtnyrkexqZ75xUy
         mVttWjleks/gxC91/EUhZ+LSJl0FQP5c6zmCllI7Ko/VxjuPr5U37pOx+4r4XqUkxhe5
         gdJGuleWKDHJtk6TBCXDB4qwcmBS2zLT2t+FfBPSJbNP3kvGc8spSW8qLZ1mxb35jzvw
         bXWZKZnLueIXF/7YnQGk3RSeRAXqFctKxrg0M4D2VxuDFVeNOXj/bBPXSBGK2TuhweVg
         RyJG/PU/ctLVXeggnFehFkFAuewD7B14lX72pDLqDkMTcsSAny3jwVH6l2RHly+B6aNv
         lwkA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a0a:51c0:0:12e:550::1])
        by mx.google.com with ESMTPS id o143si13746648wme.57.2019.07.15.01.28.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 15 Jul 2019 01:28:28 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) client-ip=2a0a:51c0:0:12e:550::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from pd9ef1cb8.dip0.t-ipconnect.de ([217.239.28.184] helo=nanos)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hmwLE-0005Ij-RB; Mon, 15 Jul 2019 10:28:12 +0200
Date: Mon, 15 Jul 2019 10:28:11 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Alexandre Chartre <alexandre.chartre@oracle.com>
cc: Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, 
    pbonzini@redhat.com, rkrcmar@redhat.com, mingo@redhat.com, bp@alien8.de, 
    hpa@zytor.com, dave.hansen@linux.intel.com, luto@kernel.org, 
    kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org, konrad.wilk@oracle.com, 
    jan.setjeeilers@oracle.com, liran.alon@oracle.com, jwadams@google.com, 
    graf@amazon.de, rppt@linux.vnet.ibm.com, Paul Turner <pjt@google.com>
Subject: Re: [RFC v2 00/27] Kernel Address Space Isolation
In-Reply-To: <fd98f388-1080-ff9e-1f9a-b089272c0037@oracle.com>
Message-ID: <alpine.DEB.2.21.1907151026190.1669@nanos.tec.linutronix.de>
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com> <5cab2a0e-1034-8748-fcbe-a17cf4fa2cd4@intel.com> <alpine.DEB.2.21.1907120911160.11639@nanos.tec.linutronix.de> <61d5851e-a8bf-e25c-e673-b71c8b83042c@oracle.com>
 <20190712125059.GP3419@hirez.programming.kicks-ass.net> <alpine.DEB.2.21.1907121459180.1788@nanos.tec.linutronix.de> <3ca70237-bf8e-57d9-bed5-bc2329d17177@oracle.com> <alpine.DEB.2.21.1907122059430.1669@nanos.tec.linutronix.de>
 <fd98f388-1080-ff9e-1f9a-b089272c0037@oracle.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Linutronix-Spam-Score: -1.0
X-Linutronix-Spam-Level: -
X-Linutronix-Spam-Status: No , -1.0 points, 5.0 required,  ALL_TRUSTED=-1,SHORTCIRCUIT=-0.0001
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Alexandre,

On Mon, 15 Jul 2019, Alexandre Chartre wrote:
> On 7/12/19 9:48 PM, Thomas Gleixner wrote:
> > As I said before, come up with a list of possible usage scenarios and
> > protection scopes first and please take all the ideas other people have
> > with this into account. This includes PTI of course.
> > 
> > Once we have that we need to figure out whether these things can actually
> > coexist and do not contradict each other at the semantical level and
> > whether the outcome justifies the resulting complexity.
> > 
> > After that we can talk about implementation details.
> 
> Right, that makes perfect sense. I think so far we have the following
> scenarios:
> 
>  - PTI
>  - KVM (i.e. VMExit handler isolation)
>  - maybe some syscall isolation?

Vs. the latter you want to talk to Paul Turner. He had some ideas there.

> I will look at them in more details, in particular what particular
> mappings they need and when they need to switch mappings.
> 
> And thanks for putting me back on the right track.

That's what maintainers are for :)

Thanks,

	tglx

