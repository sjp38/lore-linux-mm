Return-Path: <SRS0=B4NV=XI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B4216C49ED7
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 10:01:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6BDD720678
	for <linux-mm@archiver.kernel.org>; Fri, 13 Sep 2019 10:01:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="Sqj8nI8N"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6BDD720678
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 136616B0005; Fri, 13 Sep 2019 06:01:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0BFA46B0006; Fri, 13 Sep 2019 06:01:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E7C636B0007; Fri, 13 Sep 2019 06:01:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0096.hostedemail.com [216.40.44.96])
	by kanga.kvack.org (Postfix) with ESMTP id C415C6B0005
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 06:01:05 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 5E0CF81CB
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 10:01:05 +0000 (UTC)
X-FDA: 75929454090.09.alley89_7dd7817c29240
X-HE-Tag: alley89_7dd7817c29240
X-Filterd-Recvd-Size: 5594
Received: from pegase1.c-s.fr (pegase1.c-s.fr [93.17.236.30])
	by imf07.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 13 Sep 2019 10:01:04 +0000 (UTC)
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 46VB3f0pVyz9tyjW;
	Fri, 13 Sep 2019 12:01:02 +0200 (CEST)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=Sqj8nI8N; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id wR-kri8FtY2Q; Fri, 13 Sep 2019 12:01:02 +0200 (CEST)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 46VB3d6fTQz9tyjG;
	Fri, 13 Sep 2019 12:01:01 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1568368861; bh=2ALza02n3A6CEg96aj5aMUr3JRGvxRxQLYEMFbFE/UU=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=Sqj8nI8NzbdvtlrbtrCYNcrM/TyIHT3s84kxgzLuc1bHrWIX3+Flnk1NoUeSpiScl
	 UtPpympvmV9LviqGRUz/Z7JinvogKFhxB4Hnk01VKvvK3cYgxdyYZdocRhBX7zGS2q
	 RYCcqoehg9GVxm+zOPGaVX3kpe6owDPMAy/ACXJk=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id F0DC88B982;
	Fri, 13 Sep 2019 12:01:02 +0200 (CEST)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id fVVtef9u6zrS; Fri, 13 Sep 2019 12:01:02 +0200 (CEST)
Received: from [172.25.230.101] (po15451.idsi0.si.c-s.fr [172.25.230.101])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 95ADA8B958;
	Fri, 13 Sep 2019 12:01:02 +0200 (CEST)
Subject: Re: [PATCH V2 2/2] mm/pgtable/debug: Add test validating architecture
 page table helpers
To: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
 Vlastimil Babka <vbabka@suse.cz>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Thomas Gleixner <tglx@linutronix.de>, Mike Rapoport
 <rppt@linux.vnet.ibm.com>, Jason Gunthorpe <jgg@ziepe.ca>,
 Dan Williams <dan.j.williams@intel.com>,
 Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@kernel.org>,
 Mark Rutland <mark.rutland@arm.com>, Mark Brown <broonie@kernel.org>,
 Steven Price <Steven.Price@arm.com>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Masahiro Yamada <yamada.masahiro@socionext.com>,
 Kees Cook <keescook@chromium.org>,
 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
 Matthew Wilcox <willy@infradead.org>,
 Sri Krishna chowdary <schowdary@nvidia.com>,
 Dave Hansen <dave.hansen@intel.com>,
 Russell King - ARM Linux <linux@armlinux.org.uk>,
 Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>,
 "David S. Miller" <davem@davemloft.net>, Vineet Gupta <vgupta@synopsys.com>,
 James Hogan <jhogan@kernel.org>, Paul Burton <paul.burton@mips.com>,
 Ralf Baechle <ralf@linux-mips.org>,
 "Kirill A . Shutemov" <kirill@shutemov.name>,
 Gerald Schaefer <gerald.schaefer@de.ibm.com>,
 linux-snps-arc@lists.infradead.org, linux-mips@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org,
 linux-kernel@vger.kernel.org
References: <1568268173-31302-1-git-send-email-anshuman.khandual@arm.com>
 <1568268173-31302-3-git-send-email-anshuman.khandual@arm.com>
 <ab0ca38b-1e4f-b636-f8b4-007a15903984@c-s.fr>
 <502c497a-9bf1-7d2e-95f2-cfebcd9cf1d9@arm.com>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Message-ID: <95ed9d92-dd43-4c45-2e52-738aed7f2fb5@c-s.fr>
Date: Fri, 13 Sep 2019 12:01:00 +0200
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.9.0
MIME-Version: 1.0
In-Reply-To: <502c497a-9bf1-7d2e-95f2-cfebcd9cf1d9@arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



Le 13/09/2019 =C3=A0 11:02, Anshuman Khandual a =C3=A9crit=C2=A0:
>=20
>>> +#if !defined(__PAGETABLE_PMD_FOLDED) && !defined(__ARCH_HAS_4LEVEL_H=
ACK)
>>
>> #ifdefs have to be avoided as much as possible, see below
>=20
> Yeah but it has been bit difficult to avoid all these $ifdef because of=
 the
> availability (or lack of it) for all these pgtable helpers in various c=
onfig
> combinations on all platforms.

As far as I can see these pgtable helpers should exist everywhere at=20
least via asm-generic/ files.

Can you spot a particular config which fails ?

>=20
>>

[...]

>>> +#if !defined(__PAGETABLE_PUD_FOLDED) && !defined(__ARCH_HAS_5LEVEL_H=
ACK)
>>
>> The same can be done here.
>=20
> IIRC not only the page table helpers but there are data types (pxx_t) w=
hich
> were not present on various configs and these wrappers help prevent bui=
ld
> failures. Any ways will try and see if this can be improved further. Bu=
t
> meanwhile if you have some suggestions, please do let me know.

pgt_t and pmd_t are everywhere I guess.
then pud_t and p4d_t have fallbacks in asm-generic files.

So it shouldn't be an issue. Maybe if a couple of arches miss them, the=20
best would be to fix the arches, since that's the purpose of your=20
testsuite isn't it ?


Christophe

