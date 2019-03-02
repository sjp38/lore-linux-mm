Return-Path: <SRS0=Ffi5=RF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7EC8BC43381
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 08:42:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0817D20838
	for <linux-mm@archiver.kernel.org>; Sat,  2 Mar 2019 08:42:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (4096-bit key) header.d=wiesinger.com header.i=@wiesinger.com header.b="0E/h3nvb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0817D20838
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=wiesinger.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7F1028E0003; Sat,  2 Mar 2019 03:42:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7A14D8E0001; Sat,  2 Mar 2019 03:42:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6B7758E0003; Sat,  2 Mar 2019 03:42:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 176E98E0001
	for <linux-mm@kvack.org>; Sat,  2 Mar 2019 03:42:19 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id f4so196325wrj.11
        for <linux-mm@kvack.org>; Sat, 02 Mar 2019 00:42:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-filter:dkim-signature:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=xpeH8YwqJwW/QChjS476XhaOdctvCylBuGN9WgDujSk=;
        b=UKc5lKVtNkgz6AFiKTASfaTMyjAsL/70oHpX5H5Keo+29iisK5bwtYjHb7fiBexmQF
         Ir/kOjgs+zD0p6MZoJxGkCZTs0cVDULnqebd6VzclnFlmGNfIgY/WaU/brUvotYmgP0D
         LPWbQzoa/xmNqMGIED0wlASmd9SBFspHmmmr6o343UqUtyxTfn0drpkkMxr2sY4BXKrj
         iKoR9uqnxBfLLTzCmHYZh66hJ0EHF93OQx7msbytu2YHW2dgqRZahXmu8AUx5DJxtpeI
         G0qO8IjMENFOuexC1w5ql962IPBA6w9EB6E3jXrRNjUgEpqJRbvjebesOQH80DYUH+2V
         Ifjw==
X-Gm-Message-State: APjAAAXxiP1UMm1j7mRSvATjEsck7SB89Gi75XZEBynfkC8Cds2bSPyY
	PHRRUG+3Vx0+aSfzrphWTVkYddrLmFm5/edNjlqmoX3Ps6daPRjMlRzh4BaL7iSuR08mRK3EqPK
	IS2gwzErQfqFFYfJVl+95iBGdrDFFOZYLnwhB9rM1Pv8zHyivN4bKdjPmoJEwRKf9Qg==
X-Received: by 2002:a5d:5111:: with SMTP id s17mr6044994wrt.183.1551516138431;
        Sat, 02 Mar 2019 00:42:18 -0800 (PST)
X-Google-Smtp-Source: APXvYqyo+e2NIriQObRgYA7djpK1WLQclN0zHQ2C6FHlZOIpb+wZFh+Zt0RypzHUMnlaCg+XlLeg
X-Received: by 2002:a5d:5111:: with SMTP id s17mr6044945wrt.183.1551516137177;
        Sat, 02 Mar 2019 00:42:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551516137; cv=none;
        d=google.com; s=arc-20160816;
        b=mNYcEmotCL5dkYyyjEh0rffYx8OP8hFWI7KsR05acgXSINERA/R0Cr7cRhD5KrC2iI
         M/5v8jmwWhHayyksjzWSGuApQDaGUX04RbvSqQJfaBqR649XuH4rvdqV9s089mI8fkST
         mIfUQmVWrjfXwlwPMAUZla5YD1LS0pAtsrnhjJKHCn4p6jjIn7TXdDaTOCboOYVsu0/f
         pmUXqDPwsKDz7wRExHI9Aqrv90fTumLzhwCMve3pA+4h97MRHWBV6B92wYwf8OSgsakP
         vMvBXo4vxCKLpnJ3lUjTN0RE6IQIANCNmy53JYnUhMulcRqCOiaJX8Yh665a4We2lE8B
         18VA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature:dkim-filter;
        bh=xpeH8YwqJwW/QChjS476XhaOdctvCylBuGN9WgDujSk=;
        b=vXlXgBgHdx435PrWHYL+XZy42mjevDR7fSntWYiqIONP8BVWFOhc2IKTBRyipsCdri
         sd1uaEdojOKEZM3fQa612yPLMg/vbOvIppD0odZzd72QBd5A/S+TrTXZuafLFVpQrgs8
         O3OQ7D3+qFQLBO6E4UQ5HGoMTor+rQL43f7wUJZKeTEdmcWXfzthOpRnAp00kpHIRTsJ
         SVRKllfECi8SyGzZu8uaiN6i5aYzESdn9cDQ647KV7OmfdnSb2Vbu6+C0BFs0f0cTYEE
         PBhyuPGe6I/ox8ABLPNxNwUJAMXooXJHd8kSk84m987SbCqRmDHYTsT958BVKoc+MMXt
         HfzA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@wiesinger.com header.s=default header.b="0E/h3nvb";
       spf=pass (google.com: domain of lists@wiesinger.com designates 46.36.37.179 as permitted sender) smtp.mailfrom=lists@wiesinger.com
Received: from vps01.wiesinger.com (vps01.wiesinger.com. [46.36.37.179])
        by mx.google.com with ESMTPS id 4si307005wma.133.2019.03.02.00.42.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 02 Mar 2019 00:42:17 -0800 (PST)
Received-SPF: pass (google.com: domain of lists@wiesinger.com designates 46.36.37.179 as permitted sender) client-ip=46.36.37.179;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@wiesinger.com header.s=default header.b="0E/h3nvb";
       spf=pass (google.com: domain of lists@wiesinger.com designates 46.36.37.179 as permitted sender) smtp.mailfrom=lists@wiesinger.com
Received: from wiesinger.com (wiesinger.com [84.113.44.87])
	by vps01.wiesinger.com (Postfix) with ESMTPS id E94909F318;
	Sat,  2 Mar 2019 09:42:13 +0100 (CET)
Received: from [192.168.32.242] (bgld-ip-242.intern [192.168.32.242])
	(authenticated bits=0)
	by wiesinger.com (8.15.2/8.15.2) with ESMTPSA id x228g8W7008259
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Sat, 2 Mar 2019 09:42:11 +0100
DKIM-Filter: OpenDKIM Filter v2.11.0 wiesinger.com x228g8W7008259
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=wiesinger.com;
	s=default; t=1551516132;
	bh=xpeH8YwqJwW/QChjS476XhaOdctvCylBuGN9WgDujSk=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=0E/h3nvbbX+8X4Z4nHQvEY2ZYpzYU8FZYU1sgojLIPQg2OotoaHui4gW40zWLb6AM
	 OE+KB4e1Jm+tTbDrXfVI2Lr2ooL04zCUMB7X/Lo97YVOtbel81DJzn7cSZtczyhFil
	 zTwmq9/Qea7Psrlmr45JgeoKnsWnTS5kT6/cA0ULBMSuUJbv6LHAmeK+o2yXPAElNC
	 rdU4zWqT6r0SCwJtq1LdLHDr69fSYnH86V9Uq2D1faOoZhnOmF9+LvX+POTc78xDvn
	 c87I/t9ZmYQCQT4HyvQHJGyMAogm9QWPm9hGDjkNgd+KDdUSYaqVqG9EPaGzoNyed7
	 UtJrWGzO4KrsyvwbkF4EvnEIOLNcyIcdoU4xIbLM1fvYXSMXzGDl2kamaVEHM/3uT+
	 7Ee2iDvTJagrH3SfQX3vPrsxD3ZhdcqVgPjMewGDMZp6IC+kxanWYpfgd76pMFI8IC
	 zJT7NQFLW5l2AcBT/GSiVN6LHUQgNQjFSVdXMobrUiH0mrM0TpXV2lv4dcJHFbfHnA
	 c+NSCkelESiOhKBI/+FNny1g+0DsvGtA5qTpKUkdXP05QYwdM875o5sHgcy2ZbZagk
	 RrOPdmf9g1qFHoz/VlW78wRmjCehvPbL20t70J3ilx4x5g8Y7KlvWhHs/PnGRaDKGo
	 W7X0m9qO5TmKskxmkFxXp/rU=
Subject: Re: Banana Pi-R1 stabil
To: Maxime Ripard <maxime.ripard@bootlin.com>
Cc: arm@lists.fedoraproject.org, Chen-Yu Tsai <wens@csie.org>,
        LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
        Florian Fainelli <f.fainelli@gmail.com>, filbar@centrum.cz
References: <7b20af72-76ea-a7b1-9939-ca378dc0ed83@wiesinger.com>
 <20190227092023.nvr34byfjranujfm@flea>
 <5f63a2c6-abcb-736f-d382-18e8cea31b65@wiesinger.com>
 <20190228093516.abual3564dkvx6un@flea>
 <91c22ba4-39eb-dd3d-29bd-1bfa7a45e9cd@wiesinger.com>
 <20190301093038.oz56z22ivpntdcfw@flea>
From: Gerhard Wiesinger <lists@wiesinger.com>
Message-ID: <8ad8fbeb-fad8-d39a-9cc6-e7f1deab0b4f@wiesinger.com>
Date: Sat, 2 Mar 2019 09:42:08 +0100
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.2
MIME-Version: 1.0
In-Reply-To: <20190301093038.oz56z22ivpntdcfw@flea>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 01.03.2019 10:30, Maxime Ripard wrote:
> On Thu, Feb 28, 2019 at 08:41:53PM +0100, Gerhard Wiesinger wrote:
>> On 28.02.2019 10:35, Maxime Ripard wrote:
>>> On Wed, Feb 27, 2019 at 07:58:14PM +0100, Gerhard Wiesinger wrote:
>>>> On 27.02.2019 10:20, Maxime Ripard wrote:
>>>>> On Sun, Feb 24, 2019 at 09:04:57AM +0100, Gerhard Wiesinger wrote:
>>>>>> Hello,
>>>>>>
>>>>>> I've 3 Banana Pi R1, one running with self compiled kernel
>>>>>> 4.7.4-200.BPiR1.fc24.armv7hl and old Fedora 25 which is VERY STABLE, the 2
>>>>>> others are running with Fedora 29 latest, kernel 4.20.10-200.fc29.armv7hl. I
>>>>>> tried a lot of kernels between of around 4.11
>>>>>> (kernel-4.11.10-200.fc25.armv7hl) until 4.20.10 but all had crashes without
>>>>>> any output on the serial console or kernel panics after a short time of
>>>>>> period (minutes, hours, max. days)
>>>>>>
>>>>>> Latest known working and stable self compiled kernel: kernel
>>>>>> 4.7.4-200.BPiR1.fc24.armv7hl:
>>>>>>
>>>>>> https://www.wiesinger.com/opensource/fedora/kernel/BananaPi-R1/
>>>>>>
>>>>>> With 4.8.x the DSA b53 switch infrastructure has been introduced which
>>>>>> didn't work (until ca8931948344c485569b04821d1f6bcebccd376b and kernel
>>>>>> 4.18.x):
>>>>>>
>>>>>> https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/tree/drivers/net/dsa/b53?h=v4.20.12
>>>>>>
>>>>>> https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/log/drivers/net/dsa/b53?h=v4.20.12
>>>>>>
>>>>>> https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/commit/drivers/net/dsa/b53?h=v4.20.12&id=ca8931948344c485569b04821d1f6bcebccd376b
>>>>>>
>>>>>> I has been fixed with kernel 4.18.x:
>>>>>>
>>>>>> https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/log/drivers/net/dsa/b53?h=linux-4.18.y
>>>>>>
>>>>>>
>>>>>> So current status is, that kernel crashes regularly, see some samples below.
>>>>>> It is typically a "Unable to handle kernel paging request at virtual addres"
>>>>>>
>>>>>> Another interesting thing: A Banana Pro works well (which has also an
>>>>>> Allwinner A20 in the same revision) running same Fedora 29 and latest
>>>>>> kernels (e.g. kernel 4.20.10-200.fc29.armv7hl.).
>>>>>>
>>>>>> Since it happens on 2 different devices and with different power supplies
>>>>>> (all with enough power) and also the same type which works well on the
>>>>>> working old kernel) a hardware issue is very unlikely.
>>>>>>
>>>>>> I guess it has something to do with virtual memory.
>>>>>>
>>>>>> Any ideas?
>>>>>> [47322.960193] Unable to handle kernel paging request at virtual addres 5675d0
>>>>> That line is a bit suspicious
>>>>>
>>>>> Anyway, cpufreq is known to cause those kind of errors when the
>>>>> voltage / frequency association is not correct.
>>>>>
>>>>> Given the stack trace and that the BananaPro doesn't have cpufreq
>>>>> enabled, my first guess would be that it's what's happening. Could you
>>>>> try using the performance governor and see if it's more stable?
>>>>>
>>>>> If it is, then using this:
>>>>> https://github.com/ssvb/cpuburn-arm/blob/master/cpufreq-ljt-stress-test
>>>>>
>>>>> will help you find the offending voltage-frequency couple.
>>>> For me it looks like they have all the same config regarding cpu governor
>>>> (Banana Pro, old kernel stable one, new kernel unstable ones)
>>> The Banana Pro doesn't have a regulator set up, so it will only change
>>> the frequency, not the voltage.
>>>
>>>> They all have the ondemand governor set:
>>>>
>>>> I set on the 2 unstable "new kernel Banana Pi R1":
>>>>
>>>> # Set to max performance
>>>> echo "performance" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
>>>> echo "performance" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
>>> What are the results?
>> Stable since more than around 1,5 days. Normally they have been crashed for
>> such a long uptime. So it looks that the performance governor fixes it.
>>
>> I guess crashes occour because of changing CPU voltage and clock changes and
>> invalid data (e.g. also invalid RAM contents might be read, register
>> problems, etc).
>>
>> Any ideas how to fix it for ondemand mode, too?
> Run https://github.com/ssvb/cpuburn-arm/blob/master/cpufreq-ljt-stress-test
>
>> But it doesn't explaing that it works with kernel 4.7.4 without any
>> problems.
> My best guess would be that cpufreq wasn't enabled at that time, or
> without voltage scaling.
>

Where can I see the voltage scaling parameters?

on DTS I don't see any difference between kernel 4.7.4 and 4.20.10 
regarding voltage:

dtc -I dtb -O dts -o 
/boot/dtb-4.20.10-200.fc29.armv7hl/sun7i-a20-lamobo-r1.dts 
/boot/dtb-4.20.10-200.fc29.armv7hl/sun7i-a20-lamobo-r1.dtb

There is another strange thing (tested with 
kernel-5.0.0-0.rc8.git1.1.fc31.armv7hl, kernel-4.19.8-300.fc29.armv7hl, 
kernel-4.20.13-200.fc29.armv7hl, kernel-4.20.10-200.fc29.armv7hl):

There is ALWAYS high CPU of around 10% in kworker:

   PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM TIME+ COMMAND
18722 root      20   0       0      0      0 I   9.5   0.0 0:47.52 
[kworker/1:3-events_freezable_power_]

   PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM TIME+ COMMAND
   776 root      20   0       0      0      0 I   8.6   0.0 0:02.77 
[kworker/0:4-events]

Therefore CPU doesn't switch to low frequencies (see below).

Any ideas?

BTW: Still stable at aboout 2,5days on both devices. So solution IS the 
performance governor.

Ciao,

Gerhard

================================================================================================================================================================
# monitor frequency
while true; do echo "========================================"; echo -n 
"CPU_FREQ0: "; cat 
/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq; echo -n 
"CPU_FREQ1: "; cat 
/sys/devices/system/cpu/cpu1/cpufreq/cpuinfo_cur_freq; sleep 1; done
================================================================================================================================================================

# Kernel 4.7.4:
========================================
CPU_FREQ0: 144000
CPU_FREQ1: 144000
========================================
CPU_FREQ0: 144000
CPU_FREQ1: 144000
========================================
CPU_FREQ0: 144000
CPU_FREQ1: 144000
========================================

# Kernel 4.20.10
========================================
CPU_FREQ0: 864000
CPU_FREQ1: 720000
========================================
CPU_FREQ0: 960000
CPU_FREQ1: 960000
========================================
CPU_FREQ0: 960000
CPU_FREQ1: 960000
========================================
CPU_FREQ0: 144000
CPU_FREQ1: 144000
========================================
CPU_FREQ0: 720000
CPU_FREQ1: 960000
========================================
CPU_FREQ0: 960000
CPU_FREQ1: 864000
========================================
CPU_FREQ0: 720000
CPU_FREQ1: 864000
========================================
CPU_FREQ0: 528000
CPU_FREQ1: 864000


