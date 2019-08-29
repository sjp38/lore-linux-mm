Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5D5DC3A5A4
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 02:26:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AC16C22CF8
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 02:26:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="dvr793nm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AC16C22CF8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3920F6B0006; Wed, 28 Aug 2019 22:26:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3428B6B000C; Wed, 28 Aug 2019 22:26:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2593A6B000D; Wed, 28 Aug 2019 22:26:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0173.hostedemail.com [216.40.44.173])
	by kanga.kvack.org (Postfix) with ESMTP id 037916B0006
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 22:26:43 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 9EB408132
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 02:26:43 +0000 (UTC)
X-FDA: 75873877086.16.card22_57c8016757543
X-HE-Tag: card22_57c8016757543
X-Filterd-Recvd-Size: 4058
Received: from bombadil.infradead.org (bombadil.infradead.org [198.137.202.133])
	by imf12.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 02:26:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	Content-Type:In-Reply-To:MIME-Version:Date:Message-ID:From:References:To:
	Subject:Sender:Reply-To:Cc:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=cvhAYDXepFr1W9XWCommsvR9amxyOLa9CIfTaM40gzI=; b=dvr793nmEyuIwAJsP5Fl+MGYY
	uvnb9faUYyG1neWulPIY9ZqRNcx7SjwX+FKIEfKqNBaq9RcsVdx+oknvaG6iuC9vm37zGhMyvQvSp
	nJheZPzgfL7MJSOERDyF7B+MXxsLHKpsR2LFo2OMFICcizUrJHk3BSzURLc/JXfRSqhYSVDAbp0Dz
	cz3cR7/pdDt9G7D/xrl5aDhIH/TOr7g14632wYtcz03Z7SVo120mKlQT+ZPrHNq6nrfB5BSpna5tq
	iBgolawBjj8HZ+Oof7dNaGFrhrtQ92LUnI5Fms8FoSvTkrIZX17aaBVDTCZayHDWuIoXvsEx2ijEb
	64O83mpTA==;
Received: from [2601:1c0:6200:6e8::4f71]
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1i3A8u-0005Xu-47; Thu, 29 Aug 2019 02:26:32 +0000
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
 <4725bbed-81e1-9724-b51c-47eba8e414d0@infradead.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <d26c671b-fa17-e065-85f3-d6d187c4fc15@infradead.org>
Date: Wed, 28 Aug 2019 19:26:30 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <4725bbed-81e1-9724-b51c-47eba8e414d0@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/28/19 3:59 PM, Randy Dunlap wrote:
> On 8/28/19 3:45 PM, Pierre-Louis Bossart wrote:
>>
>>>>> I just checked with Mark Brown's for-next tree 8aceffa09b4b9867153b=
fe0ff6f40517240cee12
>>>>> and things are fine in i386 mode, see below.
>>>>>
>>>>> next-20190828 also works fine for me in i386 mode.
>>>>>
>>>>> if you can point me to a tree and configuration that don't work I'l=
l look into this, I'd need more info to progress.
>>>>
>>>> Please try the attached randconfig file.
>>>>
>>>> Thanks for looking.
>>>
>>> Ack, I see some errors as well with this config. Likely a missing dep=
endency somewhere, working on this now.
>>
>> My bad, I added a fallback with static inline functions in the .h file=
 when ACPI is not defined, but the .c file was still compiled.
>>
>> The diff below makes next-20190828 compile with Randy's config.
>>
>> It looks like the alsa-devel server is down btw?
>>
>> diff --git a/sound/hda/Makefile b/sound/hda/Makefile
>> index 8560f6ef1b19..b3af071ce06b 100644
>> --- a/sound/hda/Makefile
>> +++ b/sound/hda/Makefile
>> @@ -14,5 +14,7 @@ obj-$(CONFIG_SND_HDA_CORE) +=3D snd-hda-core.o
>> =C2=A0#extended hda
>> =C2=A0obj-$(CONFIG_SND_HDA_EXT_CORE) +=3D ext/
>>
>> +ifdef CONFIG_ACPI
>> =C2=A0snd-intel-nhlt-objs :=3D intel-nhlt.o
>> =C2=A0obj-$(CONFIG_SND_INTEL_NHLT) +=3D snd-intel-nhlt.o
>> +endif
>>
>=20
> works for me.  Thanks.
> Acked-by: Randy Dunlap <rdunlap@infradead.org> # build-tested
>=20

although this Makefile change should not be needed
and the dependencies should be handled correctly in Kconfig files.

--=20
~Randy

