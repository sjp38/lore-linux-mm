Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=0.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65B1FC282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 17:26:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 19058206BA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 17:26:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NcvYWJCy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 19058206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE8B26B0006; Wed, 17 Apr 2019 13:26:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B99866B0007; Wed, 17 Apr 2019 13:26:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A62666B0008; Wed, 17 Apr 2019 13:26:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5CFEF6B0006
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 13:26:38 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id t10so22922453wrp.3
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 10:26:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=ns0QxnuhAfvDI+e0rO3qV1NnmRx4qtLcXwX4SEWj8w8=;
        b=q8W/ZjnGu8ehultlHLxVWW9va19HqOcqnTO1dSON31HGFK/EfKoIRhuXtDhdRV8zKg
         UiMhf9PNOl+9oJnHoGsIoAWQwIpZmvRErdjT9i1i1CbJFeQMoGFkDFwIbALBUNUoa3X6
         Ri2jhGBMdCtQf8EQg9VobsrjfGeRNh9lz7lpgh9yohM2oOiuuX2zKL/vLkJxRL50nLht
         JC6/yg517AFikSJ5aG90hm5V53SZ2B1G0nIH81UnHdeSmzbUrmMAve2mpbp7Pte2McUh
         k66ksWfWmJQjHXMvUu4J2M+BbVQ3EVtLOhA/tVpAmC8mlTaSzxkGHAh4duRuEGAdM2nm
         CAAQ==
X-Gm-Message-State: APjAAAXgwsg8/qD2UeFjgbnfax5aAOYQtR3tZbZekadsHUJLhQz53YWK
	tS91cYaJVL2SlkQ7wgFkji0KSqc5hQihSlGTlVCCcoMk2449sH/zmwSbDwcwEI4Mjso18TTudOA
	FJNm2RVaLnW3nuMb5L72aHlUFGNbhSyvO9Yyq/gvYP10ysvq+d6lr+9mVBqXN6RY=
X-Received: by 2002:a7b:cbd6:: with SMTP id n22mr34173761wmi.57.1555521997921;
        Wed, 17 Apr 2019 10:26:37 -0700 (PDT)
X-Received: by 2002:a7b:cbd6:: with SMTP id n22mr34173731wmi.57.1555521997011;
        Wed, 17 Apr 2019 10:26:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555521997; cv=none;
        d=google.com; s=arc-20160816;
        b=ny8Nhu5YvsYaJuiAUUS1wO78Ubs3Kc0nGXd7ea0h81V9c7uY6a6ezqbHJMkvcsG73Q
         irnU1Cfujwx6Ikk2MbLH+TEE2EZVugvdHD8LRXTyIRXMlcw6H9BTwXh1ddOAp0aGIJYE
         0LO2NFiU+H/+VcEB19hWTpSTmeCf2JMaQC1hvTNsXNPpJPrE+dy30G2J7DX1aCv7Fiak
         eCckObcQyNw7FiCX2rV1EN1asQ5GJ5gCxe/D++keTXQgKC/ibgImfN9W/wNrK2ODfA70
         18jApOs3ZrlfOEpUhImN4yuWqIk5ChlH50v59kDhxpnkus76qTXvoFxbpgRinSVRugxx
         U9lQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:sender:dkim-signature;
        bh=ns0QxnuhAfvDI+e0rO3qV1NnmRx4qtLcXwX4SEWj8w8=;
        b=DL+RnUNhKMqXqOtzXPHSxIFkb3yZ8uZiFjz995RA1J62bmpswqhprj0uHyxGaTeHc2
         3Lv4N9SSSo90k/GOj40aC8pQm230Kg5IzNPOjsBYvLcdsfS8GsMxwA7VmK3UJ511tjRr
         zwW2nzu34vyTwj90+jfDhtjfa2ouE8ujeqhRDPsFtEWPnP9sXwD/rTvQbUyaHfPCZDIU
         JHq216nV0XmwK6OWOhOxqhUhINgmHIDdy9OjjG6n61xojW1zSS9wL43r4X1Cju0OGoPB
         wZ7mssOrOhWSKImugPWlIkdzf8+L7AANj77qe7rJvtUpvg3TfkSFSgfs6KgfnjDRImu4
         TioA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=NcvYWJCy;
       spf=pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mingo.kernel.org@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z14sor2234568wmk.13.2019.04.17.10.26.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 10:26:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=NcvYWJCy;
       spf=pass (google.com: domain of mingo.kernel.org@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mingo.kernel.org@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=ns0QxnuhAfvDI+e0rO3qV1NnmRx4qtLcXwX4SEWj8w8=;
        b=NcvYWJCyNfLatXmVyDRxLTR3Qx/x7JgxS8jcPHCtBtiN6MPmtGAh7sebTFiQVJAXNk
         Sbm/GqYfFaqfvaPEXTOrurvDwkKnd5zlx2TBIC3kz2Q4om3TP0Y1KaPxiIdippBjXGPT
         mt//zbGrEi8KAnTquF8hj0kCkKK4+MgiTjgN9U5T632osXgyVF0kyOkokSJYhpqPWU7q
         HvdQgIN00S7lvWehKYIDllQwTC97+wEK/qsM7xgShblV1PsGd2t5GKDax19T5iQvivwv
         QGi7KKBjclQM6KMFluz3llgRlzIQ2Zeot4lykjGh7vko0CNZ/xTAD3H/14XuvK6bERiB
         TxyQ==
X-Google-Smtp-Source: APXvYqx0bXa7GoJQLXDLgeOn35F7WmZUbi0CsPk0aTEStD8EU08aO6txiY/M5Pu51pv7jSUwysUxyA==
X-Received: by 2002:a1c:495:: with SMTP id 143mr575729wme.78.1555521996663;
        Wed, 17 Apr 2019 10:26:36 -0700 (PDT)
Received: from gmail.com (2E8B0CD5.catv.pool.telekom.hu. [46.139.12.213])
        by smtp.gmail.com with ESMTPSA id x5sm65470238wrt.72.2019.04.17.10.26.34
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Apr 2019 10:26:35 -0700 (PDT)
Date: Wed, 17 Apr 2019 19:26:32 +0200
From: Ingo Molnar <mingo@kernel.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Khalid Aziz <khalid.aziz@oracle.com>, juergh@gmail.com,
	Tycho Andersen <tycho@tycho.ws>, jsteckli@amazon.de,
	keescook@google.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Juerg Haefliger <juerg.haefliger@canonical.com>,
	deepa.srinivasan@oracle.com, chris.hyser@oracle.com,
	tyhicks@canonical.com, David Woodhouse <dwmw@amazon.co.uk>,
	Andrew Cooper <andrew.cooper3@citrix.com>, jcm@redhat.com,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	iommu <iommu@lists.linux-foundation.org>, X86 ML <x86@kernel.org>,
	linux-arm-kernel@lists.infradead.org,
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>,
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
	Linux-MM <linux-mm@kvack.org>,
	LSM List <linux-security-module@vger.kernel.org>,
	Khalid Aziz <khalid@gonehiking.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Andy Lutomirski <luto@kernel.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Dave Hansen <dave@sr71.net>, Borislav Petkov <bp@alien8.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Arjan van de Ven <arjan@infradead.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [RFC PATCH v9 03/13] mm: Add support for eXclusive Page Frame
 Ownership (XPFO)
Message-ID: <20190417172632.GA95485@gmail.com>
References: <cover.1554248001.git.khalid.aziz@oracle.com>
 <f1ac3700970365fb979533294774af0b0dd84b3b.1554248002.git.khalid.aziz@oracle.com>
 <20190417161042.GA43453@gmail.com>
 <e16c1d73-d361-d9c7-5b8e-c495318c2509@oracle.com>
 <20190417170918.GA68678@gmail.com>
 <56A175F6-E5DA-4BBD-B244-53B786F27B7F@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <56A175F6-E5DA-4BBD-B244-53B786F27B7F@gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


* Nadav Amit <nadav.amit@gmail.com> wrote:

> > On Apr 17, 2019, at 10:09 AM, Ingo Molnar <mingo@kernel.org> wrote:
> > 
> > 
> > * Khalid Aziz <khalid.aziz@oracle.com> wrote:
> > 
> >>> I.e. the original motivation of the XPFO patches was to prevent execution 
> >>> of direct kernel mappings. Is this motivation still present if those 
> >>> mappings are non-executable?
> >>> 
> >>> (Sorry if this has been asked and answered in previous discussions.)
> >> 
> >> Hi Ingo,
> >> 
> >> That is a good question. Because of the cost of XPFO, we have to be very
> >> sure we need this protection. The paper from Vasileios, Michalis and
> >> Angelos - <http://www.cs.columbia.edu/~vpk/papers/ret2dir.sec14.pdf>,
> >> does go into how ret2dir attacks can bypass SMAP/SMEP in sections 6.1
> >> and 6.2.
> > 
> > So it would be nice if you could generally summarize external arguments 
> > when defending a patchset, instead of me having to dig through a PDF 
> > which not only causes me to spend time that you probably already spent 
> > reading that PDF, but I might also interpret it incorrectly. ;-)
> > 
> > The PDF you cited says this:
> > 
> >  "Unfortunately, as shown in Table 1, the W^X prop-erty is not enforced 
> >   in many platforms, including x86-64.  In our example, the content of 
> >   user address 0xBEEF000 is also accessible through kernel address 
> >   0xFFFF87FF9F080000 as plain, executable code."
> > 
> > Is this actually true of modern x86-64 kernels? We've locked down W^X 
> > protections in general.
> 
> As I was curious, I looked at the paper. Here is a quote from it:
> 
> "In x86-64, however, the permissions of physmap are not in sane state.
> Kernels up to v3.8.13 violate the W^X property by mapping the entire region
> as “readable, writeable, and executable” (RWX)—only very recent kernels
> (≥v3.9) use the more conservative RW mapping.”

But v3.8.13 is a 5+ years old kernel, it doesn't count as a "modern" 
kernel in any sense of the word. For any proposed patchset with 
significant complexity and non-trivial costs the benchmark version 
threshold is the "current upstream kernel".

So does that quote address my followup questions:

> Is this actually true of modern x86-64 kernels? We've locked down W^X
> protections in general.
>
> I.e. this conclusion:
>
>   "Therefore, by simply overwriting kfptr with 0xFFFF87FF9F080000 and
>    triggering the kernel to dereference it, an attacker can directly
>    execute shell code with kernel privileges."
>
> ... appears to be predicated on imperfect W^X protections on the x86-64
> kernel.
>
> Do such holes exist on the latest x86-64 kernel? If yes, is there a
> reason to believe that these W^X holes cannot be fixed, or that any fix
> would be more expensive than XPFO?

?

What you are proposing here is a XPFO patch-set against recent kernels 
with significant runtime overhead, so my questions about the W^X holes 
are warranted.

Thanks,

	Ingo

