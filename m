Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 924C8C46477
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 18:50:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 47CDB208C0
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 18:50:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Zfpt3uun"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 47CDB208C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D65728E0002; Mon, 17 Jun 2019 14:50:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D16088E0001; Mon, 17 Jun 2019 14:50:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C046C8E0002; Mon, 17 Jun 2019 14:50:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8A3828E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 14:50:38 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id a125so7559742pfa.13
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 11:50:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=YT9HuF+UAL5f5ci7H4JzJ/S6XavqO8+S9ops45crT04=;
        b=LwnMrjHVYiXd9yh4n5lF98fyPijQNJisjXdcNE+vZN4al/d8hKY9LY4fQGXq5m9Xei
         2O8poZSMzOaOcKGMrYAFHFlk8FlTaO24nv6nsPDa7wv1mSLFnQCVIFXQND4W/rqgVHSt
         0D4up9xLFPaHRSUaPrKVfd4RJdOLzf/p2qNVlj59OkQynVyoE/namIFbTE99DoapdYpI
         +TWT+epTgH8NUzX1sd8RtEmy4B+E0Y3xEo0Bmw07JS3kVWAxuw6HHmVMU6NGzkXynFbI
         uxl5kFVC+MDJ2H5T/CgGUfqUFYYNrkA+o1uwskkiCzsqYvhyVYfIG2pMkTT7UcB8+MkF
         fK8Q==
X-Gm-Message-State: APjAAAUfoIThe/JSaGk5AHFhCQfkhNwdDgodw0pB2RWJ6jsGZRa5Fe6q
	bd8gDybGAhPeH9cZR43b10t0D0QATi3OZri/ljOZgSE9p+KpzlZIEfLXsPA+eoLCKvGrdO02xgW
	MSF1Gt4wX6VWwAyfhafIA7w2E0yhIqWuqhtkAPreu1+USskPUyVpDtRo81UMidnbNJw==
X-Received: by 2002:a17:902:a60d:: with SMTP id u13mr40928192plq.144.1560797438179;
        Mon, 17 Jun 2019 11:50:38 -0700 (PDT)
X-Received: by 2002:a17:902:a60d:: with SMTP id u13mr40928128plq.144.1560797437415;
        Mon, 17 Jun 2019 11:50:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560797437; cv=none;
        d=google.com; s=arc-20160816;
        b=kPeCf9sNntkmgM9u/qUP4Lk9CQVMITxmWfUoSd72V3W0t4Hg361nxpDcEiZzRfJ3SJ
         sXcU8DRvC3hG01qg1rXATCRdgDwA+xafznLwo1lIBbY8HM5EU90V7aS2Pd5NdrlnqQUI
         wkOLsGoZ8vK7wnMHcyqjm42U460q6dN/jPv477ttppm87EBiEgPoIyvybkHgQn4v9kXV
         a8ZsC4cWVtWmsboIUohCZQnolaMUo1WJUifQ4PifUkw1Jm7nP5gZq8uarnhsrIXFGdAM
         +Jq2wXDNoREcot0OXVHdXS5KhLwc8tCMq13EYnPktGi6OkLVgcAKW7TJA3z+9VUi02qN
         YVow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=YT9HuF+UAL5f5ci7H4JzJ/S6XavqO8+S9ops45crT04=;
        b=0LmebsPv0uI7buW2kc4K9MAg61m3KtIKcvYO3JU2smrd3zFpPtToL0IV5CPlqbBadm
         ngBzzLIc9RN+S9BZG5I4gKBLOuhQ2mzeraqpdvwVJ9HGZPTOhSdg01YpVet1I4h3EPlT
         6GeLSUeBvRMsfZdAKm3g83BP+gIlYCDKpIT88S62hsbmhL/NeKUHVj/vbNCMI7droEYK
         vdODTr9+0SZDxik0qbtQKCN7azMJuTC60rQHULHw+6qiQEO77Uc1vtTfLGBWqskOP3SU
         Ps1YrT+YP2YSd3SRlKAh6EfCfRMWOuoSSkNKHHR3832oLPVPgWwROv8PnXo9c21UKlB8
         CI6A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Zfpt3uun;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id go5sor14551507plb.37.2019.06.17.11.50.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Jun 2019 11:50:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Zfpt3uun;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=YT9HuF+UAL5f5ci7H4JzJ/S6XavqO8+S9ops45crT04=;
        b=Zfpt3uunBLYcSG089usKV8UfK0qMkW9RgZ/ht+cK7fx45yQdRXzuM4k6DPI6zvCSfi
         0b3jkIINqBOHb/zU/1f0XcGlK9C4FAg1iZvHzrqz40G30DXvdJOSbiC4XdmQGerLkQoR
         aT5EgFrx3EcOeDl7CDlpQ/A7/rYmh9HJ3rnFe7W2D9/WpSraIO3SQSjJc5BPwRcg+dHw
         SPuWuixjDd2kTd8bJJKGjPMpHwnDksjI2b6kT33SjyErxJAJ+adv5BIpRJz1FUgmsg31
         WMNCDArPFaqyMrcsw7wSYB32SF083r7pR7XN3BQJ2niCYfBu5lNlOnPi4o+qmzNvSq00
         xS6w==
X-Google-Smtp-Source: APXvYqx5UAroLnXpaBq2i2aaY3z6bqvsMT+mzSSAf5PPJfwRApihHPP0h7obDCWJIslPN6lv94WgXg==
X-Received: by 2002:a17:902:2862:: with SMTP id e89mr110159490plb.258.1560797436896;
        Mon, 17 Jun 2019 11:50:36 -0700 (PDT)
Received: from [10.33.114.148] ([66.170.99.1])
        by smtp.gmail.com with ESMTPSA id x25sm12686727pfm.48.2019.06.17.11.50.35
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 11:50:36 -0700 (PDT)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.11\))
Subject: Re: [RFC 00/10] Process-local memory allocations for hiding KVM
 secrets
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <f6f352ed-750e-d735-a1c9-7ff133ca8aea@intel.com>
Date: Mon, 17 Jun 2019 11:50:34 -0700
Cc: Andy Lutomirski <luto@kernel.org>,
 Alexander Graf <graf@amazon.com>,
 Thomas Gleixner <tglx@linutronix.de>,
 Marius Hillenbrand <mhillenb@amazon.de>,
 kvm list <kvm@vger.kernel.org>,
 LKML <linux-kernel@vger.kernel.org>,
 Kernel Hardening <kernel-hardening@lists.openwall.com>,
 Linux-MM <linux-mm@kvack.org>,
 Alexander Graf <graf@amazon.de>,
 David Woodhouse <dwmw@amazon.co.uk>,
 the arch/x86 maintainers <x86@kernel.org>,
 Peter Zijlstra <peterz@infradead.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <3131CDA2-F6CF-43AC-A9FC-448DC6983596@gmail.com>
References: <20190612170834.14855-1-mhillenb@amazon.de>
 <eecc856f-7f3f-ed11-3457-ea832351e963@intel.com>
 <A542C98B-486C-4849-9DAC-2355F0F89A20@amacapital.net>
 <alpine.DEB.2.21.1906141618000.1722@nanos.tec.linutronix.de>
 <58788f05-04c3-e71c-12c3-0123be55012c@amazon.com>
 <63b1b249-6bc7-ffd9-99db-d36dd3f1a962@intel.com>
 <CALCETrXph3Zg907kWTn6gAsZVsPbCB3A2XuNf0hy5Ez2jm2aNQ@mail.gmail.com>
 <698ca264-123d-46ae-c165-ed62ea149896@intel.com>
 <CALCETrVt=X+FB2cM5hMN9okvbcROFfT4_KMwaKaN2YVvc7UQTw@mail.gmail.com>
 <5AA8BF10-8987-4FCB-870C-667A5228D97B@gmail.com>
 <f6f352ed-750e-d735-a1c9-7ff133ca8aea@intel.com>
To: Dave Hansen <dave.hansen@intel.com>
X-Mailer: Apple Mail (2.3445.104.11)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> On Jun 17, 2019, at 11:07 AM, Dave Hansen <dave.hansen@intel.com> =
wrote:
>=20
> On 6/17/19 9:53 AM, Nadav Amit wrote:
>>>> For anyone following along at home, I'm going to go off into crazy
>>>> per-cpu-pgds speculation mode now...  Feel free to stop reading =
now. :)
>>>>=20
>>>> But, I was thinking we could get away with not doing this on =
_every_
>>>> context switch at least.  For instance, couldn't 'struct =
tlb_context'
>>>> have PGD pointer (or two with PTI) in addition to the TLB info?  =
That
>>>> way we only do the copying when we change the context.  Or does =
that tie
>>>> the implementation up too much with PCIDs?
>>> Hmm, that seems entirely reasonable.  I think the nasty bit would be
>>> figuring out all the interactions with PV TLB flushing.  PV TLB
>>> flushes already don't play so well with PCID tracking, and this will
>>> make it worse.  We probably need to rewrite all that code =
regardless.
>> How is PCID (as you implemented) related to TLB flushing of kernel =
(not
>> user) PTEs? These kernel PTEs would be global, so they would be =
invalidated
>> from all the address-spaces using INVLPG, I presume. No?
>=20
> The idea is that you have a per-cpu address space.  Certain kernel
> virtual addresses would map to different physical address based on =
where
> you are running.  Each of the physical addresses would be "owned" by a
> single CPU and would, by convention, never use a PGD that mapped an
> address unless that CPU that "owned" it.
>=20
> In that case, you never really invalidate those addresses.

I understand, but as I see it, this is not related directly to PCIDs.

