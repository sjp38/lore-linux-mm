Return-Path: <SRS0=hkLx=PX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 68927C43387
	for <linux-mm@archiver.kernel.org>; Tue, 15 Jan 2019 07:06:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 23F0820883
	for <linux-mm@archiver.kernel.org>; Tue, 15 Jan 2019 07:06:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jeOEIrMp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 23F0820883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AC82A8E0003; Tue, 15 Jan 2019 02:06:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A76AA8E0002; Tue, 15 Jan 2019 02:06:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 98D7B8E0003; Tue, 15 Jan 2019 02:06:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 70D638E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 02:06:23 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id q18so1316794ioj.5
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 23:06:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=vBxTO+ik6S90VjvwhhQyOAyNkKinjn9P/JvduBA/t5Y=;
        b=PAfmiqY3qNPVQzeQLJOPrK4UopWVNCFR+q00IckQmWj5ui7FkXyuR90w62dYiXsGVo
         e3OVqR1jk58AiSI1i1lUwC6tHJU/fXJLRSwIQKM0xYl662yYIvhKvc2/F7Zg9hXdqkZR
         bhb2Y2YPHItiPbddu2u2e6HUNIIicW53jQq9uBlVqPq0DFEoMOIVgZWpN9CDrrWfPkS4
         k3w197qScVl5iIdN52K+6rmFNksDXV/8agbv1LK4ygdLiH6PMZcjfkYhnVKJg/GVazyO
         rVh8gd0f2f7YfL1hXHEfoK+lr1TzrF5CSYzEvIGVcnmBjBVulPJTQXfk4eRO5uhgO2M7
         sc9Q==
X-Gm-Message-State: AJcUukepn4kj2A+1R6KPuRob2Z59NvGwG6tZBOTB69r3SVBHDZuwWvhH
	en/FkBGUt8du5hxYSrXVpDCrTmzq9mzllvTA1UaciRxgEy277R9jfIvEjlaqbIWzTSKeeo6QdD7
	7CZFACFn4iz8O7bd3ojKZEl2NGiIj0MPeSMdO4Z/YTfe7BgI4zEcp30P1jgLMCUkvj+zuu82NUn
	0PTCOleCr9kr/rnkPk6saJjbYnMhDyhneLsvNVffk9hjdxghNVCuUS+ujscDI427wz/YhqdirUP
	J3ssTb55REAT0lId0sXSNtsTlSqOS2rC/aZgWb/wi7k6a2MgdYl7WjKeBdDC4rKw8GtKy5umhQP
	NeOzkS8rQV9MZg0g91riu2ZQHrNlc0MJBdd7tNKdOqIYpxqPoiKqBxETpEz8Oa5KGI0q7927KEF
	z
X-Received: by 2002:a05:660c:12c7:: with SMTP id k7mr1654267itd.148.1547535983163;
        Mon, 14 Jan 2019 23:06:23 -0800 (PST)
X-Received: by 2002:a05:660c:12c7:: with SMTP id k7mr1654250itd.148.1547535982445;
        Mon, 14 Jan 2019 23:06:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547535982; cv=none;
        d=google.com; s=arc-20160816;
        b=KGiR765PJN15TGiW6MlDQzJDtUpUUdnk5gdtnA1OPtQGad8pbxVSAvDogT50n2G9vb
         jndOG+pXZNdUxeiWdMJ6OLA0+wHvhtXnVysLbK590uXZJJBHwX3yYQoatHZ4fe7RQc4Y
         q4LDoxmUplKdk71eBHhOWMsEbz6vhJWRoyFiJXJcKNPJfEVM/UndPSX9IJnC/9gb6ukl
         RJTWONuik6iRJwNHQ0g3Yqa4B/EXxOQ941pFfcnh2RB69s3MMpIEli5FsK9xhFU3RXwx
         VogxyIHn9A2qZGztNIuUGBuJQ8zJ0itUWtIxCa94wIRJUVSYMdnGgXx9hjbWq92GKb8k
         hz6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=vBxTO+ik6S90VjvwhhQyOAyNkKinjn9P/JvduBA/t5Y=;
        b=N9BSyA+WAYee53AZ16Kq0fKMQEzrTPYL0yFhf6CnbWkkfYlhQKRvs13cIHURvPf/rL
         NCjpQAZT8A7FNrgzwSu4lIk/v77WCgQQQFnMmGPy+WOli9193eqpDeLUJ8grp8bvQlMz
         mYGXIaCt3BRzXwEaslFAjXxlo0k1h5M0WqTpIMIlMPFLuJtuwKwbk+yiApUFXlahyTXO
         WePyzW9/W71fmR1ZXpgs2lGA28UN+jpDgoO9ONl5yqF1E55xlVI7S4EdWqswTWGpyq5T
         300+o3T/OzYtb3V6ai4FwL1z085dV/5p/ZggZJMxqfTDhcsS41vBIIuWCasLgsYiuxn5
         ElBg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jeOEIrMp;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d142sor4228719itc.16.2019.01.14.23.06.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 Jan 2019 23:06:22 -0800 (PST)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jeOEIrMp;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=vBxTO+ik6S90VjvwhhQyOAyNkKinjn9P/JvduBA/t5Y=;
        b=jeOEIrMpgXi3/B7EW3lgvfCoRqTBFVzmSrBIFt2tpkk7CsLQC3esSVpvE24X0hK4uB
         osXXGM7O5q6Yu2NWuL6D/ZZ77ErZREpHtlOsSYWeisH5EGVdQ4CXm96ZKK54ibyXBy5N
         MPwG4FR9UT821u6+5z+QP70w3L7rtVYdT5LrwkWNMYeSKkH/lRplKQA2yfk2m9lhU/qk
         zGoOpERnzuOf9XOAkLe9KQGPCuOd98lgGz0Jb6mQQRW9Ot54eyTc5J2t01YluhmiVns5
         gUIE+OUsCABCvScUTdpBOaV2mqvTn1b5w4P7TMu9mrbacZReD2PS2NHVofzR58dR/MlV
         Dp8A==
X-Google-Smtp-Source: ALg8bN6nciu4jZVlb6o0NjOSQGyRSzWVuL2vBfcarEjVevsygaYd+FFSzu/F/XJJlih/Jj0QBVK449+HgxJ5/dlokAQ=
X-Received: by 2002:a24:3282:: with SMTP id j124mr1700100ita.173.1547535982120;
 Mon, 14 Jan 2019 23:06:22 -0800 (PST)
MIME-Version: 1.0
References: <1547183577-20309-1-git-send-email-kernelfans@gmail.com>
 <1547183577-20309-2-git-send-email-kernelfans@gmail.com> <96233c0c-940d-8d7c-b3be-d8863c026996@intel.com>
In-Reply-To: <96233c0c-940d-8d7c-b3be-d8863c026996@intel.com>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Tue, 15 Jan 2019 15:06:10 +0800
Message-ID:
 <CAFgQCTsV13JSH_S2kSQGeUa3K0s_n4LeGqhrHwBEW9DWeCWgcA@mail.gmail.com>
Subject: Re: [PATCHv2 1/7] x86/mm: concentrate the code to memblock allocator enabled
To: Dave Hansen <dave.hansen@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, 
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, 
	Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, 
	Peter Zijlstra <peterz@infradead.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, 
	Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, Chao Fan <fanc.fnst@cn.fujitsu.com>, 
	Baoquan He <bhe@redhat.com>, Juergen Gross <jgross@suse.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, 
	Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, x86@kernel.org, 
	linux-acpi@vger.kernel.org, linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190115070610.jPUvg7F6WrEew3jGV3XIkEKCZu-Zlugrcvhh1nafLPo@z>

On Tue, Jan 15, 2019 at 7:07 AM Dave Hansen <dave.hansen@intel.com> wrote:
>
> On 1/10/19 9:12 PM, Pingfan Liu wrote:
> > This patch identifies the point where memblock alloc start. It has no
> > functional.
>
> It has no functional ... what?  Effects?
>
During re-organize the code, it takes me a long time to figure out why
memblock_set_bottom_up(true) is added here, and how far can it be
deferred. And finally, I realize that it only takes effect after
e820__memblock_setup(), the point where memblock allocator can work.
So I concentrate the related code, and hope this patch can classify
this truth.

> > -     memblock_set_current_limit(ISA_END_ADDRESS);
> > -     e820__memblock_setup();
> > -
> >       reserve_bios_regions();
> >
> >       if (efi_enabled(EFI_MEMMAP)) {
> > @@ -1113,6 +1087,8 @@ void __init setup_arch(char **cmdline_p)
> >               efi_reserve_boot_services();
> >       }
> >
> > +     memblock_set_current_limit(0, ISA_END_ADDRESS, false);
> > +     e820__memblock_setup();
>
> It looks like you changed the arguments passed to
> memblock_set_current_limit().  How can this even compile?  Did you mean
> that this patch is not functional?
>
Sorry that during rebasing, merge trivial fix by mistake. I will build
against each patch.

Best regards,
Pingfan

