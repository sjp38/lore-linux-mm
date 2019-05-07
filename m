Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1CE38C004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 19:50:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BB7A520825
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 19:50:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB7A520825
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 279866B000A; Tue,  7 May 2019 15:50:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 22A796B000C; Tue,  7 May 2019 15:50:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 119C06B000D; Tue,  7 May 2019 15:50:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id D19436B000A
	for <linux-mm@kvack.org>; Tue,  7 May 2019 15:50:52 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id s22so9968265plq.1
        for <linux-mm@kvack.org>; Tue, 07 May 2019 12:50:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=zcFsdjI1s+LaqmSPrrez6zaem2wf8uOZRltJ71XJpcs=;
        b=hxyxztiqv9QY3gGMxunEV3AElViOT/FVAfSdoRUeqvVehDqncw72Of3ejNqAzQ6Wiu
         rRDCMvgC7OgZ/QTOT8+TKrfk6Ns9t7wiyrwtyy9B9tEGuSNGL/q+ojFRXU2pYffN97CF
         LBLpB9ldoL2ns84E/VPE2kSj7yHdptyExs4PnL4VfyqKUiBKLqsijOWkhK5iQolHuHWO
         SX2AdEi4pRYjPjnlIKhKk1IbQT1TVxgfbXMAOtAXjS6dITsOQmlVsA1Ik7RqTQGl7odf
         DJxTcVJRG0uOZOdkJ/Pu83MVR3yFVQU7+JMMsZzky9Eft7OgqB28EluQ6KWKdq5ik1KQ
         1lfQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of brian.welty@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=brian.welty@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWFEokKaUju5pNuJrJe0NC476Kr2GLBufN0EKBadLdSngYKwjoU
	VyZdGunvJqL7y59+C0YKeCUW+9HLAjAHH6U7kY6LmLvBHCowJ6U198LSQsXRn+OuILgAEqV7QbH
	kuIWxwrya2dgvEMgoVIrVGRCEZwtHQGTVpKLSvdIaYS+T2XqgdI1/cB0M3KXYYrZppA==
X-Received: by 2002:a17:902:a503:: with SMTP id s3mr41505566plq.16.1557258652497;
        Tue, 07 May 2019 12:50:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx7tkB8Ww2Purzfqel7LnLS+PlXwEEeNYanbHKzblzxBSfgnq4P9koecNmsyksCeJ05vLTI
X-Received: by 2002:a17:902:a503:: with SMTP id s3mr41505469plq.16.1557258651654;
        Tue, 07 May 2019 12:50:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557258651; cv=none;
        d=google.com; s=arc-20160816;
        b=Ilpdre+IdXCp0M66emjyLyqcEW7gxTNrh4ieSZoLznj8Pw9SegGC2vpHnRtPAoyuSN
         JZ/cDKfI6pauBIPUB1js0+CFsJYoLUdNR1XWZcacLfeRnsoaAXOjTin0ZU4o2y9bNve2
         WE1DeiICnkGZiDVAI/cRDTzm7E1BzBUnEbpLH1cTzP3qAZKybItX8aUhbn0ARBlaSvpO
         BW/fid8nme6CzDQUkO87wJsLyO10dkaoOFH+wfHpMS5xVObSH805EgaYArQ1/nT1QRNp
         QKVtNE0foQpW6J1jv3ypXsXTNhGlbi9u7e4jrhIBzDJjOwgAIFwesjYRboBPnX3ehcE6
         FScQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=zcFsdjI1s+LaqmSPrrez6zaem2wf8uOZRltJ71XJpcs=;
        b=JCvbwg9N8yjVUUDh3dFt+aocZFVypYh0uTtn4p6EyQLDWCCfigoWcIR8Rmhy/KExCX
         7ZF7/fafmiF27Ov2SjCvSzik3dLCjrqU60b1bIp2B7T06GcIxc1vAAoVe14RxEX1hz7N
         3PgO5FMjFZByxqAhLHFxWe4qOqQ//9u99ySVzHfn/Az66WOLgLvj8i4mekeg3SNAE5Q2
         SAr56WQweDTFCApU03LmBc0Y6/+oqpG7XMXu1AtWomcQHB9+FS/Yn5x0883jKAOsTHvu
         1FbggezBHIRzhvN7dEUybHeWFwr1tDf3EQxVa8JGQqBevX04j+onIxV6InHN8cERIdtY
         ccfw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of brian.welty@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=brian.welty@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id j11si19205610plt.112.2019.05.07.12.50.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 12:50:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of brian.welty@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of brian.welty@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=brian.welty@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 07 May 2019 12:50:51 -0700
X-ExtLoop1: 1
Received: from brianwel-mobl1.amr.corp.intel.com (HELO [10.144.155.123]) ([10.144.155.123])
  by orsmga004.jf.intel.com with ESMTP; 07 May 2019 12:50:50 -0700
Subject: Re: [RFC PATCH 0/5] cgroup support for GPU devices
To: Tejun Heo <tj@kernel.org>
Cc: cgroups@vger.kernel.org, Li Zefan <lizefan@huawei.com>,
 Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org,
 Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>,
 dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>,
 Daniel Vetter <daniel@ffwll.ch>, intel-gfx@lists.freedesktop.org,
 =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 RDMA mailing list <linux-rdma@vger.kernel.org>,
 Leon Romanovsky <leon@kernel.org>, kenny.ho@amd.com
References: <20190501140438.9506-1-brian.welty@intel.com>
 <20190506152643.GL374014@devbig004.ftw2.facebook.com>
From: "Welty, Brian" <brian.welty@intel.com>
Message-ID: <cf58b047-d678-ad89-c9b6-96fc6b01c1d7@intel.com>
Date: Tue, 7 May 2019 12:50:50 -0700
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190506152643.GL374014@devbig004.ftw2.facebook.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 5/6/2019 8:26 AM, Tejun Heo wrote:
> Hello,
> 
> On Wed, May 01, 2019 at 10:04:33AM -0400, Brian Welty wrote:
>> The patch series enables device drivers to use cgroups to control the
>> following resources within a GPU (or other accelerator device):
>> *  control allocation of device memory (reuse of memcg)
>> and with future work, we could extend to:
>> *  track and control share of GPU time (reuse of cpu/cpuacct)
>> *  apply mask of allowed execution engines (reuse of cpusets)
>>
>> Instead of introducing a new cgroup subsystem for GPU devices, a new
>> framework is proposed to allow devices to register with existing cgroup
>> controllers, which creates per-device cgroup_subsys_state within the
>> cgroup.  This gives device drivers their own private cgroup controls
>> (such as memory limits or other parameters) to be applied to device
>> resources instead of host system resources.
>> Device drivers (GPU or other) are then able to reuse the existing cgroup
>> controls, instead of inventing similar ones.
> 
> I'm really skeptical about this approach.  When creating resource
> controllers, I think what's the most important and challenging is
> establishing resource model - what resources are and how they can be
> distributed.  This patchset is going the other way around - building
> out core infrastructure for bolierplates at a significant risk of
> mixing up resource models across different types of resources.
> 
> IO controllers already implement per-device controls.  I'd suggest
> following the same interface conventions and implementing a dedicated
> controller for the subsystem.
>
Okay, thanks for feedback.  Preference is clear to see this done as
dedicated cgroup controller.

Part of my proposal was an attempt for devices with "mem like" and "cpu 
like" attributes to be managed by common controller.   We can ignore this
idea for cpu attributes, as those can just go in a GPU controller.

There might still be merit in having a 'device mem' cgroup controller.
The resource model at least is then no longer mixed up with host memory.
RDMA community seemed to have some interest in a common controller at
least for device memory aspects.
Thoughts on this?   I believe could still reuse the 'struct mem_cgroup' data
structure.  There should be some opportunity to reuse charging APIs and
have some nice integration with HMM for charging to device memory, depending
on backing store.

-Brian

