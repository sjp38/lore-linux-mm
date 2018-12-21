Return-Path: <SRS0=s2+Z=O6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 137EBC43387
	for <linux-mm@archiver.kernel.org>; Fri, 21 Dec 2018 17:30:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BB86F218F0
	for <linux-mm@archiver.kernel.org>; Fri, 21 Dec 2018 17:30:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="mnOg5ZAs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB86F218F0
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 59B0C8E0006; Fri, 21 Dec 2018 12:30:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 54A048E0001; Fri, 21 Dec 2018 12:30:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4396D8E0006; Fri, 21 Dec 2018 12:30:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id E3B088E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 12:30:29 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id z16so2123529wrt.5
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 09:30:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=euqYl09XQoTlJRYGDaa3DGHaSNqi9kg3Krkko4vHdAw=;
        b=EcRwBMCj7hWFKS7wMy8WHLkF2fkf8ve7d2TgJh+1ZizPYY3D80qXAaYtE+d6P6TGMR
         mGyp7i2uIRzyyr73ihZuHWERDezofKLJcSzGpr6lVbY954ei/B3uCvb32AuHhzHGpKWM
         d+Lv1h17A9xrVML199hmXekJBnnNd+sZXueeh3BWo9ZuZhjBSBNKPpUweZNYae7Cqk09
         /+Iiv4juq/ho9bJSeap8t9tuq7vCgILQUTfw8BTXG5iloIT5+AZ4lY45a4OJ/IHLmgf6
         Wt94XBa7CzzOsZTtW3VnFNuvqnkj/oqePtrc7IuSDCFG+49K0XSCGwGgHNrfGfsCmOks
         9+fA==
X-Gm-Message-State: AJcUukfQ0UkNd9zo+0HPZz1L6848jzmlqS/jXnbuDBQxuoo8zgdrFdwG
	Iq1RW3Cp36OOnAraK2B89WMM17f2lbnpp9Oii1ohOmL+dOHt774FGNXAYXzH25G+LfgUlgnxtdX
	cKzryU83SBgiuahenzAK8loLVmZGREVia8NvkY3YtmM/CXB8Cl9khUYwszhvhQeVOxrmsowXv3C
	LPDISG32osDkTHpQOE0BV6n+aHFtSXEfGEka6cG2EVYkLRiev9qTv0RBdziM6IWlJMSqKNv7z1D
	HAfR3bz/c+9B2fRbhhLtM/nOp6bFEA1ozDSv5Ff2d9oaL8R1TIKmz15i7YwGa+wnLXqz0yALLwd
	o7syPP8ALOPXFTyLv7wZMSbhshGNW3PXqsiEfAAULMQvh4Pq6hXqkSSZll1JopKvTqEIoEZcLx6
	8
X-Received: by 2002:a5d:558a:: with SMTP id i10mr3387084wrv.287.1545413429513;
        Fri, 21 Dec 2018 09:30:29 -0800 (PST)
X-Received: by 2002:a5d:558a:: with SMTP id i10mr3387033wrv.287.1545413428735;
        Fri, 21 Dec 2018 09:30:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545413428; cv=none;
        d=google.com; s=arc-20160816;
        b=unsgxzg7j4vn83Xo1Uywv9iINlm1BalqwRLkCwIxVjpsdz3c3CXiDNc/lIK+Rw+wah
         Vin7OGRY15wdeSPNOFwIQAoyEukCc0jLytIpOpRnZz+55P2G9TkPbLLQvVVApYdJ8KYs
         aSEsYEcKA+MeHiXy018Mfuhon1BZ9v7LCBLeWUx5ZoLW9ghw+wWCxg2Ny/J2x83SHqxK
         DxKVSyvY0NU2VFezyR3Wr6JB1FeewXwn2DfNfWpKLPV63XC3YEKh/byUn/Qu5OBNNJy8
         eKguHmJdNp7JRnZamAIobb0cYXivWiMgCDO6rEns8X5WQTdLe2OKYvKnMl51cJqNg0UU
         2dNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=euqYl09XQoTlJRYGDaa3DGHaSNqi9kg3Krkko4vHdAw=;
        b=LvVrR20OFVB3YbqY2kANz+nbqODTxQEFaIXxYsRGqN48Z4jnu1GLHMD8hN2n6dNsMt
         ErpKOmfiaal34A/iJBVN82VtKawXDowI2TtW2sLj96w/OFqr6rdJrev0zlCtJotYvq7K
         VUe4fQPfBiXOCSAKeRB3996xl0sKTb7WyPCHWbpBK4Js+5zjTexV8CpCrzdRh+/XQB6r
         XwsB0dtS9+gxmX9sEMQ0vcv1L4jPGWogejpvIXxXhefnuzlrBE3VkrPAhVZjnu5V6I1+
         rAljxX6nWF4CyeRvEhF3GnbSRJqbXRXqsqv0C3Hmp3T02bpFSFIWTQfbXTkzHggqREcG
         FMpw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=mnOg5ZAs;
       spf=pass (google.com: domain of marcorr@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=marcorr@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x6sor9746660wro.22.2018.12.21.09.30.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Dec 2018 09:30:28 -0800 (PST)
Received-SPF: pass (google.com: domain of marcorr@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=mnOg5ZAs;
       spf=pass (google.com: domain of marcorr@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=marcorr@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=euqYl09XQoTlJRYGDaa3DGHaSNqi9kg3Krkko4vHdAw=;
        b=mnOg5ZAsi/K1onpFN8AouVU9ci+LIr4mtmvOxsGrd/lyJ/61quiatEw4Sj+eqv1oE8
         5MXKZlEw9jdjZxf8c4tGmA/P+vrkfutGzhjlfFrezIP8Mc0L51d7tqbP92tjJhGoUoEH
         fL0m2i+QUAg/8ucdUhWE1hGZIrE2LHzdHvB1OE//1gGfsYk0zmmM7wAoWPZ5TdbedsM0
         dEbMy/ZegVgOaKmnDVJPduumI//zoZ4ewnbWxdauHGIZRrYtwDaqG3WPu5+y0+7mePFx
         M5haDrZtb17P3dVJf3IRe1zzEPUjiYljKJn5oGDR22nTGODCe84WlgVPRi0Rbj2lIRXH
         klLQ==
X-Google-Smtp-Source: ALg8bN75obeU8K4l/1RAssadvbN6YgEd4Er+Z7x4qmn76WoSnMj14ZbwYsZY+ro8vpanTqSCqxjpuUPQ4GFbc/QkFXo=
X-Received: by 2002:adf:81b6:: with SMTP id 51mr3696524wra.240.1545413428081;
 Fri, 21 Dec 2018 09:30:28 -0800 (PST)
MIME-Version: 1.0
References: <20181106222009.90833-1-marcorr@google.com> <20181106222009.90833-3-marcorr@google.com>
 <fe4cff79-f24e-4eb0-a28c-ca770e3186df@redhat.com>
In-Reply-To: <fe4cff79-f24e-4eb0-a28c-ca770e3186df@redhat.com>
From: Marc Orr <marcorr@google.com>
Date: Fri, 21 Dec 2018 09:30:16 -0800
Message-ID:
 <CAA03e5FpxXXho-2XQUDbJ48a6j4-tpRqDkKPO0-QvvhCJZurdw@mail.gmail.com>
Subject: Re: [kvm PATCH v7 2/2] kvm: x86: Dynamically allocate guest_fpu
To: Paolo Bonzini <pbonzini@redhat.com>
Cc: kvm@vger.kernel.org, Jim Mattson <jmattson@google.com>, 
	David Rientjes <rientjes@google.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, 
	akpm@linux-foundation.org, rkrcmar@redhat.com, willy@infradead.org, 
	sean.j.christopherson@intel.com, dave.hansen@linux.intel.com, 
	Wanpeng Li <kernellwp@gmail.com>, Dave Hansen <dave.hansen@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181221173016.LBUmgTTmrmMQ3aOJhsnWefsiu7VuwLALSL6eJccoWS4@z>

On Fri, Dec 21, 2018 at 2:28 AM Paolo Bonzini <pbonzini@redhat.com> wrote:
>
> On 06/11/18 23:20, Marc Orr wrote:
> > +     x86_fpu_cache = kmem_cache_create_usercopy(
> > +                             "x86_fpu",
> > +                             fpu_kernel_xstate_size,
>
> This unfortunately is wrong because there are other members in struct
> fpu before the fpregs_state union.  It's enough to run a guest and then
> rmmod kvm to see slub errors which are actually caused by memory
> corruption.
>
> The right way to size it is shown in fpu__init_task_struct_size but for
> now I'll revert it to sizeof(struct fpu).  I have plans to move
> fsave/fxsave/xsave directly in KVM, without using the kernel FPU
> helpers, and actually this guest_fpu thing will come in handy for that.
> :)  Once it's done, the size of the object in the cache will be
> something like kvm_xstate_size.
>
> Paolo
>
>
> > +                             __alignof__(struct fpu),
> > +                             SLAB_ACCOUNT,
> > +                             offsetof(struct fpu, state),
> > +                             fpu_kernel_xstate_size,
> > +                             NULL);
>

Oops. Thanks for debugging, explaining and fixing!

