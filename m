Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D6DF3C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 19:42:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 86FC620C01
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 19:42:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (4096-bit key) header.d=wiesinger.com header.i=@wiesinger.com header.b="oSQE+JMq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86FC620C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=wiesinger.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 288808E0004; Thu, 28 Feb 2019 14:42:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 239E78E0001; Thu, 28 Feb 2019 14:42:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 102588E0004; Thu, 28 Feb 2019 14:42:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id A755E8E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 14:42:16 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id c69so3624935wme.5
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 11:42:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-filter:dkim-signature:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=mQ6B9ieNdz4PAnuOETRKFulbTteDNeeJbQHKd6FtlRo=;
        b=TbX2oU89LhyxAF7jCup9Pnk92zAq0H56AUI2O6GIBNAL5shFl5ryf9rVzZeEENPg4D
         V+8INrkF8VfQ5MVq4+5TNvbSI079Kubgs/h9gt2YegvyBmtShkjtdF2cE38oLk5tMlc3
         gdEea7u9Czfb8sPMYjmJ0NNfi6rNJg023WooYAJDeoJlmEbzHbKaJSoIjkgmDI8d0GFt
         0RsvHGS9EjhdLt5GN532xYIET4ZXv2guoFz5gVwI4qQ9mdwzb+hOJoURx2apJ9j76jKk
         ujs7YQ4mk8rKT0UqUY4sGjVH6sNjoKc67+cR4bTkcACvMAWMAARxQnNFOf6LUcb4UZgP
         xScw==
X-Gm-Message-State: APjAAAUXfCJcDmw/mi2MlrokOVZdzQq6bjRxnS619y9/t2c0NgkEgKpA
	jXh9BEpCxoN5hk2OTPSril9BCUDCp01O0NHTLmjmf9eP17zeY6ZVP30GQUujahln6MGXI/BRX16
	F310/XJ3RCg6IFmHoEU32eqA9qjty0F/M+9+KP+vw4SNry61xavKwNscTNgs+olaJ8A==
X-Received: by 2002:a7b:c352:: with SMTP id l18mr812279wmj.127.1551382936099;
        Thu, 28 Feb 2019 11:42:16 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZkAZfkAHM5CZyLsTs4MRmDKopYSa/JB06xETdH7LzfyjYrWl7fJ5sPRsMnfheLTpaLeOvj
X-Received: by 2002:a7b:c352:: with SMTP id l18mr812234wmj.127.1551382934928;
        Thu, 28 Feb 2019 11:42:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551382934; cv=none;
        d=google.com; s=arc-20160816;
        b=0AbIMSEn1u0ZjWIcRAtBKhcbpwo1leP3fIRjI95t10PQMJXd/zEcIo59lD3OjAcvF5
         inztMi1YwXfvplGDxqTQvE4xUIokJ5qi44KYCPbxX39by+YgSO49kMrkx5jMzR8vDiH9
         n215CyFh9+PV9T8qsqo/cPM8SR3gtvi2HhqDbj8mWT5deMn4MYCibcYxLidqkSknMQzD
         lS00nErEvwuneQ5v09CvqEtumxSqyHtp6xv6wwcUMQb0ZklJ6l2RLM8wvAC+rutO9EWo
         pDD6wIACx/zyZ6nFVPuICwvqp+DK3i5/CsQyHD9hRdmZfQn6OJJZknjfgexPjN7EIcsm
         7xag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature:dkim-filter;
        bh=mQ6B9ieNdz4PAnuOETRKFulbTteDNeeJbQHKd6FtlRo=;
        b=YOAb8YqSCRRtAk8uJo+UPTYz/qGT1cInCFrjMCcPOhT0wWjy3IBq60SawUuTlslR/E
         on7bMTgDtArXY00eAsefrh3qokdFwnRpaadT3Ezgb+7gqJ/V4OtvXwzVkFT8QbwsP6cx
         hqg9DpK/7z784NvRY6un1GxEPlyprCgXbsMA4c4CsI1nTgO8gflrI/LnXhuqCDQcUdQn
         TFKPWaViZtEc9aj/LDWi1Xd2c3019otaMU1vbR+WxuL6jW65ejlIfXndtA/dQWSrXVUE
         Kzk7yA373mn16J+TnGtp9UX/7eqcEgqTC5A/KnPLbUqm/hN1Rlb8JRyWXKTz8+vsk+1c
         QxDQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@wiesinger.com header.s=default header.b=oSQE+JMq;
       spf=pass (google.com: domain of lists@wiesinger.com designates 46.36.37.179 as permitted sender) smtp.mailfrom=lists@wiesinger.com
Received: from vps01.wiesinger.com (vps01.wiesinger.com. [46.36.37.179])
        by mx.google.com with ESMTPS id k6si13118652wre.173.2019.02.28.11.42.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Feb 2019 11:42:14 -0800 (PST)
Received-SPF: pass (google.com: domain of lists@wiesinger.com designates 46.36.37.179 as permitted sender) client-ip=46.36.37.179;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@wiesinger.com header.s=default header.b=oSQE+JMq;
       spf=pass (google.com: domain of lists@wiesinger.com designates 46.36.37.179 as permitted sender) smtp.mailfrom=lists@wiesinger.com
Received: from wiesinger.com (wiesinger.com [84.113.44.87])
	by vps01.wiesinger.com (Postfix) with ESMTPS id 649D89F294;
	Thu, 28 Feb 2019 20:42:13 +0100 (CET)
Received: from [192.168.0.14] ([192.168.0.14])
	(authenticated bits=0)
	by wiesinger.com (8.15.2/8.15.2) with ESMTPSA id x1SJfsmP010673
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Thu, 28 Feb 2019 20:41:55 +0100
DKIM-Filter: OpenDKIM Filter v2.11.0 wiesinger.com x1SJfsmP010673
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=wiesinger.com;
	s=default; t=1551382915;
	bh=mQ6B9ieNdz4PAnuOETRKFulbTteDNeeJbQHKd6FtlRo=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=oSQE+JMqmGjlHlZvsAUeXSinXzknHpdy5bO14bl78Vcl3jb6Gwln5wZvQRfWEpA7m
	 4gIW0QKVXbwv6n4TRHYbwwTvCyImwl87SOKOEE6mJRjA+cOzrk8mcRPXHjU4Kpb4lR
	 efcQvY8X7X7QHO+WdgFQGfnRmWGsA2VxDmQdpDPePz7UimDpLDbXS7pVzCkvB5LoJq
	 5a+9z4h0r51atE1UY5/IHEb4C5PHJAVnviE6t8KDbpO+7Bl1cMIJc9GFu7xHAhxtsQ
	 zHWWRJmBwiC6+1m8fbDi5XyM3z0P3rGAA9HWUhKBQCm+wq94B4sHYQ7PANtU3UlYGz
	 wM8Ort5LZLfKrKdbj/189DPYdDv0fmLcGrLgTVvh+xZj6N2noZBaLOckyKU58PnliT
	 0B042sx+rKOcvQj0ouqVyvUqqA5z5TpAC9F0xb/XW1K2qumIN2nPFm/Omq6I5FfJdv
	 bkVAshZ3G5yF3xI3Ji6hqzKRHWEbleJ2g6/g6RN89ABRYkh/+iUrwOQvxXAmoHkZ7N
	 zrbG6pVrdR1GUlj2kQzKFdk4/OHy0y2TEZHHqiJzTSvzEcdD4vvtE6v7GNSCMcarns
	 ljTdSjBjEeJJu5AMy9kESQyBYFmsgKNG6V2jk3XqG3bhcb/KqZ2ByV87JyhOLULvth
	 bi1IFIlOrlxYxKaC0QBXKZ0M=
Subject: Re: Banana Pi-R1 stabil
To: Maxime Ripard <maxime.ripard@bootlin.com>
Cc: arm@lists.fedoraproject.org, Chen-Yu Tsai <wens@csie.org>,
        LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
        Florian Fainelli <f.fainelli@gmail.com>, filbar@centrum.cz
References: <7b20af72-76ea-a7b1-9939-ca378dc0ed83@wiesinger.com>
 <20190227092023.nvr34byfjranujfm@flea>
 <5f63a2c6-abcb-736f-d382-18e8cea31b65@wiesinger.com>
 <20190228093516.abual3564dkvx6un@flea>
From: Gerhard Wiesinger <lists@wiesinger.com>
Message-ID: <91c22ba4-39eb-dd3d-29bd-1bfa7a45e9cd@wiesinger.com>
Date: Thu, 28 Feb 2019 20:41:53 +0100
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.2
MIME-Version: 1.0
In-Reply-To: <20190228093516.abual3564dkvx6un@flea>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 28.02.2019 10:35, Maxime Ripard wrote:
> On Wed, Feb 27, 2019 at 07:58:14PM +0100, Gerhard Wiesinger wrote:
>> On 27.02.2019 10:20, Maxime Ripard wrote:
>>> On Sun, Feb 24, 2019 at 09:04:57AM +0100, Gerhard Wiesinger wrote:
>>>> Hello,
>>>>
>>>> I've 3 Banana Pi R1, one running with self compiled kernel
>>>> 4.7.4-200.BPiR1.fc24.armv7hl and old Fedora 25 which is VERY STABLE, the 2
>>>> others are running with Fedora 29 latest, kernel 4.20.10-200.fc29.armv7hl. I
>>>> tried a lot of kernels between of around 4.11
>>>> (kernel-4.11.10-200.fc25.armv7hl) until 4.20.10 but all had crashes without
>>>> any output on the serial console or kernel panics after a short time of
>>>> period (minutes, hours, max. days)
>>>>
>>>> Latest known working and stable self compiled kernel: kernel
>>>> 4.7.4-200.BPiR1.fc24.armv7hl:
>>>>
>>>> https://www.wiesinger.com/opensource/fedora/kernel/BananaPi-R1/
>>>>
>>>> With 4.8.x the DSA b53 switch infrastructure has been introduced which
>>>> didn't work (until ca8931948344c485569b04821d1f6bcebccd376b and kernel
>>>> 4.18.x):
>>>>
>>>> https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/tree/drivers/net/dsa/b53?h=v4.20.12
>>>>
>>>> https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/log/drivers/net/dsa/b53?h=v4.20.12
>>>>
>>>> https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/commit/drivers/net/dsa/b53?h=v4.20.12&id=ca8931948344c485569b04821d1f6bcebccd376b
>>>>
>>>> I has been fixed with kernel 4.18.x:
>>>>
>>>> https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/log/drivers/net/dsa/b53?h=linux-4.18.y
>>>>
>>>>
>>>> So current status is, that kernel crashes regularly, see some samples below.
>>>> It is typically a "Unable to handle kernel paging request at virtual addres"
>>>>
>>>> Another interesting thing: A Banana Pro works well (which has also an
>>>> Allwinner A20 in the same revision) running same Fedora 29 and latest
>>>> kernels (e.g. kernel 4.20.10-200.fc29.armv7hl.).
>>>>
>>>> Since it happens on 2 different devices and with different power supplies
>>>> (all with enough power) and also the same type which works well on the
>>>> working old kernel) a hardware issue is very unlikely.
>>>>
>>>> I guess it has something to do with virtual memory.
>>>>
>>>> Any ideas?
>>>> [47322.960193] Unable to handle kernel paging request at virtual addres 5675d0
>>> That line is a bit suspicious
>>>
>>> Anyway, cpufreq is known to cause those kind of errors when the
>>> voltage / frequency association is not correct.
>>>
>>> Given the stack trace and that the BananaPro doesn't have cpufreq
>>> enabled, my first guess would be that it's what's happening. Could you
>>> try using the performance governor and see if it's more stable?
>>>
>>> If it is, then using this:
>>> https://github.com/ssvb/cpuburn-arm/blob/master/cpufreq-ljt-stress-test
>>>
>>> will help you find the offending voltage-frequency couple.
>> For me it looks like they have all the same config regarding cpu governor
>> (Banana Pro, old kernel stable one, new kernel unstable ones)
> The Banana Pro doesn't have a regulator set up, so it will only change
> the frequency, not the voltage.
>
>> They all have the ondemand governor set:
>>
>> I set on the 2 unstable "new kernel Banana Pi R1":
>>
>> # Set to max performance
>> echo "performance" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
>> echo "performance" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
> What are the results?


Stable since more than around 1,5 days. Normally they have been crashed 
for such a long uptime. So it looks that the performance governor fixes it.

I guess crashes occour because of changing CPU voltage and clock changes 
and invalid data (e.g. also invalid RAM contents might be read, register 
problems, etc).

Any ideas how to fix it for ondemand mode, too?

But it doesn't explaing that it works with kernel 4.7.4 without any 
problems.


>
>> Running some stress tests are ok (I did that already in the past, but
>> without setting maximum performance governor).
> Which stress tests have you been running?


Now:

while true; do echo "========================================"; echo -n 
"TEMP     : "; cat /sys/devices/virtual/thermal/thermal_zone0/temp; echo 
-n "VOLTAGE : "; cat 
/sys/devices/platform/soc@1c00000/1c2ac00.i2c/i2c-0/0-0034/axp20x-ac-power-supply/power_supply/axp20x-ac/voltage_now; 
echo -n "CURRENT  : "; cat 
/sys/devices/platform/soc@1c00000/1c2ac00.i2c/i2c-0/0-0034/axp20x-ac-power-supply/power_supply/axp20x-ac/current_now; 
echo -n "CPU_FREQ0: "; cat 
/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq; echo -n 
"CPU_FREQ0: "; cat 
/sys/devices/system/cpu/cpu1/cpufreq/cpuinfo_cur_freq; sleep 1; done& 
stress -c 4 -t 900s

In the past also:

while true; do echo "========================================"; echo -n 
"TEMP     : "; cat /sys/devices/virtual/thermal/thermal_zone0/temp; echo 
-n "VOLTAGE : "; cat 
/sys/devices/platform/soc@1c00000/1c2ac00.i2c/i2c-0/0-0034/axp20x-ac-power-supply/power_supply/axp20x-ac/voltage_now; 
echo -n "CURRENT  : "; cat 
/sys/devices/platform/soc@1c00000/1c2ac00.i2c/i2c-0/0-0034/axp20x-ac-power-supply/power_supply/axp20x-ac/current_now; 
echo -n "CPU_FREQ0: "; cat 
/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq; echo -n 
"CPU_FREQ0: "; cat 
/sys/devices/system/cpu/cpu1/cpufreq/cpuinfo_cur_freq; sleep 1; done& 
stress-ng --cpu 4 --io 2 --vm 1 --vm-bytes 1G --timeout 900s --metrics-brief

while true; do echo "========================================"; echo -n 
"TEMP     : "; cat /sys/devices/virtual/thermal/thermal_zone0/temp; echo 
-n "VOLTAGE : "; cat 
/sys/devices/platform/soc@1c00000/1c2ac00.i2c/i2c-0/0-0034/axp20x-ac-power-supply/power_supply/axp20x-ac/voltage_now; 
echo -n "CURRENT  : "; cat 
/sys/devices/platform/soc@1c00000/1c2ac00.i2c/i2c-0/0-0034/axp20x-ac-power-supply/power_supply/axp20x-ac/current_now; 
echo -n "CPU_FREQ0: "; cat 
/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq; echo -n 
"CPU_FREQ0: "; cat 
/sys/devices/system/cpu/cpu1/cpufreq/cpuinfo_cur_freq; sleep 1; done& 
./cpuburn-a7

https://www.cyberciti.biz/faq/stress-test-linux-unix-server-with-stress-ng/
while true; do echo "========================================"; echo -n 
"TEMP     : "; cat /sys/devices/virtual/thermal/thermal_zone0/temp; echo 
-n "VOLTAGE : "; cat 
/sys/devices/platform/soc@1c00000/1c2ac00.i2c/i2c-0/0-0034/axp20x-ac-power-supply/power_supply/axp20x-ac/voltage_now; 
echo -n "CURRENT  : "; cat 
/sys/devices/platform/soc@1c00000/1c2ac00.i2c/i2c-0/0-0034/axp20x-ac-power-supply/power_supply/axp20x-ac/current_now; 
echo -n "CPU_FREQ0: "; cat 
/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq; echo -n 
"CPU_FREQ0: "; cat 
/sys/devices/system/cpu/cpu1/cpufreq/cpuinfo_cur_freq; sleep 1; done& 
stress -c 2 -i 1 -m 1 --vm-bytes 128M -t 900s


But I guess that the problems occour nots on full load but on dynamical 
switching loads (when CPU voltage and clock changes). Because the 
Bananas are typically really idle and crash (with the ondemand governor).


Thanx.

Ciao,

Gerhard

