Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B50AFC10F14
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 13:34:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7CB652077C
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 13:34:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7CB652077C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 19C476B0003; Tue, 23 Apr 2019 09:34:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 14D096B0006; Tue, 23 Apr 2019 09:34:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 013F96B0007; Tue, 23 Apr 2019 09:34:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id AA10E6B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 09:34:44 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id g18so11820928wrs.17
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 06:34:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=FI5QWZjiAYXqsEQkJdumsZm7TZ1OoUuyoIjnnABex7Q=;
        b=ad5kiM33mKlp7ZdbOVDewI+5mx8OLQH0HNu8x/W1pubuaCpfUo+maABhmIUuGEIexH
         mYFTrwgVFcmhXChw6S7fIT+/Jv20fEPcpy6yP4gVndZe3L5vWYo4/eG/2NUq4zmzeAmk
         JU8eQkTzTNppmtG+bNqf0EuKoLPcohKrRfXfGVdWiS78S5FRU24Kzr+SuYMXHmkrXTIe
         rDj/jshevEB4hSwQgQWV2lkMg4eqaO2k7bH6otgXbKraIAaWU0vKizBR6KMFiB2RE4B9
         hz0RzdBK1gxxXev/1YBa+saF3F40OKAhpQoYsfEnmek7/ST4yFGKI3SYo8+VkNEB3UTz
         D2+w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAU4ctfYoIqFQ+HgdPKCsrqkmD2k+vya0srym7E5szcR4EV8b9kh
	uolPCVCY5FdNaF+pDs+4k58kofVTfcdl8vH84rkDUO2fjK/ivu9HQxKLy98bOiv9lR8OxnEhLxF
	cn6mJ8xUIqOqHywxBi3vrCcrHmw9u4L7iwcHlDxg4mNmm/RESksZgclWOwcdpO+/lDQ==
X-Received: by 2002:a7b:cd95:: with SMTP id y21mr2253667wmj.29.1556026484250;
        Tue, 23 Apr 2019 06:34:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqypT0R+/fbUTeC9fJUs/0Kv1A/0OXN0vZ4++i2oz9bTREeqemXaSnHg5caPPGAEatGVWTrC
X-Received: by 2002:a7b:cd95:: with SMTP id y21mr2253591wmj.29.1556026483042;
        Tue, 23 Apr 2019 06:34:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556026483; cv=none;
        d=google.com; s=arc-20160816;
        b=dOZy1GnezdwbRMvqwSTMxJ6AohLLVYLtKbD5dNR5fC+Ewe72QdOF2R/ciRvN6w6996
         sWE2ySlD34hrR0vUSa2JznJFu+EIsHIcwFLXsaGQ6WyfYu0nD0XVHiOgicvJv621K3Bg
         lGRaNWLRGzNyXjaFdOU1Yq5xPtK5AILa7x/XMlf93L0f9+7/5SU1jU5FfP8L2vHLYS/q
         yg+IL1egtQ30mcs2RUR0VT6HrCkqVrjLiM4Trim06i48t95zCCev1XyiNDXAYLKbFJRS
         E0SgNhr5LHF0/tRYYWPTcJvdtP93NAa6O6Tsvbhm11gSgLjrvS7mtTr1qVwpE3Q92nM+
         +xRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=FI5QWZjiAYXqsEQkJdumsZm7TZ1OoUuyoIjnnABex7Q=;
        b=XkpKh0TkVewqO9+STL7GLCWwf2K+1yHvuoaneff+aC8TNaCn809oWp8HZ+0LBBPDn+
         LJwU2LawQuejNTXCQYYRF/tKDLxsIyN7CxdcZNgOxTkI4EFtz4GxXR4AL090NA59uwJz
         XD0t6IAQ3lFBly5F0zMmoIbyyc/fv2bhuyuF438NGeMjrPKxTBt9XmtlyZs1FWmVpxBG
         v5zblKAg3i34QMOJTF3br3l9iCgnAm3GMCdjEBObkH5uS/c1X4ZwBLRj/yc4G0uLtyMf
         vB2xeJ4dv3xHJhIIThWJWggQy3wBQYOJp8t430WJ8kJPIR45eyIJYEJOnHoI/pIMQhUn
         nHTA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id b14si12318577wrr.99.2019.04.23.06.34.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 23 Apr 2019 06:34:43 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from p5de0b374.dip0.t-ipconnect.de ([93.224.179.116] helo=nanos)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hIvZ0-0007x3-5X; Tue, 23 Apr 2019 15:34:22 +0200
Date: Tue, 23 Apr 2019 15:34:14 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
cc: Michael Ellerman <mpe@ellerman.id.au>, 
    Dave Hansen <dave.hansen@linux.intel.com>, 
    LKML <linux-kernel@vger.kernel.org>, rguenther@suse.de, mhocko@suse.com, 
    vbabka@suse.cz, luto@amacapital.net, x86@kernel.org, 
    Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, 
    stable@vger.kernel.org
Subject: Re: [PATCH] x86/mpx: fix recursive munmap() corruption
In-Reply-To: <6718ede2-1fcb-1a8f-a116-250eef6416c7@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.21.1904231533190.9956@nanos.tec.linutronix.de>
References: <20190401141549.3F4721FE@viggo.jf.intel.com> <alpine.DEB.2.21.1904191248090.3174@nanos.tec.linutronix.de> <87d0lht1c0.fsf@concordia.ellerman.id.au> <6718ede2-1fcb-1a8f-a116-250eef6416c7@linux.vnet.ibm.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="8323329-995733783-1556026462=:9956"
X-Linutronix-Spam-Score: -1.0
X-Linutronix-Spam-Level: -
X-Linutronix-Spam-Status: No , -1.0 points, 5.0 required,  ALL_TRUSTED=-1,SHORTCIRCUIT=-0.0001
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-995733783-1556026462=:9956
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT

On Tue, 23 Apr 2019, Laurent Dufour wrote:
> Le 20/04/2019 à 12:31, Michael Ellerman a écrit :
> > Thomas Gleixner <tglx@linutronix.de> writes:
> > > Aside of that the powerpc variant looks suspicious:
> > > 
> > > static inline void arch_unmap(struct mm_struct *mm,
> > >                                unsigned long start, unsigned long end)
> > > {
> > >   	if (start <= mm->context.vdso_base && mm->context.vdso_base < end)
> > >                  mm->context.vdso_base = 0;
> > > }
> > > 
> > > Shouldn't that be:
> > > 
> > >   	if (start >= mm->context.vdso_base && mm->context.vdso_base < end)
> > > 
> > > Hmm?
> > 
> > Yeah looks pretty suspicious. I'll follow-up with Laurent who wrote it.
> > Thanks for spotting it!
> 
> I've to admit that I had to read that code carefully before answering.
> 
> There are 2 assumptions here:
>  1. 'start' and 'end' are page aligned (this is guaranteed by __do_munmap().
>  2. the VDSO is 1 page (this is guaranteed by the union vdso_data_store on
> powerpc).
> 
> The idea is to handle a munmap() call surrounding the VDSO area:
>       | VDSO |
>  ^start         ^end
> 
> This is covered by this test, as the munmap() matching the exact boundaries of
> the VDSO is handled too.
> 
> Am I missing something ?

Well if this is the intention, then you missed to add a comment explaining it :)

Thanks,

	tglx
--8323329-995733783-1556026462=:9956--

