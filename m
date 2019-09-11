Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7017CC49ED6
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 12:38:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 10CB22082C
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 12:38:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="BheTapsZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 10CB22082C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 81FA26B0005; Wed, 11 Sep 2019 08:38:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D0306B0006; Wed, 11 Sep 2019 08:38:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 70C7D6B0007; Wed, 11 Sep 2019 08:38:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0014.hostedemail.com [216.40.44.14])
	by kanga.kvack.org (Postfix) with ESMTP id 531716B0005
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 08:38:05 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id F1EDC180AD802
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 12:38:04 +0000 (UTC)
X-FDA: 75922592088.16.light88_4684c16c30c09
X-HE-Tag: light88_4684c16c30c09
X-Filterd-Recvd-Size: 3306
Received: from pegase1.c-s.fr (pegase1.c-s.fr [93.17.236.30])
	by imf26.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 12:38:04 +0000 (UTC)
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 46T1dj3qf5z9ttBh;
	Wed, 11 Sep 2019 14:38:01 +0200 (CEST)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=BheTapsZ; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id mYSQiCEUNZcF; Wed, 11 Sep 2019 14:38:01 +0200 (CEST)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 46T1dj2lqhz9ttBL;
	Wed, 11 Sep 2019 14:38:01 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1568205481; bh=DhX4WED4iVEDvM7Oo6DUrJ7y5zvr1cIiyY6i5byB5xc=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=BheTapsZKTb+mshgPxc5LdW+Rjt6YT+UWBHiyi8BqPZzqijoiF4b8ASoCLfoJqGIo
	 u2zdN67hu9KFy/D7DmUHWGbYstPxxBodFfJcUcoxDR/bUVxj38gJIOHySRpbnIugt1
	 PbCeRLYqhEnvNMELqUUbiz0qeDa36xLBGYDo6rOk=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id BB57A8B8BF;
	Wed, 11 Sep 2019 14:38:02 +0200 (CEST)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id SJCnYKUN_9kO; Wed, 11 Sep 2019 14:38:02 +0200 (CEST)
Received: from [172.25.230.103] (po15451.idsi0.si.c-s.fr [172.25.230.103])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 945FD8B8A6;
	Wed, 11 Sep 2019 14:38:02 +0200 (CEST)
Subject: Re: [PATCH v7 0/5] kasan: support backing vmalloc space with real
 shadow memory
To: Daniel Axtens <dja@axtens.net>, kasan-dev@googlegroups.com,
 linux-mm@kvack.org, x86@kernel.org, aryabinin@virtuozzo.com,
 glider@google.com, luto@kernel.org, linux-kernel@vger.kernel.org,
 mark.rutland@arm.com, dvyukov@google.com
Cc: linuxppc-dev@lists.ozlabs.org, gor@linux.ibm.com
References: <20190903145536.3390-1-dja@axtens.net>
 <d43cba17-ef1f-b715-e826-5325432042dd@c-s.fr>
 <87ftl39izy.fsf@dja-thinkpad.axtens.net>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Message-ID: <f1798d6b-96c5-18a7-3787-2307d0899b59@c-s.fr>
Date: Wed, 11 Sep 2019 14:38:02 +0200
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.9.0
MIME-Version: 1.0
In-Reply-To: <87ftl39izy.fsf@dja-thinkpad.axtens.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



Le 11/09/2019 =C3=A0 13:20, Daniel Axtens a =C3=A9crit=C2=A0:
> Hi Christophe,
>=20
>> Are any other patches required prior to this series ? I have tried to
>> apply it on later powerpc/merge branch without success:
>=20
> It applies on the latest linux-next. I didn't base it on powerpc/*
> because it's generic.
>=20

Ok, thanks.

I backported it to powerpc/merge and I'm testing it on PPC32 with=20
VMAP_STACK.

Got a few challenges but it is working now.

Christophe

