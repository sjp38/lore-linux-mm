Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C3930C282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 17:20:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 80AD8206BA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 17:20:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lz4JnTW0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 80AD8206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0A4BF6B0005; Wed, 17 Apr 2019 13:20:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0605B6B0006; Wed, 17 Apr 2019 13:20:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E38336B0007; Wed, 17 Apr 2019 13:20:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id A2B0F6B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 13:20:00 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id f67so16684173pfh.9
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 10:20:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=V1yIYIvLzz+BOCdxdX2gjSKybWz8E9N/6tRrpN2enDY=;
        b=Y5m4wRQLNjQZJIhXM+oGs6IErn9Qqsnhlmm8Ta9zfPZQy1xjqvw43IiKXcHfOydh8o
         pPmamPh2/WWqYdArPNieXHn/AK07vhX8Otoo2qH+hZIpM/JwaXGRoKxTfOAfuSIaaDr0
         Qw18HDje2iS4Iddo+5ivnLTT4EwoG9gggzgJroqEhITuX22hSW8Ktnl7+9qg0wMEezmX
         vEOS1XcQE6LXAuP5aqpHu9ykac52z7s4xcYgsnlY86IkW1/6rRzBYhGusoeyhwuFwBZl
         wDSBlm/XUYZGsRGDtTX1laG2/AsdgljTiQJySEgk01PMmlbUz8Tbb8QPyAdmF2VTFPM5
         guTQ==
X-Gm-Message-State: APjAAAUDd03mSllGX3auvPvtkQN9MrA8kkWpN3cBGruuE7KMXkEghF00
	f/7IRBVqnvojRmlpMFSABZYKt+GEK9wHa3ITvX4jR/2Rj1CWX77iyfQH6VMSRb6RhoGkUROvlsM
	XyA0Yn0SuEawpmubbO5TdmavDOZRvDPhBmkYdEsn0Ozc9Pt6+aAs9yb0sfMJRSHgfVA==
X-Received: by 2002:a17:902:599c:: with SMTP id p28mr27516963pli.70.1555521600179;
        Wed, 17 Apr 2019 10:20:00 -0700 (PDT)
X-Received: by 2002:a17:902:599c:: with SMTP id p28mr27516882pli.70.1555521599310;
        Wed, 17 Apr 2019 10:19:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555521599; cv=none;
        d=google.com; s=arc-20160816;
        b=DWJqR85oegI7mc8adqRJ9r0iLYyDJbkCdz0Vimx8prkSp6XPud3/s4EHKWejy3PRJZ
         lNQiczPcRGzCEwHfbzLs6fmYnuR1FT4ZWpOKevlj4J1E6knl4vTkEv0DWIJVdK0jKQE2
         fB8twUaUHHOTA3LD/7YK3lqdwvEn9pOAH4fclI2gT8gqKIsXa9F3rTytf5YiJG/NEJzZ
         zOIXvcvkuUDbhH4WtFiNRhelPOqTSxx+g4lHgMy5aAnmQDUhpQx3vJ34IFlNm+Bk+4Al
         MxsHeeFrS5hmtQpFpid8azY6g5M6IX9E8jdfy+YL4JSRFjWVDtpKLo15XJShm0vunRzH
         Tl4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=V1yIYIvLzz+BOCdxdX2gjSKybWz8E9N/6tRrpN2enDY=;
        b=In8ekuP5zt0MCskFlHvkuPRPjPHKBIkq70AqN/u43fz02gx8/vwhTW/MwxYiTpwSJR
         GhWfwekGRaSHtFD4o/k1RJdTB2tkHn1uJigihpHPAj2AusmUNG4fFib7BqwHsuKDaEkH
         etVEppeQeY0efdgwEtFjo2amq5jp5GCtsbzqzrZGLsLXEDzfdnZ3z+JXY7W5uzPiW31l
         m8MPguPWJacCnxPrpKulif/ps6qAhQUFBe8oAVbG9IBH2vGtz+bGyVT5YVnBKo2Yd99a
         HCd+uvmTT0qSlvRVtqlJLn0niJAz2gA8/oetlMavG6L5ax0gS758jK4Fmg2fT2GcnZV/
         gDmQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=lz4JnTW0;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q87sor43637182pfi.11.2019.04.17.10.19.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 10:19:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=lz4JnTW0;
       spf=pass (google.com: domain of nadav.amit@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=nadav.amit@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=V1yIYIvLzz+BOCdxdX2gjSKybWz8E9N/6tRrpN2enDY=;
        b=lz4JnTW0SxRkuzYb5nVwScOlj31C+NR7Pbf9V6itmwyvo+tcPA9xux9vHCBHlmzlf8
         l+V8GGCFjPLmvBpRzgeACiPtj6mSkfCDd56w0bYBQkYTi/I/GVwyrRB3giEJR/zpWrC4
         Ly8vw18KA3Ytm2WNNnQcY8KjOlhY9n59X1m03ngRjQ/6YOOtXsB0oAtRdnVrdBL5lghC
         QBkS95ipjK32Jj5COWARIon/mFRjh9umt56N+abO+6I5bCPJQveIPH6XghPnvqF21iIb
         6KuFUeO5O8Syhf418LaQuuqrU8N7SpRNvehZAKN9N0qsgeiSnMw38h0ltYF4duUQ5Hob
         SBzw==
X-Google-Smtp-Source: APXvYqw8tbbQTyJUpI8x5or/uOxF5UZyuqm6K8VfzwsOuau8hPR4i1Hby9IWvX82aT/ndMHLmdxiHA==
X-Received: by 2002:aa7:814e:: with SMTP id d14mr90827247pfn.101.1555521598738;
        Wed, 17 Apr 2019 10:19:58 -0700 (PDT)
Received: from [10.33.115.113] ([66.170.99.2])
        by smtp.gmail.com with ESMTPSA id b7sm149466641pfj.67.2019.04.17.10.19.56
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 10:19:57 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [RFC PATCH v9 03/13] mm: Add support for eXclusive Page Frame
 Ownership (XPFO)
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <20190417170918.GA68678@gmail.com>
Date: Wed, 17 Apr 2019 10:19:54 -0700
Cc: Khalid Aziz <khalid.aziz@oracle.com>,
 juergh@gmail.com,
 Tycho Andersen <tycho@tycho.ws>,
 jsteckli@amazon.de,
 keescook@google.com,
 Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 Juerg Haefliger <juerg.haefliger@canonical.com>,
 deepa.srinivasan@oracle.com,
 chris.hyser@oracle.com,
 tyhicks@canonical.com,
 David Woodhouse <dwmw@amazon.co.uk>,
 Andrew Cooper <andrew.cooper3@citrix.com>,
 jcm@redhat.com,
 Boris Ostrovsky <boris.ostrovsky@oracle.com>,
 iommu <iommu@lists.linux-foundation.org>,
 X86 ML <x86@kernel.org>,
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
 Dave Hansen <dave@sr71.net>,
 Borislav Petkov <bp@alien8.de>,
 "H. Peter Anvin" <hpa@zytor.com>,
 Arjan van de Ven <arjan@infradead.org>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <56A175F6-E5DA-4BBD-B244-53B786F27B7F@gmail.com>
References: <cover.1554248001.git.khalid.aziz@oracle.com>
 <f1ac3700970365fb979533294774af0b0dd84b3b.1554248002.git.khalid.aziz@oracle.com>
 <20190417161042.GA43453@gmail.com>
 <e16c1d73-d361-d9c7-5b8e-c495318c2509@oracle.com>
 <20190417170918.GA68678@gmail.com>
To: Ingo Molnar <mingo@kernel.org>
X-Mailer: Apple Mail (2.3445.102.3)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> On Apr 17, 2019, at 10:09 AM, Ingo Molnar <mingo@kernel.org> wrote:
>=20
>=20
> * Khalid Aziz <khalid.aziz@oracle.com> wrote:
>=20
>>> I.e. the original motivation of the XPFO patches was to prevent =
execution=20
>>> of direct kernel mappings. Is this motivation still present if those=20=

>>> mappings are non-executable?
>>>=20
>>> (Sorry if this has been asked and answered in previous discussions.)
>>=20
>> Hi Ingo,
>>=20
>> That is a good question. Because of the cost of XPFO, we have to be =
very
>> sure we need this protection. The paper from Vasileios, Michalis and
>> Angelos - <http://www.cs.columbia.edu/~vpk/papers/ret2dir.sec14.pdf>,
>> does go into how ret2dir attacks can bypass SMAP/SMEP in sections 6.1
>> and 6.2.
>=20
> So it would be nice if you could generally summarize external =
arguments=20
> when defending a patchset, instead of me having to dig through a PDF=20=

> which not only causes me to spend time that you probably already spent=20=

> reading that PDF, but I might also interpret it incorrectly. ;-)
>=20
> The PDF you cited says this:
>=20
>  "Unfortunately, as shown in Table 1, the W^X prop-erty is not =
enforced=20
>   in many platforms, including x86-64.  In our example, the content of=20=

>   user address 0xBEEF000 is also accessible through kernel address=20
>   0xFFFF87FF9F080000 as plain, executable code."
>=20
> Is this actually true of modern x86-64 kernels? We've locked down W^X=20=

> protections in general.

As I was curious, I looked at the paper. Here is a quote from it:

"In x86-64, however, the permissions of physmap are not in sane state.
Kernels up to v3.8.13 violate the W^X property by mapping the entire =
region
as =E2=80=9Creadable, writeable, and executable=E2=80=9D (RWX)=E2=80=94onl=
y very recent kernels
(=E2=89=A5v3.9) use the more conservative RW mapping.=E2=80=9D

