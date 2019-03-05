Return-Path: <SRS0=tSF5=RI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62AA3C43381
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 19:21:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CE7FF20842
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 19:21:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (4096-bit key) header.d=wiesinger.com header.i=@wiesinger.com header.b="nVoJLu0a"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CE7FF20842
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=wiesinger.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 48F378E0003; Tue,  5 Mar 2019 14:21:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 417068E0001; Tue,  5 Mar 2019 14:21:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 291728E0003; Tue,  5 Mar 2019 14:21:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id C213B8E0001
	for <linux-mm@kvack.org>; Tue,  5 Mar 2019 14:21:30 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id c69so1777329wme.5
        for <linux-mm@kvack.org>; Tue, 05 Mar 2019 11:21:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-filter:dkim-signature:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=BrX1PaqBse0hKFu1bH5rAaYwUyCi8PruHlOBsds4J/0=;
        b=emdhnrpnRfr3iTDGhlKSsfe68Wqic4M7QxTXKA5Vv4jYgBt4TpK/VBHnXNxg5AH2kp
         WgvDDA/Ho+W2oatrIQ6AQHaot6EAYpVGVBvIDFiVhXsji+WyVum9aciA6l70HK8H9QEB
         8SSZ1dCsW1yP68MxNndPx6BZAce96gxyuWM4MrRspWf+FgypcEQKR/GupGtg+tL8UIvO
         DWi7TdEWxj0dmc41ts4U88MDurTs5KYezt33M9csyu7q/JMyFYC99B4ldoETKNFC2Czu
         B3+eip1RB2o9nGvGeN8iuXr0C/cw3zjaMPZhHEOqPvkA+9BvjXEarDgQp3FKZhrchiLW
         uNbA==
X-Gm-Message-State: APjAAAVLwvJ2KNMcfxUxKG/3SJxl3oYsOuYYIg8MlterdMlU+mUwmdoO
	fT0tbENuQS29x7gAmX+EB8xEhlwKaCw8W7aIx/ivaFxYhhpZGD1LQcSvE5pC/JTfftMM9deZLva
	6eF2E0uTcIAVy7efKDGXERA1LmbxcMt6LK4vbx0VBeOwUCnrybtRKlIBglYSlqgf7sw==
X-Received: by 2002:a1c:41c5:: with SMTP id o188mr63659wma.147.1551813690100;
        Tue, 05 Mar 2019 11:21:30 -0800 (PST)
X-Google-Smtp-Source: APXvYqwiQWx4YVCKe21anSdHPvGnupF6YyzhwXeD6by9FEW5R2kbLwecPI/bnqcnndk1BnV+mspJ
X-Received: by 2002:a1c:41c5:: with SMTP id o188mr63582wma.147.1551813688268;
        Tue, 05 Mar 2019 11:21:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551813688; cv=none;
        d=google.com; s=arc-20160816;
        b=pov6musy2TB5pP11ocMSdeguEK5PSeM+q6w8wbQMbXKzmug3++HUpiqkl9SAiBhBCV
         Md/F2rUnBM4PqU6X9X9trYo6HCE1QFjoejzY1vLZbGoo4BoBmyiKxqzDG3Gz7pdbuAD5
         GqtSSKvXM1mbBAemy6P3auzRp5THaU1q+ZAcuYId/Nl3bal6i2s5+QazGZvX5vLHyDN5
         Znkb63KQ9lAiNDl+4/lDbpn2x5yd5l17LL7fDPj1kE/UCYhjrxhHsdGgKxpD01ioNeGP
         qUGBIAeUa13jgbHcaxSNpzYftEXRmFhFYZOFYu/LcDTmMgfpeGV7wpn5dsDDhe171Avt
         kUbA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature:dkim-filter;
        bh=BrX1PaqBse0hKFu1bH5rAaYwUyCi8PruHlOBsds4J/0=;
        b=hHb2ZrlsmH46FvF2iG+SEVqQ5eKdGclL6qRDtN5zFwmE3GLYyzdweB43UYXHjcMtuI
         Ok4diJeY/3q2llbN7+JhkHcdpXgHpVjE1DjucU1gHEMcchmwmMrZt8jQM8Bl7CUHBvFC
         RAdowovzv8XjU1OpZ/+SchDa+xr3iBZBHYLudPZFdGVGukvdL0E7Vh6K8LBoHDcgZIa8
         QGU1sfLko63/Pt51umToe9O6HP51qdH6M5naPiqiZz9bRc47mIq7G7/yt084MgfyUaoo
         5qkmZLhIj9eEcpXcHAUKB5K3v1+tSFdmaXwDjBEdGnT2V7FA0S/3i4kSCjbQufYyAg83
         BXxg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@wiesinger.com header.s=default header.b=nVoJLu0a;
       spf=pass (google.com: domain of lists@wiesinger.com designates 46.36.37.179 as permitted sender) smtp.mailfrom=lists@wiesinger.com
Received: from vps01.wiesinger.com (vps01.wiesinger.com. [46.36.37.179])
        by mx.google.com with ESMTPS id p13si6295467wrq.131.2019.03.05.11.21.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 05 Mar 2019 11:21:28 -0800 (PST)
Received-SPF: pass (google.com: domain of lists@wiesinger.com designates 46.36.37.179 as permitted sender) client-ip=46.36.37.179;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@wiesinger.com header.s=default header.b=nVoJLu0a;
       spf=pass (google.com: domain of lists@wiesinger.com designates 46.36.37.179 as permitted sender) smtp.mailfrom=lists@wiesinger.com
Received: from wiesinger.com (wiesinger.com [84.113.44.87])
	by vps01.wiesinger.com (Postfix) with ESMTPS id EE7759F2CD;
	Tue,  5 Mar 2019 20:21:25 +0100 (CET)
Received: from [192.168.0.14] ([192.168.0.14])
	(authenticated bits=0)
	by wiesinger.com (8.15.2/8.15.2) with ESMTPSA id x25JL3qH029344
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Tue, 5 Mar 2019 20:21:04 +0100
DKIM-Filter: OpenDKIM Filter v2.11.0 wiesinger.com x25JL3qH029344
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=wiesinger.com;
	s=default; t=1551813666;
	bh=BrX1PaqBse0hKFu1bH5rAaYwUyCi8PruHlOBsds4J/0=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=nVoJLu0aB5edoSLTlurPTRQ0xDnQV4htBo3g58FFGoewEW6lSNstrnoqFptr61HpT
	 XoIT/+bBvsoYfxUD0Ep9wtyAxum9khO6MEW0CpO1Kdrgbday+ymLvkyghWTLXlWdgJ
	 w7othGtJEFnPuxtNqHunIXNtP4t+uIQSa/FhXqcPtPldG/SZqjZ0iVOr5A3ThBudIo
	 ykaG6SqRPDT5gZgaLKFa+9W2icol/2X7141BcgFROvYSGzcd53YvFgZP0C1uAdO2f+
	 5AZeZlyRbwe8BjmgBYM3RtiwwxkXHBxIGredehQv7LUPo1Is8jCXhikjNG9XCBd4sv
	 rLz8xovM3JLPEcxObmUQeiL8TuxqdmtGHkfd4kO2cPM0oLCPVHSHycyskDn0JWMyI8
	 Pn+HURdiVCQQ+jvPiX9ivlwxTSKDDtri0gvu8LCEJ1oilvRqEtKBjBB29Ry4LP6CuE
	 N5G2At1aMQOeybH6QKm7ESfCxxTZ7QsfKqvuvWIqIRh8ghSjDsYhxDes0+bEssJmPx
	 DAucQfMMp3CKbQ/7IWjVev/XsbXGz5OwHqeF/KnoXwPUXm+xQlIJ7LsADvvrKWHz5N
	 E4ImYxbVcH7vtne3GWJLD5olk8WeE+bYX58+UuxeUgjhncDZNoreZNXxK6Y5+beTNY
	 MRFR742e71WEVLq66FXlN7LE=
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
 <8ad8fbeb-fad8-d39a-9cc6-e7f1deab0b4f@wiesinger.com>
 <20190305092830.ef45kxzhdnxlh63g@flea>
From: Gerhard Wiesinger <lists@wiesinger.com>
Message-ID: <9f189569-bf76-22d2-3bf7-db710f616998@wiesinger.com>
Date: Tue, 5 Mar 2019 20:21:02 +0100
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.2
MIME-Version: 1.0
In-Reply-To: <20190305092830.ef45kxzhdnxlh63g@flea>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 05.03.2019 10:28, Maxime Ripard wrote:
> On Sat, Mar 02, 2019 at 09:42:08AM +0100, Gerhard Wiesinger wrote:
>> On 01.03.2019 10:30, Maxime Ripard wrote:
>>> On Thu, Feb 28, 2019 at 08:41:53PM +0100, Gerhard Wiesinger wrote:
>>>> On 28.02.2019 10:35, Maxime Ripard wrote:
>>>>> On Wed, Feb 27, 2019 at 07:58:14PM +0100, Gerhard Wiesinger wrote:
>>>>>> On 27.02.2019 10:20, Maxime Ripard wrote:
>>>>>>> On Sun, Feb 24, 2019 at 09:04:57AM +0100, Gerhard Wiesinger wrote:
>>>>>>>> Hello,
>>>>>>>>
>>>>>>>> I've 3 Banana Pi R1, one running with self compiled kernel
>>>>>>>> 4.7.4-200.BPiR1.fc24.armv7hl and old Fedora 25 which is VERY STABLE, the 2
>>>>>>>> others are running with Fedora 29 latest, kernel 4.20.10-200.fc29.armv7hl. I
>>>>>>>> tried a lot of kernels between of around 4.11
>>>>>>>> (kernel-4.11.10-200.fc25.armv7hl) until 4.20.10 but all had crashes without
>>>>>>>> any output on the serial console or kernel panics after a short time of
>>>>>>>> period (minutes, hours, max. days)
>>>>>>>>
>>>>>>>> Latest known working and stable self compiled kernel: kernel
>>>>>>>> 4.7.4-200.BPiR1.fc24.armv7hl:
>>>>>>>>
>>>>>>>> https://www.wiesinger.com/opensource/fedora/kernel/BananaPi-R1/
>>>>>>>>
>>>>>>>> With 4.8.x the DSA b53 switch infrastructure has been introduced which
>>>>>>>> didn't work (until ca8931948344c485569b04821d1f6bcebccd376b and kernel
>>>>>>>> 4.18.x):
>>>>>>>>
>>>>>>>> https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/tree/drivers/net/dsa/b53?h=v4.20.12
>>>>>>>>
>>>>>>>> https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/log/drivers/net/dsa/b53?h=v4.20.12
>>>>>>>>
>>>>>>>> https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/commit/drivers/net/dsa/b53?h=v4.20.12&id=ca8931948344c485569b04821d1f6bcebccd376b
>>>>>>>>
>>>>>>>> I has been fixed with kernel 4.18.x:
>>>>>>>>
>>>>>>>> https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/log/drivers/net/dsa/b53?h=linux-4.18.y
>>>>>>>>
>>>>>>>>
>>>>>>>> So current status is, that kernel crashes regularly, see some samples below.
>>>>>>>> It is typically a "Unable to handle kernel paging request at virtual addres"
>>>>>>>>
>>>>>>>> Another interesting thing: A Banana Pro works well (which has also an
>>>>>>>> Allwinner A20 in the same revision) running same Fedora 29 and latest
>>>>>>>> kernels (e.g. kernel 4.20.10-200.fc29.armv7hl.).
>>>>>>>>
>>>>>>>> Since it happens on 2 different devices and with different power supplies
>>>>>>>> (all with enough power) and also the same type which works well on the
>>>>>>>> working old kernel) a hardware issue is very unlikely.
>>>>>>>>
>>>>>>>> I guess it has something to do with virtual memory.
>>>>>>>>
>>>>>>>> Any ideas?
>>>>>>>> [47322.960193] Unable to handle kernel paging request at virtual addres 5675d0
>>>>>>> That line is a bit suspicious
>>>>>>>
>>>>>>> Anyway, cpufreq is known to cause those kind of errors when the
>>>>>>> voltage / frequency association is not correct.
>>>>>>>
>>>>>>> Given the stack trace and that the BananaPro doesn't have cpufreq
>>>>>>> enabled, my first guess would be that it's what's happening. Could you
>>>>>>> try using the performance governor and see if it's more stable?
>>>>>>>
>>>>>>> If it is, then using this:
>>>>>>> https://github.com/ssvb/cpuburn-arm/blob/master/cpufreq-ljt-stress-test
>>>>>>>
>>>>>>> will help you find the offending voltage-frequency couple.
>>>>>> For me it looks like they have all the same config regarding cpu governor
>>>>>> (Banana Pro, old kernel stable one, new kernel unstable ones)
>>>>> The Banana Pro doesn't have a regulator set up, so it will only change
>>>>> the frequency, not the voltage.
>>>>>
>>>>>> They all have the ondemand governor set:
>>>>>>
>>>>>> I set on the 2 unstable "new kernel Banana Pi R1":
>>>>>>
>>>>>> # Set to max performance
>>>>>> echo "performance" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
>>>>>> echo "performance" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
>>>>> What are the results?
>>>> Stable since more than around 1,5 days. Normally they have been crashed for
>>>> such a long uptime. So it looks that the performance governor fixes it.
>>>>
>>>> I guess crashes occour because of changing CPU voltage and clock changes and
>>>> invalid data (e.g. also invalid RAM contents might be read, register
>>>> problems, etc).
>>>>
>>>> Any ideas how to fix it for ondemand mode, too?
>>> Run https://github.com/ssvb/cpuburn-arm/blob/master/cpufreq-ljt-stress-test
>>>
>>>> But it doesn't explaing that it works with kernel 4.7.4 without any
>>>> problems.
>>> My best guess would be that cpufreq wasn't enabled at that time, or
>>> without voltage scaling.
>>>
>> Where can I see the voltage scaling parameters?
>>
>> on DTS I don't see any difference between kernel 4.7.4 and 4.20.10 regarding
>> voltage:
>>
>> dtc -I dtb -O dts -o
>> /boot/dtb-4.20.10-200.fc29.armv7hl/sun7i-a20-lamobo-r1.dts
>> /boot/dtb-4.20.10-200.fc29.armv7hl/sun7i-a20-lamobo-r1.dtb
> This can be also due to configuration being changed, driver support, etc.

Where will the voltages for scaling then be set in detail (drivers, etc.)?


>
>> There is another strange thing (tested with
>> kernel-5.0.0-0.rc8.git1.1.fc31.armv7hl, kernel-4.19.8-300.fc29.armv7hl,
>> kernel-4.20.13-200.fc29.armv7hl, kernel-4.20.10-200.fc29.armv7hl):
>>
>> There is ALWAYS high CPU of around 10% in kworker:
>>
>>    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM TIME+ COMMAND
>> 18722 root      20   0       0      0      0 I   9.5   0.0 0:47.52
>> [kworker/1:3-events_freezable_power_]
>>
>>    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM TIME+ COMMAND
>>    776 root      20   0       0      0      0 I   8.6   0.0 0:02.77
>> [kworker/0:4-events]
> The first one looks like it's part of the workqueue code.


Any guessed reason for that?


>
>> Therefore CPU doesn't switch to low frequencies (see below).
> You said previously that those crashes were happening when the board
> was changing frequency, so I'm confused?


For the ondemand setting: due to the high load of kworker, the frequency 
is not changing often to lower values (but does some time and crashes 
also regularly)

For the performance setting: frequency is fixed (to maximum in the 
current configuration) and is stable


>
>> Any ideas?
> Run the cpustress program I told you to use already twice.

Had no time to try it yet. Will do. See also my comment below regarding 
idle CPU and high CPU.


>
>> BTW: Still stable at aboout 2,5days on both devices. So solution IS the
>> performance governor.
> No, the performance governor prevents any change in frequency. My
> guess is that a lower frequency operating point is not working and is
> crashing the CPU.
>

Yes, there might at least 2 scenarios:

1.) Frequency switching itself is the problem

2.) lower frequency/voltage operating points are not stable.

For both scenarios: it might be possible that the crash happens on idle 
CPU, high CPU load or just randomly. Therefore just "waiting" might be 
better than 100% CPU utilization.But will test also 100% CPU.

Therefore it would be good to see where the voltages for different 
frequencies for the SoC are defined (to compare).


I'm currently testing 2 different settings on the 2 new Banana Pi R1 
with newest kernel (see below), so 2 static frequencies:

# Set to specific frequency 144000 (currently testing on Banana Pi R1 #1)

# Set to specific frequency 312000 (currently testing on Banana Pi R1 #2)

If that's fine I'll test also further frequencies (with different loads).

Thnx.

Ciao,

Gerhard


# Set to max performance (stable)
echo "performance" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo "performance" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
echo "144000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo "960000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
echo "144000" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq
echo "960000" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq

# Set to ondemand (not stable)
echo "ondemand" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo "ondemand" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
echo "144000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo "960000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
echo "144000" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq
echo "960000" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq

# Set to specific frequency 144000 (currently testing on Banana Pi R1 #1)
echo "performance" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo "performance" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
echo "144000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo "144000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
echo "144000" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq
echo "144000" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq

# Set to specific frequency 312000 (currently testing on Banana Pi R1 #2)
echo "performance" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo "performance" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
echo "312000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo "312000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
echo "312000" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq
echo "312000" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq

# Set to specific frequency 528000 (untested)
echo "performance" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo "performance" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
echo "528000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo "528000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
echo "528000" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq
echo "528000" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq

# Set to specific frequency 720000 (untested)
echo "performance" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo "performance" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
echo "720000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo "720000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
echo "720000" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq
echo "720000" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq

# Set to specific frequency 864000 (untested)
echo "performance" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo "performance" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
echo "864000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo "864000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
echo "864000" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq
echo "864000" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq

# Set to specific frequency 912000 (untested)
echo "performance" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo "performance" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
echo "912000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo "912000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
echo "912000" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq
echo "912000" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq

# Set to specific frequency 960000 (untested)
echo "performance" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo "performance" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
echo "960000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
echo "960000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
echo "960000" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq
echo "960000" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq


