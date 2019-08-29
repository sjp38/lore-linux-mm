Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 521A3C3A59F
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 16:22:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 205C520673
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 16:22:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 205C520673
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C43AC6B0003; Thu, 29 Aug 2019 12:22:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BF2C36B0005; Thu, 29 Aug 2019 12:22:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B309E6B0008; Thu, 29 Aug 2019 12:22:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0206.hostedemail.com [216.40.44.206])
	by kanga.kvack.org (Postfix) with ESMTP id 8F5096B0003
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 12:22:33 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 4790B127B1
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 16:22:33 +0000 (UTC)
X-FDA: 75875983386.04.sail26_6d813ead9c240
X-HE-Tag: sail26_6d813ead9c240
X-Filterd-Recvd-Size: 4080
Received: from mga01.intel.com (mga01.intel.com [192.55.52.88])
	by imf18.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 16:22:32 +0000 (UTC)
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 29 Aug 2019 09:22:31 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,444,1559545200"; 
   d="scan'208";a="205787728"
Received: from mbmcwil3-mobl.amr.corp.intel.com (HELO [10.252.203.249]) ([10.252.203.249])
  by fmsmga004.fm.intel.com with ESMTP; 29 Aug 2019 09:22:29 -0700
Subject: Re: [alsa-devel] mmotm 2019-08-27-20-39 uploaded
 (sound/hda/intel-nhlt.c)
To: Takashi Iwai <tiwai@suse.de>
Cc: Randy Dunlap <rdunlap@infradead.org>, akpm@linux-foundation.org,
 broonie@kernel.org, linux-fsdevel@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-next@vger.kernel.org, mhocko@suse.cz, mm-commits@vger.kernel.org,
 sfr@canb.auug.org.au,
 moderated for non-subscribers <alsa-devel@alsa-project.org>
References: <20190828034012.sBvm81sYK%akpm@linux-foundation.org>
 <274054ef-8611-2661-9e67-4aabae5a7728@infradead.org>
 <5ac8a7a7-a9b4-89a5-e0a6-7c97ec1fabc6@linux.intel.com>
 <98ada795-4700-7fcc-6d14-fcc1ab25d509@infradead.org>
 <f0a62b08-cba9-d944-5792-8eac0ea39df1@linux.intel.com>
 <19edfb9a-f7b3-7a89-db5a-33289559aeef@linux.intel.com>
 <s5hzhjs102i.wl-tiwai@suse.de>
From: Pierre-Louis Bossart <pierre-louis.bossart@linux.intel.com>
Message-ID: <c7c8fcde-40c7-8025-9fa7-e7e0daa8770c@linux.intel.com>
Date: Thu, 29 Aug 2019 11:22:29 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <s5hzhjs102i.wl-tiwai@suse.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 8/29/19 10:08 AM, Takashi Iwai wrote:
> On Thu, 29 Aug 2019 00:45:05 +0200,
> Pierre-Louis Bossart wrote:
>>
>>
>>>>> I just checked with Mark Brown's for-next tree
>>>>> 8aceffa09b4b9867153bfe0ff6f40517240cee12
>>>>> and things are fine in i386 mode, see below.
>>>>>
>>>>> next-20190828 also works fine for me in i386 mode.
>>>>>
>>>>> if you can point me to a tree and configuration that don't work
>>>>> I'll look into this, I'd need more info to progress.
>>>>
>>>> Please try the attached randconfig file.
>>>>
>>>> Thanks for looking.
>>>
>>> Ack, I see some errors as well with this config. Likely a missing
>>> dependency somewhere, working on this now.
>>
>> My bad, I added a fallback with static inline functions in the .h file
>> when ACPI is not defined, but the .c file was still compiled.
>>
>> The diff below makes next-20190828 compile with Randy's config.
> 
> IMO, we need to fix the site that enables this config.  i.e.
> the "select SND_INTEL_NHLT" must be always conditional, e.g.
> 	select SND_INTEL_NHLT if ACPI

that would be nicer indeed, currently we don't have a consistent solution:
sound/pci/hda/Kconfig:  select SND_INTEL_NHLT if ACPI
sound/soc/intel/Kconfig:        select SND_INTEL_NHLT
sound/soc/sof/intel/Kconfig:    select SND_INTEL_NHLT

I can't recall why things are different, will send a patch to align.


> 
>> It looks like the alsa-devel server is down btw?
> 
> Now it seems starting again.
> 
> 
> thanks,
> 
> Takashi
> 
>> diff --git a/sound/hda/Makefile b/sound/hda/Makefile
>> index 8560f6ef1b19..b3af071ce06b 100644
>> --- a/sound/hda/Makefile
>> +++ b/sound/hda/Makefile
>> @@ -14,5 +14,7 @@ obj-$(CONFIG_SND_HDA_CORE) += snd-hda-core.o
>>   #extended hda
>>   obj-$(CONFIG_SND_HDA_EXT_CORE) += ext/
>>
>> +ifdef CONFIG_ACPI
>>   snd-intel-nhlt-objs := intel-nhlt.o
>>   obj-$(CONFIG_SND_INTEL_NHLT) += snd-intel-nhlt.o
>> +endif
>>
>> _______________________________________________
>> Alsa-devel mailing list
>> Alsa-devel@alsa-project.org
>> https://mailman.alsa-project.org/mailman/listinfo/alsa-devel
>>

