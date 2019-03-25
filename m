Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23087C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 00:38:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C6B582171F
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 00:38:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="LvbuDSLe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C6B582171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A6916B0005; Sun, 24 Mar 2019 20:38:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 655586B0007; Sun, 24 Mar 2019 20:38:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 56C996B0008; Sun, 24 Mar 2019 20:38:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 17ED06B0005
	for <linux-mm@kvack.org>; Sun, 24 Mar 2019 20:38:43 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id f1so7795694pgv.12
        for <linux-mm@kvack.org>; Sun, 24 Mar 2019 17:38:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:to:to:cc:cc:cc:cc:cc
         :cc:cc:cc:subject:in-reply-to:references:message-id;
        bh=/oJQpet8URiZBR3gu5LiPabZo0Xozbg1IolWQQ9laLk=;
        b=knxQv6XjaesOZwryy+sjm7Cp6fkcLks6gNBkgIHnWKb9YVh98ljYByi8dN8WW9cus1
         BeBprFX+b0t0d2T+Gguj8HrNJtlTv9fJTagXSW2ZHYU3rEb6EZI4sz4fbff84GvJFtv9
         dBHJqKAYNuTEGfquixkgEmKvBgJeDPrYgSdpD0ItpuhC+PKBXwZUoW7ISQiW+kj7nGyu
         LGoUyOKcF8VZNFP3bJj1cALPPvy1voZk+UKK8PRecpBjkq1qT+MGwA9pl892TW51zEX0
         o4cCIfzlkX11HHjyZ4zpKpil8aKU9rFfaz3c3r1FYoBI6oN78kXvDKrhPnQsUW2ho/02
         AW4A==
X-Gm-Message-State: APjAAAUCKGjPCFLDR+t218VgGZSNWb1j0zrTI6NPZJlsPoL4pbLdnmKl
	PNLSbdfUIRJ+OMuMJGGmETYgLLeGfWfCGbGnSQgVlXUtl2VLTVEWBw5al7L2mrREbpOw2U/s+sB
	m3EDaGA3VQuFt3kNB5NuliZGPHZbgmuac5cUsQIu8OCub93LYg9aN+h5DqCYVgi8bSA==
X-Received: by 2002:a65:508b:: with SMTP id r11mr20744270pgp.242.1553474322668;
        Sun, 24 Mar 2019 17:38:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx4ff6xgLXZHWKn+/DbTC4FOPi0zRWBddWluTWsaQnx8XxKC3KAE9WBtQ92mfmi0TSQs89R
X-Received: by 2002:a65:508b:: with SMTP id r11mr20744236pgp.242.1553474321854;
        Sun, 24 Mar 2019 17:38:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553474321; cv=none;
        d=google.com; s=arc-20160816;
        b=UbGQbovpzrXgzF3xzKMrMBBfo8HXrWNY9wrCCVt/xF+anP4w5iiEhsd+YdcWS00LV7
         q1u1GvMttXoujMeoGXEptKxcJQ9UKOQIo+AymBNdbjuUlBO6iJopw9aO9u/6f7PIglB7
         S+Ljb5l+qL95ogMMuB4frhVJkGErVLcf1/NMnEBJjB6oWVSNFUKtTTJl3rpNB+e5sVvE
         QI8pSE6WHqJiqw0Sghv37974xn8qJ4G9/SS5ajv6w+BxteNan369f0gH5gxLYuB8URbd
         FINwZtf3e6JXnqgmdAzCoAN2Lw/SYMnWZRyWuf/32ZITPMZ3SbAx+429x09cl1/+74Ti
         IFXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:references:in-reply-to:subject:cc:cc:cc:cc:cc:cc:cc:cc
         :to:to:to:from:date:dkim-signature;
        bh=/oJQpet8URiZBR3gu5LiPabZo0Xozbg1IolWQQ9laLk=;
        b=y3fEUXz0Q/ZUZ85zTpSp8XKdLza5sloNcYTYXXTKFIJS8qZjv4tNu9MnRNQdbancij
         IPzLR21JxWue9kFyCFlJ8LB6R1YrjE+rC03Vps3cALbK5rVPxy1hFm0Ij1HhIDbAM6/w
         9a5cDpg5xg32UMBhSmFETjjVz6BOAnPeO11sXt4vMUjIuf3S+3c1z012Sxk1k99zzO++
         /Tgxzl07io5rMC8AclT+eEnObPEVRxQ15qhA5FazU7csK7a5l/8vzi+Kyb3t02KOIiNn
         NGBZKOBApw3QyY8EBm9YDXSuNrR8cRoT7rIwDSlAoniyqmD9n/pinr9PJGewLrq7baud
         UWpA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=LvbuDSLe;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id g5si12085961pgq.486.2019.03.24.17.38.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 Mar 2019 17:38:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=LvbuDSLe;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (unknown [23.100.24.84])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 503582148D;
	Mon, 25 Mar 2019 00:38:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1553474321;
	bh=rHF4u6Lyit+LBq8dwED/INYcQiWxbAi7EuxMwg3Yvow=;
	h=Date:From:To:To:To:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Cc:Subject:In-Reply-To:
	 References:From;
	b=LvbuDSLeT1Z7Fj/GKiR/xpIn1ufBUjmyvUmW5Q8SvLRu0iAgCBQiF5S8QokFIO51K
	 J0wUZRCNJfh9N9bk4frtNtCJst4SIiKgyl+uMxHG08BR9juha9ejK6pUoiOq8CW8H5
	 6B1UVAd5RJbbgVzCFaUILbwTtuVT2PaiHciRK/lk=
Date: Mon, 25 Mar 2019 00:38:40 +0000
From: Sasha Levin <sashal@kernel.org>
To: Sasha Levin <sashal@kernel.org>
To:   Laurent Dufour <ldufour@linux.ibm.com>
To:     linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc:     stable@vger.kernel.org, Christoph Lameter <cl@linux.com>,
Cc: stable@vger.kernel.org
Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: stable@vger.kernel.org
Subject: Re: [PATCH] mm/slab: protect cache_reap() against CPU and memory hot plug operations
In-Reply-To: <20190311191701.24325-1-ldufour@linux.ibm.com>
References: <20190311191701.24325-1-ldufour@linux.ibm.com>
Message-Id: <20190325003841.503582148D@mail.kernel.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

[This is an automated email]

This commit has been processed because it contains a -stable tag.
The stable tag indicates that it's relevant for the following trees: all

The bot has tested the following trees: v5.0.3, v4.19.30, v4.14.107, v4.9.164, v4.4.176, v3.18.136.

v5.0.3: Build OK!
v4.19.30: Build OK!
v4.14.107: Build OK!
v4.9.164: Build OK!
v4.4.176: Failed to apply! Possible dependencies:
    27590dc17b34 ("hrtimer: Convert to hotplug state machine")
    31487f8328f2 ("smp/cfd: Convert core to hotplug state machine")
    512089d98457 ("perf/x86/intel/rapl: Clean up the printk output")
    55f2890f0726 ("perf/x86/intel/rapl: Add proper error handling")
    57ecde42cc74 ("powerpc/perf: Convert book3s notifier to state machine callbacks")
    6731d4f12315 ("slab: Convert to hotplug state machine")
    6b2c28471de5 ("x86/x2apic: Convert to CPU hotplug state machine")
    7162b8fea630 ("perf/x86/intel/rapl: Refactor the code some more")
    75c7003fbf41 ("perf/x86/intel/rapl: Calculate timing once")
    7ee681b25284 ("workqueue: Convert to state machine callbacks")
    8a6d2f8f73ca ("perf/x86/intel/rapl: Utilize event->pmu_private")
    8b5b773d6245 ("perf/x86/intel/rapl: Convert to hotplug state machine")
    9de8d686955b ("perf/x86/intel/rapl: Convert it to a per package facility")
    a208749c6426 ("perf/x86/intel/rapl: Make PMU lock raw")
    a409f5ee2937 ("blackfin/perf: Convert hotplug notifier to state machine")
    b8b3319a471b ("perf/x86/intel/rapl: Sanitize the quirk handling")
    e3cfce17d309 ("sh/perf: Convert the hotplug notifiers to state machine callbacks")
    e6d4989a9ad1 ("relayfs: Convert to hotplug state machine")
    e722d8daafb9 ("profile: Convert to hotplug state machine")

v3.18.136: Failed to apply! Possible dependencies:
    13ca62b243f6 ("ACPI: Fix minor syntax issues in processor_core.c")
    27590dc17b34 ("hrtimer: Convert to hotplug state machine")
    31487f8328f2 ("smp/cfd: Convert core to hotplug state machine")
    4daa832d9987 ("x86: Drop bogus __ref / __refdata annotations")
    57ecde42cc74 ("powerpc/perf: Convert book3s notifier to state machine callbacks")
    645523960102 ("perf/x86/intel/rapl: Fix energy counter measurements but supporing per domain energy units")
    6731d4f12315 ("slab: Convert to hotplug state machine")
    6b2c28471de5 ("x86/x2apic: Convert to CPU hotplug state machine")
    7162b8fea630 ("perf/x86/intel/rapl: Refactor the code some more")
    7ee681b25284 ("workqueue: Convert to state machine callbacks")
    828aef376d7a ("ACPI / processor: Introduce phys_cpuid_t for CPU hardware ID")
    8b5b773d6245 ("perf/x86/intel/rapl: Convert to hotplug state machine")
    9de8d686955b ("perf/x86/intel/rapl: Convert it to a per package facility")
    a409f5ee2937 ("blackfin/perf: Convert hotplug notifier to state machine")
    af8f3f514d19 ("ACPI / processor: Convert apic_id to phys_id to make it arch agnostic")
    d02dc27db0dc ("ACPI / processor: Rename acpi_(un)map_lsapic() to acpi_(un)map_cpu()")
    d089f8e97d37 ("x86: fix up obsolete cpu function usage.")
    e3cfce17d309 ("sh/perf: Convert the hotplug notifiers to state machine callbacks")
    e6d4989a9ad1 ("relayfs: Convert to hotplug state machine")
    e722d8daafb9 ("profile: Convert to hotplug state machine")
    ecf5636dcd59 ("ACPI: Add interfaces to parse IOAPIC ID for IOAPIC hotplug")
    fdaf3a6539d6 ("x86: fix more deprecated cpu function usage.")


How should we proceed with this patch?

--
Thanks,
Sasha

