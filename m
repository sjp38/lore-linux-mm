Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55C7CC3A5A6
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 22:59:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 176E323405
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 22:59:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="apGZ0790"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 176E323405
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 84C9A6B0008; Wed, 28 Aug 2019 18:59:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7FC086B000C; Wed, 28 Aug 2019 18:59:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6EBF46B000D; Wed, 28 Aug 2019 18:59:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0149.hostedemail.com [216.40.44.149])
	by kanga.kvack.org (Postfix) with ESMTP id 4D57C6B0008
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 18:59:18 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id DFE4E180AD7C3
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 22:59:17 +0000 (UTC)
X-FDA: 75873354354.06.toe37_16ea653cc1417
X-HE-Tag: toe37_16ea653cc1417
X-Filterd-Recvd-Size: 3804
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf26.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 22:59:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:In-Reply-To:MIME-Version:Date:Message-ID:From:References:To:
	Subject:Sender:Reply-To:Cc:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=T68LB0FXO/suGbld1wN+JgjhePzUkb8K5QqC/l1w5Tc=; b=apGZ0790F2Byb5ula3d4xEfxr
	vCjo6bsgtwe4WgjOKnRvMWgsodT4X3lpKavbp9MiQzkPtDOnTFrchnEeMdw+Vx2MIZVjEEf23oowl
	DISybElP+QbxZq7nPWML9lidFMVgoH+7M0GKhghLYX0bbTSUmsJ+jH6WgG8AuU9AvAXrOLr0jI1/e
	WE1nOt7XvbJU0oergHsoRQgLPB0QgAPECF2R7WGoZVRCeqVMSpJ0Mgvf6TC7br7r2Ol7mgHVQbUN3
	otmWsubVT7rRRfi3SVZFpXRx46nTGP4EJ5bmQ4Z9G1u7FCzA9cXDCMJ8guvpQvsbdeoS0UMJdrCOU
	sv/Vl4I4A==;
Received: from [2601:1c0:6200:6e8::4f71]
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1i36uA-00017t-VK; Wed, 28 Aug 2019 22:59:07 +0000
Subject: Re: mmotm 2019-08-27-20-39 uploaded (sound/hda/intel-nhlt.c)
To: Pierre-Louis Bossart <pierre-louis.bossart@linux.intel.com>,
 akpm@linux-foundation.org, broonie@kernel.org,
 linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, linux-next@vger.kernel.org, mhocko@suse.cz,
 mm-commits@vger.kernel.org, sfr@canb.auug.org.au,
 moderated for non-subscribers <alsa-devel@alsa-project.org>
References: <20190828034012.sBvm81sYK%akpm@linux-foundation.org>
 <274054ef-8611-2661-9e67-4aabae5a7728@infradead.org>
 <5ac8a7a7-a9b4-89a5-e0a6-7c97ec1fabc6@linux.intel.com>
 <98ada795-4700-7fcc-6d14-fcc1ab25d509@infradead.org>
 <f0a62b08-cba9-d944-5792-8eac0ea39df1@linux.intel.com>
 <19edfb9a-f7b3-7a89-db5a-33289559aeef@linux.intel.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <4725bbed-81e1-9724-b51c-47eba8e414d0@infradead.org>
Date: Wed, 28 Aug 2019 15:59:05 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <19edfb9a-f7b3-7a89-db5a-33289559aeef@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/28/19 3:45 PM, Pierre-Louis Bossart wrote:
>=20
>>>> I just checked with Mark Brown's for-next tree 8aceffa09b4b9867153bf=
e0ff6f40517240cee12
>>>> and things are fine in i386 mode, see below.
>>>>
>>>> next-20190828 also works fine for me in i386 mode.
>>>>
>>>> if you can point me to a tree and configuration that don't work I'll=
 look into this, I'd need more info to progress.
>>>
>>> Please try the attached randconfig file.
>>>
>>> Thanks for looking.
>>
>> Ack, I see some errors as well with this config. Likely a missing depe=
ndency somewhere, working on this now.
>=20
> My bad, I added a fallback with static inline functions in the .h file =
when ACPI is not defined, but the .c file was still compiled.
>=20
> The diff below makes next-20190828 compile with Randy's config.
>=20
> It looks like the alsa-devel server is down btw?
>=20
> diff --git a/sound/hda/Makefile b/sound/hda/Makefile
> index 8560f6ef1b19..b3af071ce06b 100644
> --- a/sound/hda/Makefile
> +++ b/sound/hda/Makefile
> @@ -14,5 +14,7 @@ obj-$(CONFIG_SND_HDA_CORE) +=3D snd-hda-core.o
> =C2=A0#extended hda
> =C2=A0obj-$(CONFIG_SND_HDA_EXT_CORE) +=3D ext/
>=20
> +ifdef CONFIG_ACPI
> =C2=A0snd-intel-nhlt-objs :=3D intel-nhlt.o
> =C2=A0obj-$(CONFIG_SND_INTEL_NHLT) +=3D snd-intel-nhlt.o
> +endif
>=20

works for me.  Thanks.
Acked-by: Randy Dunlap <rdunlap@infradead.org> # build-tested

--=20
~Randy

