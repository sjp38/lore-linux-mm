Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76B12C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 18:58:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0E40720C01
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 18:58:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (4096-bit key) header.d=wiesinger.com header.i=@wiesinger.com header.b="s1QnbUN4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0E40720C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=wiesinger.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A1A6C8E0003; Wed, 27 Feb 2019 13:58:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9C7788E0001; Wed, 27 Feb 2019 13:58:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 890C08E0003; Wed, 27 Feb 2019 13:58:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2DC518E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 13:58:21 -0500 (EST)
Received: by mail-wm1-f70.google.com with SMTP id a19so1942602wmm.0
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 10:58:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-filter:dkim-signature:from:subject:to:cc
         :references:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=k9V2EgLm96FQo9l0q1BS4cpzhTR+vgKHSwE2UpAjRrc=;
        b=WrvyBORUQuxplsCRapnnbvL819ixOaWoSWKDE234irn7bn/eL1LpD7d/b3q7PhCaQt
         LmUkxXHzXz2dufO68Vfx4fXCvCBR47Pic8cHU3vu9nvW331MB8iyoyUXoqHuJPhvKQrQ
         zo6Wj5Ln+STQKto71y+7ZMnWUTo2iGNVgTf90USN4d6m5z0W+EmHlaCyjZYsT9uO0zH6
         GZxDnO0o/gyiBBhnQk7tLZIr3OnWTkA9DH1xYfGsRQ9xgpzoAoR37N1X1yZU09k937td
         BD3gotHl595MWMJbWmuVOFEwGHJxjru97wqx/mzjS/J0NLlD7q7pUga0wqzejNDQ65sO
         tHfg==
X-Gm-Message-State: AHQUAuavlzbxIpO/aTpbtcg5pBkSiCOgxDitdP8O0lWSAWMOtPjgfiWy
	efo3U9iGQcs/52l/XOis4n9+I6JLae8jUR7DmnkPLcEbf6eJvXh/vfBSIZQCxr7/4kfFLKj/OC+
	0BZID0ADva0iuEU31R8cgQvU4GEvrSsaQDlUzGlu+H0bj2TswpG5ljRXG5QBJsCEMaQ==
X-Received: by 2002:a1c:dc0a:: with SMTP id t10mr442731wmg.101.1551293900592;
        Wed, 27 Feb 2019 10:58:20 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia3h35ifNnISS5bThYAjh2u4UfvKdqRkMb7cHOdNcdw/ZztibFvRf7m9m4SXbwKnM2af8c8
X-Received: by 2002:a1c:dc0a:: with SMTP id t10mr442669wmg.101.1551293899247;
        Wed, 27 Feb 2019 10:58:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551293899; cv=none;
        d=google.com; s=arc-20160816;
        b=LU6j4eCn4EY7U47vMsT6AhVQBkIO4ohOgfaVUfdRdlq5iDeuzBp2iZERWgQzbq5wu6
         C23wXpWtit3UrDq65PWvPemekjUYz/jyLm2IpZ39y6KKtrSHY6OTRr/KDwkDdxzuQPK2
         CHjhNnB3lCpAprUAWn+fOJr6VVHhh/6F+yoeSaRYdZZWBBM2eAsWE0EjcgnxbtVM4pvn
         +/2WLZmBQkC+PXol2/UnYbFZHVu6jjnYpY3DEz6E5MeldRPLf00z2GvXQJV2ihbOX5ul
         dKzsAcDd641k5hqmFCdpSvm5ozZA5Jy0TL86Kfncy74qLpKgngUhV2rmxjcaZSDzEazV
         JcQA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:subject:from
         :dkim-signature:dkim-filter;
        bh=k9V2EgLm96FQo9l0q1BS4cpzhTR+vgKHSwE2UpAjRrc=;
        b=u+mNDvZfTsM5/sG/7cRX9Qi+XivqpV6bLfTKepFwK4UN5D8KSjpy6pC6MoJtE9svDb
         DQpqZTu+9Jqs9iRt86yCeRzRYylt5rgE8HfHMYJzIkOzcjcQ21Wza1Rc2jmlFZfj9q8b
         9dd9cxc0oxxAQE9M14Uvz67s2MjQkiP7UJgS+WH+HHPwf8Di73AwTszcXRjKFM5Uj8O7
         b+zgcuInlZ/1f47bdD7u90lCjglmwLDW+lDgJmhVkP/05uzJaTb/F4eIE0ekWhIREt+y
         2VPaGZgK6h4WDyVGq1JRLf68nqL4bkZrD7PPVTzNU6mMjmUReyn3aeB52KQ2L1xNIakO
         XSgg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@wiesinger.com header.s=default header.b=s1QnbUN4;
       spf=pass (google.com: domain of lists@wiesinger.com designates 46.36.37.179 as permitted sender) smtp.mailfrom=lists@wiesinger.com
Received: from vps01.wiesinger.com (vps01.wiesinger.com. [46.36.37.179])
        by mx.google.com with ESMTPS id o184si1750976wma.89.2019.02.27.10.58.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 27 Feb 2019 10:58:18 -0800 (PST)
Received-SPF: pass (google.com: domain of lists@wiesinger.com designates 46.36.37.179 as permitted sender) client-ip=46.36.37.179;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@wiesinger.com header.s=default header.b=s1QnbUN4;
       spf=pass (google.com: domain of lists@wiesinger.com designates 46.36.37.179 as permitted sender) smtp.mailfrom=lists@wiesinger.com
Received: from wiesinger.com (wiesinger.com [84.113.44.87])
	by vps01.wiesinger.com (Postfix) with ESMTPS id 30B399F294;
	Wed, 27 Feb 2019 19:58:17 +0100 (CET)
Received: from [192.168.0.14] ([192.168.0.14])
	(authenticated bits=0)
	by wiesinger.com (8.15.2/8.15.2) with ESMTPSA id x1RIwEJ7020957
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Wed, 27 Feb 2019 19:58:15 +0100
DKIM-Filter: OpenDKIM Filter v2.11.0 wiesinger.com x1RIwEJ7020957
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=wiesinger.com;
	s=default; t=1551293895;
	bh=k9V2EgLm96FQo9l0q1BS4cpzhTR+vgKHSwE2UpAjRrc=;
	h=From:Subject:To:Cc:References:Date:In-Reply-To:From;
	b=s1QnbUN4fRYJIGa6ezZZ+UnTCx3fw/hjMGmbaKOgSC72VITdIzJDLnSWb3ai+cFgK
	 1umlI9UiV0A9kL7hyOWGRGb3bsHKBB2W9PaAghQ2KfNyo0jhQX2XlPL5IBQe5BIStZ
	 RbyBEINZATmchaySIHxqdjItCGHUkqdIyiZmN5fRtTIrH1tRORR2kwwT3dP/aXkCGA
	 IIRg10h1zMY/uREuAgoVdDK/k2JUqhv8uE1XrKqj/Xe66LHXEmrc2s9KiMUMqAYd0X
	 JNZ1FgIjTQPz+o6/NsYgCbNWzTb2hx2V3hre1zh7nV8IAlPLc961gByL+HRpT1g9hn
	 I8S7HInr5yDOVa8OqsCeffIN9vnmlgXgGlDFGCjXlNrl3kqSEUAk7nPDf44QGS/ckI
	 u/QRKRN+kCPbvTTtQN/RAldp65mftDxCFDPM4EAi6DSox0dCO0lgW99Yj5rTl8VZjV
	 n0hiHN4CqgCYR5qYbjJHql3qm9RrfA+aAzw/jhPbd9YHUTukp1IwA67bbS8bPl6O7+
	 7+sv63X39mE9S6Tns8D17iMIWzg3RHeEiDpeZXA8Muh8736EE2Gun/KGaD7TOdIK7t
	 HG7oQo4XHWle1y35snQpOHBzXcreclq2zTPv8RD3EthGInZ9YWaa46V2M1OpFbdRyl
	 w1s960iHnpC2PTni7LGG1n/Y=
From: Gerhard Wiesinger <lists@wiesinger.com>
Subject: Re: Banana Pi-R1 stabil
To: Maxime Ripard <maxime.ripard@bootlin.com>
Cc: arm@lists.fedoraproject.org, Chen-Yu Tsai <wens@csie.org>,
        LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
        Florian Fainelli <f.fainelli@gmail.com>, filbar@centrum.cz
References: <7b20af72-76ea-a7b1-9939-ca378dc0ed83@wiesinger.com>
 <20190227092023.nvr34byfjranujfm@flea>
Message-ID: <5f63a2c6-abcb-736f-d382-18e8cea31b65@wiesinger.com>
Date: Wed, 27 Feb 2019 19:58:14 +0100
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.2
MIME-Version: 1.0
In-Reply-To: <20190227092023.nvr34byfjranujfm@flea>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 27.02.2019 10:20, Maxime Ripard wrote:
> On Sun, Feb 24, 2019 at 09:04:57AM +0100, Gerhard Wiesinger wrote:
>> Hello,
>>
>> I've 3 Banana Pi R1, one running with self compiled kernel
>> 4.7.4-200.BPiR1.fc24.armv7hl and old Fedora 25 which is VERY STABLE, the 2
>> others are running with Fedora 29 latest, kernel 4.20.10-200.fc29.armv7hl. I
>> tried a lot of kernels between of around 4.11
>> (kernel-4.11.10-200.fc25.armv7hl) until 4.20.10 but all had crashes without
>> any output on the serial console or kernel panics after a short time of
>> period (minutes, hours, max. days)
>>
>> Latest known working and stable self compiled kernel: kernel
>> 4.7.4-200.BPiR1.fc24.armv7hl:
>>
>> https://www.wiesinger.com/opensource/fedora/kernel/BananaPi-R1/
>>
>> With 4.8.x the DSA b53 switch infrastructure has been introduced which
>> didn't work (until ca8931948344c485569b04821d1f6bcebccd376b and kernel
>> 4.18.x):
>>
>> https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/tree/drivers/net/dsa/b53?h=v4.20.12
>>
>> https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/log/drivers/net/dsa/b53?h=v4.20.12
>>
>> https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/commit/drivers/net/dsa/b53?h=v4.20.12&id=ca8931948344c485569b04821d1f6bcebccd376b
>>
>> I has been fixed with kernel 4.18.x:
>>
>> https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/log/drivers/net/dsa/b53?h=linux-4.18.y
>>
>>
>> So current status is, that kernel crashes regularly, see some samples below.
>> It is typically a "Unable to handle kernel paging request at virtual addres"
>>
>> Another interesting thing: A Banana Pro works well (which has also an
>> Allwinner A20 in the same revision) running same Fedora 29 and latest
>> kernels (e.g. kernel 4.20.10-200.fc29.armv7hl.).
>>
>> Since it happens on 2 different devices and with different power supplies
>> (all with enough power) and also the same type which works well on the
>> working old kernel) a hardware issue is very unlikely.
>>
>> I guess it has something to do with virtual memory.
>>
>> Any ideas?
>> [47322.960193] Unable to handle kernel paging request at virtual addres 5675d0
> That line is a bit suspicious
>
> Anyway, cpufreq is known to cause those kind of errors when the
> voltage / frequency association is not correct.
>
> Given the stack trace and that the BananaPro doesn't have cpufreq
> enabled, my first guess would be that it's what's happening. Could you
> try using the performance governor and see if it's more stable?
>
> If it is, then using this:
> https://github.com/ssvb/cpuburn-arm/blob/master/cpufreq-ljt-stress-test
>
> will help you find the offending voltage-frequency couple.
>
> Maxime
>
For me it looks like they have all the same config regarding cpu 
governor (Banana Pro, old kernel stable one, new kernel unstable ones)

They all have the ondemand governor set:

I set on the 2 unstable "new kernel Banana Pi R1":

# Set to max performance
echo "performance" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
echo "performance" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor

Running some stress tests are ok (I did that already in the past, but 
without setting maximum performance governor).

Let's see if it helps.

Thnx.

Ciao,

Gerhard

# Banana Pro: Stable

./cpu_freq.sh
/sys/devices/system/cpu/cpu0/cpufreq/affected_cpus: 0 1
/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq: 960000
/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq: 960000
/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq: 144000
/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_transition_latency: 244144
/sys/devices/system/cpu/cpu0/cpufreq/related_cpus: 0 1
/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies: 
144000 312000 528000 720000 864000 912000 960000
/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors: 
conservative userspace powersave ondemand performance schedutil
/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq: 960000
/sys/devices/system/cpu/cpu0/cpufreq/scaling_driver: cpufreq-dt
/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor: ondemand
/sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq: 960000
/sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq: 144000
/sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed: <unsupported>
/sys/devices/system/cpu/cpu1/cpufreq/affected_cpus: 0 1
/sys/devices/system/cpu/cpu1/cpufreq/cpuinfo_cur_freq: 912000
/sys/devices/system/cpu/cpu1/cpufreq/cpuinfo_max_freq: 960000
/sys/devices/system/cpu/cpu1/cpufreq/cpuinfo_min_freq: 144000
/sys/devices/system/cpu/cpu1/cpufreq/cpuinfo_transition_latency: 244144
/sys/devices/system/cpu/cpu1/cpufreq/related_cpus: 0 1
/sys/devices/system/cpu/cpu1/cpufreq/scaling_available_frequencies: 
144000 312000 528000 720000 864000 912000 960000
/sys/devices/system/cpu/cpu1/cpufreq/scaling_available_governors: 
conservative userspace powersave ondemand performance schedutil
/sys/devices/system/cpu/cpu1/cpufreq/scaling_cur_freq: 912000
/sys/devices/system/cpu/cpu1/cpufreq/scaling_driver: cpufreq-dt
/sys/devices/system/cpu/cpu1/cpufreq/scaling_governor: ondemand
/sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq: 960000
/sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq: 144000
/sys/devices/system/cpu/cpu1/cpufreq/scaling_setspeed: <unsupported>

# Banana Pi R1: The one which is running kernel 4.7.4 and stable
./cpu_freq.sh
/sys/devices/system/cpu/cpu0/cpufreq/affected_cpus: 0 1
/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq: 144000
/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq: 960000
/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq: 144000
/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_transition_latency: 244144
/sys/devices/system/cpu/cpu0/cpufreq/related_cpus: 0 1
/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies: 
144000 312000 528000 720000 864000 912000 960000
/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors: 
conservative userspace powersave schedutil ondemand performance
/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq: 312000
/sys/devices/system/cpu/cpu0/cpufreq/scaling_driver: cpufreq-dt
/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor: ondemand
/sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq: 960000
/sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq: 144000
/sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed: <unsupported>
/sys/devices/system/cpu/cpu1/cpufreq/affected_cpus: 0 1
/sys/devices/system/cpu/cpu1/cpufreq/cpuinfo_cur_freq: 720000
/sys/devices/system/cpu/cpu1/cpufreq/cpuinfo_max_freq: 960000
/sys/devices/system/cpu/cpu1/cpufreq/cpuinfo_min_freq: 144000
/sys/devices/system/cpu/cpu1/cpufreq/cpuinfo_transition_latency: 244144
/sys/devices/system/cpu/cpu1/cpufreq/related_cpus: 0 1
/sys/devices/system/cpu/cpu1/cpufreq/scaling_available_frequencies: 
144000 312000 528000 720000 864000 912000 960000
/sys/devices/system/cpu/cpu1/cpufreq/scaling_available_governors: 
conservative userspace powersave schedutil ondemand performance
/sys/devices/system/cpu/cpu1/cpufreq/scaling_cur_freq: 720000
/sys/devices/system/cpu/cpu1/cpufreq/scaling_driver: cpufreq-dt
/sys/devices/system/cpu/cpu1/cpufreq/scaling_governor: ondemand
/sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq: 960000
/sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq: 144000
/sys/devices/system/cpu/cpu1/cpufreq/scaling_setspeed: <unsupported>

# Non Stable, Banana Pi R1 #1
./cpu_freq.sh
/sys/devices/system/cpu/cpu0/cpufreq/affected_cpus: 0 1
/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq: 912000
/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq: 960000
/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq: 144000
/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_transition_latency: 244144
/sys/devices/system/cpu/cpu0/cpufreq/related_cpus: 0 1
/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies: 
144000 312000 528000 720000 864000 912000 960000
/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors: 
conservative userspace powersave ondemand performance schedutil
/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq: 912000
/sys/devices/system/cpu/cpu0/cpufreq/scaling_driver: cpufreq-dt
/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor: ondemand
/sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq: 960000
/sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq: 144000
/sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed: <unsupported>
/sys/devices/system/cpu/cpu1/cpufreq/affected_cpus: 0 1
/sys/devices/system/cpu/cpu1/cpufreq/cpuinfo_cur_freq: 960000
/sys/devices/system/cpu/cpu1/cpufreq/cpuinfo_max_freq: 960000
/sys/devices/system/cpu/cpu1/cpufreq/cpuinfo_min_freq: 144000
/sys/devices/system/cpu/cpu1/cpufreq/cpuinfo_transition_latency: 244144
/sys/devices/system/cpu/cpu1/cpufreq/related_cpus: 0 1
/sys/devices/system/cpu/cpu1/cpufreq/scaling_available_frequencies: 
144000 312000 528000 720000 864000 912000 960000
/sys/devices/system/cpu/cpu1/cpufreq/scaling_available_governors: 
conservative userspace powersave ondemand performance schedutil
/sys/devices/system/cpu/cpu1/cpufreq/scaling_cur_freq: 912000
/sys/devices/system/cpu/cpu1/cpufreq/scaling_driver: cpufreq-dt
/sys/devices/system/cpu/cpu1/cpufreq/scaling_governor: ondemand
/sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq: 960000
/sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq: 144000
/sys/devices/system/cpu/cpu1/cpufreq/scaling_setspeed: <unsupported>

# Non Stable, Banana Pi R1 #2

./cpu_freq.sh
/sys/devices/system/cpu/cpu0/cpufreq/affected_cpus: 0 1
/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq: 912000
/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq: 960000
/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq: 144000
/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_transition_latency: 244144
/sys/devices/system/cpu/cpu0/cpufreq/related_cpus: 0 1
/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies: 
144000 312000 528000 720000 864000 912000 960000
/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors: 
conservative userspace powersave ondemand performance schedutil
/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq: 912000
/sys/devices/system/cpu/cpu0/cpufreq/scaling_driver: cpufreq-dt
/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor: ondemand
/sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq: 960000
/sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq: 144000
/sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed: <unsupported>
/sys/devices/system/cpu/cpu1/cpufreq/affected_cpus: 0 1
/sys/devices/system/cpu/cpu1/cpufreq/cpuinfo_cur_freq: 960000
/sys/devices/system/cpu/cpu1/cpufreq/cpuinfo_max_freq: 960000
/sys/devices/system/cpu/cpu1/cpufreq/cpuinfo_min_freq: 144000
/sys/devices/system/cpu/cpu1/cpufreq/cpuinfo_transition_latency: 244144
/sys/devices/system/cpu/cpu1/cpufreq/related_cpus: 0 1
/sys/devices/system/cpu/cpu1/cpufreq/scaling_available_frequencies: 
144000 312000 528000 720000 864000 912000 960000
/sys/devices/system/cpu/cpu1/cpufreq/scaling_available_governors: 
conservative userspace powersave ondemand performance schedutil
/sys/devices/system/cpu/cpu1/cpufreq/scaling_cur_freq: 912000
/sys/devices/system/cpu/cpu1/cpufreq/scaling_driver: cpufreq-dt
/sys/devices/system/cpu/cpu1/cpufreq/scaling_governor: ondemand
/sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq: 960000
/sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq: 144000
/sys/devices/system/cpu/cpu1/cpufreq/scaling_setspeed: <unsupported>

cat cpu_freq.sh
#!/bin/sh

MAX_CPU=2
let MAX_CPU_1=MAX_CPU-1

CPUS=`seq 0 ${MAX_CPU_1}`

for CPU in ${CPUS}; do
   for i in /sys/devices/system/cpu/cpu${CPU}/cpufreq/*; do
     if [ -f $i ]; then
       echo $i: `cat $i`
     fi
   done
done

