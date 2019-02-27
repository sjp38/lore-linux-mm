Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A966EC00319
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 18:18:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 68D0220C01
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 18:18:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=synopsys.com header.i=@synopsys.com header.b="k5of6qjc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 68D0220C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=synopsys.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F40218E0003; Wed, 27 Feb 2019 13:18:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EEF278E0001; Wed, 27 Feb 2019 13:18:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DB73E8E0003; Wed, 27 Feb 2019 13:18:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9BF1F8E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 13:18:30 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id 11so12766380pgd.19
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 10:18:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=3Izw665ZZgQEjbSE8CmRnZ9pKkiBA01cgGaMPRuksQg=;
        b=CzC8fddyXrasAo7VtUasTKw/Erw54Y5WBNRxRVZrrSBI2qV5PpNsa5o1vosBHp9lSN
         wi7rygVaVkUus8MMnRCXhEvqu5q7Y55NGsomzd3CUdkzBrE6SK1e+vrqDELvM1HY6bog
         IG+kWUoyg1vfZ2oluMW0/p/kjfgeSVrxsru/2v4/1dKj1n9oWdZR6PMRrxljaLnVxp/2
         Xodbd7p3KMf3SI4hwSUe4V9zwbdsZzb5OqT+VwcNPJ03SaNFvP7s5iV3gFqJd2+EW/nL
         pSv3h5SFTUV5C4+axV7BhtVJX0LMbJuOoGEzuBk7xqojyknz8lBV1vFXG2oBCQtBsov5
         5eww==
X-Gm-Message-State: AHQUAuaBnOkZmi+lLf6aPb7c6LGLENR4Pjl4vOMY91aZMCTlZ5rP5pp2
	CfCcrq5DZ+rlipHyxUmskSVeyBgVjyFJbj4zcr/2eMXV7NfmCGyHMHrRUlN+4ykmkvFH2+7hAb1
	j1Q780Qw8OXutyySeq8F2cfD9qx3iK/7h0phTTHRK8QhjojD+yK+SY7ROqjr4ryRbmg==
X-Received: by 2002:a62:be02:: with SMTP id l2mr3015057pff.55.1551291510295;
        Wed, 27 Feb 2019 10:18:30 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ+NPYeerdgbtRNIXXoKeA2+Gq004uEaiQ0Jv6+ToqmwCdCLKzELgLOaKqKCX/8FZLWpGiX
X-Received: by 2002:a62:be02:: with SMTP id l2mr3014969pff.55.1551291509259;
        Wed, 27 Feb 2019 10:18:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551291509; cv=none;
        d=google.com; s=arc-20160816;
        b=x2/cNgOJhG/qYx9yuFyF0O7f6lMQdWjH+nSAyCa508QlOHTR5dkBKHRE6w1Sue7tWK
         8cmi3xOzc5Kytyn+t+isDA2GZ/hy9rPC9GkXUnR8gDZFYJq/ND85pCah/FnUv7Mw9sdE
         5E/SHJ1E3tQ2fsC4rlBmV44gtBTghXFFoOyzsNjhcU757a2lJAN2k56tulneQ+/mxX7U
         r45MhMedPZLWUp35kN1phus4lyGnsDgONHuL5N0n+fT+C5rMVfIDL3uDKv4RuXtKZl/X
         4s79vmD1mn2GvsKutqATYDTEH98PlibOg1c+J00lvMo44eftEqN9+d6rjiMHJ0Ss/XZ9
         U4Rg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=3Izw665ZZgQEjbSE8CmRnZ9pKkiBA01cgGaMPRuksQg=;
        b=XHcXso1v8TxhvDK7oiLf5iM85ajmxYLzRcsuCETetNiJ+7mMZVn/n451QP9QAu2hE4
         RZkY2SUUgZevElOUWnt0OmeJx99E2j4tHi5n2ECLb8W3+Ve1191ld3ZofMBElqQLnwre
         4fA+ekYzfVkE+jQVKb+hZSXbdmS5flm7aJv+M12RnV22G2FOt02tGfzrt3KRhbjDj6UE
         XdYVhaHDDj9Wu5FAM5dm45ovU6vC/lJ5wqC4M0BOUjaD7iNlU7E6laKcd0sEsiZhPiYj
         8uQenXsX5p/UuFYnejFhm4juUPWGC7Kz6AaNrCWw2P/XDqN7OiGrFiqhmZWuea6TQA8A
         9yaw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@synopsys.com header.s=mail header.b=k5of6qjc;
       spf=pass (google.com: domain of vineet.gupta1@synopsys.com designates 198.182.47.9 as permitted sender) smtp.mailfrom=vineet.gupta1@synopsys.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=synopsys.com
Received: from smtprelay.synopsys.com (us01smtprelay-2.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id d5si15981487pls.56.2019.02.27.10.18.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Feb 2019 10:18:29 -0800 (PST)
Received-SPF: pass (google.com: domain of vineet.gupta1@synopsys.com designates 198.182.47.9 as permitted sender) client-ip=198.182.47.9;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@synopsys.com header.s=mail header.b=k5of6qjc;
       spf=pass (google.com: domain of vineet.gupta1@synopsys.com designates 198.182.47.9 as permitted sender) smtp.mailfrom=vineet.gupta1@synopsys.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=synopsys.com
Received: from mailhost.synopsys.com (dc8-mailhost1.synopsys.com [10.13.135.209])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtprelay.synopsys.com (Postfix) with ESMTPS id 6D16C24E0DA5;
	Wed, 27 Feb 2019 10:18:27 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=synopsys.com; s=mail;
	t=1551291508; bh=3Izw665ZZgQEjbSE8CmRnZ9pKkiBA01cgGaMPRuksQg=;
	h=From:To:CC:Subject:Date:References:From;
	b=k5of6qjcnGOCE4OtuX4syNNcfm+iwtEFk9QAcd4ySNtJfthcWh+Wg3RlWca/WsOVP
	 k8xz8fO/Cn1BTWUZ2Y2ASE7uzAVVal9+kgVtXEAlDPDMt5QGPlSnTXIR/xwWrCd0ki
	 yH01k1BOznXaY9OjjzjQRn08rSX/zVgw4teD4hvhPGtKB14TtyzovQRYsVyqCiPtmK
	 qsPJQbl5Wa3VJPR54SAiYzTk24F+ZPq+rYneCxVtXioAhpr5mHmVT5dbQXIDGYPk5B
	 yZQ2hBH8zd3O73ODMl9wSVGh1X6et1XThvERgZXkw0RnT37ftIXJohr4GhSVZci0aA
	 uODcwlEL/C2NA==
Received: from US01WXQAHTC1.internal.synopsys.com (us01wxqahtc1.internal.synopsys.com [10.12.238.230])
	(using TLSv1.2 with cipher AES128-SHA256 (128/128 bits))
	(No client certificate requested)
	by mailhost.synopsys.com (Postfix) with ESMTPS id BA747A005D;
	Wed, 27 Feb 2019 18:18:24 +0000 (UTC)
Received: from US01WEMBX2.internal.synopsys.com ([fe80::e4b6:5520:9c0d:250b])
 by US01WXQAHTC1.internal.synopsys.com ([::1]) with mapi id 14.03.0415.000;
 Wed, 27 Feb 2019 10:18:04 -0800
From: Vineet Gupta <vineet.gupta1@synopsys.com>
To: Steven Price <steven.price@arm.com>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>
CC: Andy Lutomirski <luto@kernel.org>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Arnd Bergmann <arnd@arndb.de>, Borislav Petkov <bp@alien8.de>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ingo Molnar <mingo@redhat.com>, James Morse <james.morse@arm.com>,
	=?iso-8859-1?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Will Deacon <will.deacon@arm.com>, "x86@kernel.org" <x86@kernel.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	"linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Mark Rutland <Mark.Rutland@arm.com>,
	"Liang,  Kan" <kan.liang@linux.intel.com>,
	Vineet Gupta <vineet.gupta1@synopsys.com>,
	"linux-snps-arc@lists.infradead.org" <linux-snps-arc@lists.infradead.org>
Subject: Re: [PATCH v3 02/34] arc: mm: Add p?d_large() definitions
Thread-Topic: [PATCH v3 02/34] arc: mm: Add p?d_large() definitions
Thread-Index: AQHUzr7PbHQ5S+UVlUyl9IbMWKnRrQ==
Date: Wed, 27 Feb 2019 18:18:03 +0000
Message-ID: <C2D7FE5348E1B147BCA15975FBA230750146437D4C@US01WEMBX2.internal.synopsys.com>
References: <20190227170608.27963-1-steven.price@arm.com>
 <20190227170608.27963-3-steven.price@arm.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.144.199.106]
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/27/19 9:06 AM, Steven Price wrote:=0A=
> walk_page_range() is going to be allowed to walk page tables other than=
=0A=
> those of user space. For this it needs to know when it has reached a=0A=
> 'leaf' entry in the page tables. This information will be provided by the=
=0A=
> p?d_large() functions/macros.=0A=
>=0A=
> For arc, we only have two levels, so only pmd_large() is needed.=0A=
>=0A=
> CC: Vineet Gupta <vgupta@synopsys.com>=0A=
> CC: linux-snps-arc@lists.infradead.org=0A=
> Signed-off-by: Steven Price <steven.price@arm.com>=0A=
=0A=
Acked-by: vineet Gupta <vgupta@synopsys.com>=0A=
=0A=
Thx,=0A=
-Vineet=0A=
=0A=

