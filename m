Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E01CC282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 08:12:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 317A9222BB
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 08:12:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 317A9222BB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=inria.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B8BF88E0002; Wed, 13 Feb 2019 03:12:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B3AE58E0001; Wed, 13 Feb 2019 03:12:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A02878E0002; Wed, 13 Feb 2019 03:12:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 48E738E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 03:12:17 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id e2so579697wrv.16
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 00:12:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:cc
         :references:from:openpgp:autocrypt:to:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=lQCsR+EKXtrhsKH6SU9rKikBI9dPobu2olo4WhByBqk=;
        b=cF4x6+H/0A+Omu/eHOfQ8vcQ4vrdklheIO6oFDKmtBLHqGKSGAMxgsKQXpjIp+LkWx
         dGMCPxd+qs493jbkEQpiO+6iO9uLXWMpPY/WngR6thHIsb7/mzQPxsf0hJ+FTMEreoI/
         Wx5jOlGJKcxeUkvWOT85C73EJpo2FoOe9pvzJ1qEffVF7jUoNYvJQM1/s9T102KFbG6m
         53jT05mRGW89RILXV0a7MURi/FbnXLp6QVsvS8ube2004JODumPbGZyOIHcmfzhjIWHq
         5G9Z3wNt+D3mJvZvw+6w0lLPZrQP+kscCBGr1DlkDKJ/0NbTiaZ5JJ8sJxVtc/tFTmBl
         eNiw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.83 as permitted sender) smtp.mailfrom=Brice.Goglin@inria.fr
X-Gm-Message-State: AHQUAuauoKVZjbcrQEh8W1NiLtiAqsdfzcIVrICs9tOqenKsw18X6/74
	Af3/uDyEqXHxQJBOcHi3ereaLzNGac7jm0LhjH9tUVfmge5mOrE0cC7VcFQUt91hxYvWirvsTxU
	VW2+2fpIxy3n+AOieR54Tl3aTDfb65WNvr9X/2i5yxbUjGliq5pJWMVOtmtILXI+qnQ==
X-Received: by 2002:a5d:6846:: with SMTP id o6mr5874561wrw.160.1550045536784;
        Wed, 13 Feb 2019 00:12:16 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZFOh004E86jxCmwhPKoECehW1phGarfoA1PZm2BnZHZ4vjOW9qn1MNsRp1WrMWan9CxXAj
X-Received: by 2002:a5d:6846:: with SMTP id o6mr5874506wrw.160.1550045535920;
        Wed, 13 Feb 2019 00:12:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550045535; cv=none;
        d=google.com; s=arc-20160816;
        b=W66NlfQwovRPIl6VDnCFrfmNl4Df9UEWpSAzNhozK1sG0HuyBu/GTrVmMzCEb8o1nc
         IbQm9j09Y7EpPYdvh2W8LU1uS84OOpj7PsvkRRYFzm5MRD8OgreJ+aaSTlus72a1y4VZ
         Kwp17GV9RFMYPmnP+sF1ZkOc4bGAqcuVyqgYeSixg0myw1veExI5UEeYmt/XXggqyh6M
         uV4pXyTWQsnQyq3INmArdtwaAY7IJ1wi9Wdu6EyBbhAzEe8lzAWdTIzmKhbbc5FGSpy1
         kRkdO2Dolvs7PQwXi+CGnMx8S9lxOFRyR37T8m6BSAo3Bgyrf5ar4D/u0GShDghIFAYF
         rlmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:to:autocrypt:openpgp:from:references:cc
         :subject;
        bh=lQCsR+EKXtrhsKH6SU9rKikBI9dPobu2olo4WhByBqk=;
        b=Lh7bgnAYo6sY1gWlJa3KQOhYw2QwHtre6Kmu/XY7UzBcghh+AFevEuxShlYcKNE0+p
         IjtumTkpVmoeSbDrKCae++RFhHUvPCDuOdFZmlN8n1E+s0LfKPcbCEC+hEBi4lb/PNXj
         4LPj3acNB+m4BUvviquFnTqPzzxPidNyZvFXGDIfgnYe8xC3kKj2t4u6J5RBlLZ7CrKv
         p+MMZ0ALIAgKl/TmudeJAFo17NgcJFfxBGgsnUb2EwsH5mpAKQW7WmLRiCTHUJ/J9l+h
         y+q+ZtNUCL00YFpTKAHSEp1UJNBMXaZpgBAqlSMK32pL1OeHVxfBlfYF3n7iW9KWxA5R
         bGRA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.83 as permitted sender) smtp.mailfrom=Brice.Goglin@inria.fr
Received: from mail2-relais-roc.national.inria.fr (mail2-relais-roc.national.inria.fr. [192.134.164.83])
        by mx.google.com with ESMTPS id 203si1562096wme.31.2019.02.13.00.12.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 00:12:15 -0800 (PST)
Received-SPF: pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.83 as permitted sender) client-ip=192.134.164.83;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.83 as permitted sender) smtp.mailfrom=Brice.Goglin@inria.fr
X-IronPort-AV: E=Sophos;i="5.58,365,1544482800"; 
   d="scan'208";a="369202876"
Received: from unknown (HELO [193.50.110.185]) ([193.50.110.185])
  by mail2-relais-roc.national.inria.fr with ESMTP/TLS/AES128-SHA; 13 Feb 2019 09:12:15 +0100
Subject: Re: [PATCH 5/5] dax: "Hotplug" persistent memory for use like normal
 RAM
Cc: Dan Williams <dan.j.williams@intel.com>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 Tom Lendacky <thomas.lendacky@amd.com>, Michal Hocko <mhocko@suse.com>,
 linux-nvdimm <linux-nvdimm@lists.01.org>, Takashi Iwai <tiwai@suse.de>,
 Ross Zwisler <zwisler@kernel.org>, Linux MM <linux-mm@kvack.org>,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Fengguang Wu <fengguang.wu@intel.com>,
 Yaowei Bai <baiyaowei@cmss.chinamobile.com>,
 "Huang, Ying" <ying.huang@intel.com>, Bjorn Helgaas <bhelgaas@google.com>,
 Andrew Morton <akpm@linux-foundation.org>, Borislav Petkov <bp@suse.de>
References: <20190124231441.37A4A305@viggo.jf.intel.com>
 <20190124231448.E102D18E@viggo.jf.intel.com>
 <c4c6aca8-6ee8-be10-65ae-4cbe0aa03bfb@inria.fr>
 <26ac36f4-7391-5321-217b-50d67e2119d7@intel.com>
 <453f13cd-a7fe-33eb-9a27-8490825ca29c@inria.fr>
 <CAPcyv4jF7ZyKaFDw7nb04UvWkVWGJdLGkZDQ1g=X7i+kdu7JRg@mail.gmail.com>
From: Brice Goglin <Brice.Goglin@inria.fr>
Openpgp: preference=signencrypt
Autocrypt: addr=Brice.Goglin@inria.fr; prefer-encrypt=mutual; keydata=
 mQINBFNg91oBEADMfOyfz9iilNPe1Yy3pheXLf5O/Vpr+gFJoXcjA80bMeSWBf4on8Mt5Fg/
 jpVuNBhii0Zyq4Lip1I2ve+WQjfL3ixYQqvNRLgfw/FL0gNHSOe9dVFo0ol0lT+vu3AXOVmh
 AM4IrsOp2Tmt+w89Oyvu+xwHW54CJX3kXp4c7COz79A6OhbMEPQUreerTavSvYpH5pLY55WX
 qOSdjmlXD45yobQbMg9rFBy1BECrj4DJSpym/zJMFVnyC5yAq2RdPFRyvYfS0c491adD/iw9
 eFZY1XWj+WqLSW8zEejdl78npWOucfin7eAKvov5Bqa1MLGS/2ojVMHXJN0qpStpKcueV5Px
 igX8i4O4pPT10xCXZ7R6KIGUe1FE0N7MLErLvBF6AjMyiFHix9rBG0pWADgCQUUFjc8YBKng
 nwIKl39uSpk5W5rXbZ9nF3Gp/uigTBNVvaLO4PIDw9J3svHQwCB31COsUWS1QhoLMIQPdUkk
 GarScanm8i37Ut9G+nB4nLeDRYpPIVBFXFD/DROIEfLqOXNbGwOjDd5RWuzA0TNzJSeOkH/0
 qYr3gywjiE81zALO3UeDj8TaPAv3Dmu7SoI86Bl7qm6UOnSL7KQxZWuMTlU3BF3d+0Ly0qxv
 k1XRPrL58IyoHIgAVom0uUnLkRKHczdhGDpNzsQDJaO71EPp8QARAQABtCRCcmljZSBHb2ds
 aW4gPEJyaWNlLkdvZ2xpbkBpbnJpYS5mcj6JAjgEEwECACIFAlNg+aMCGwMGCwkIBwMCBhUI
 AgkKCwQWAgMBAh4BAheAAAoJEESRkPMjWr076RoQAJhJ1q5+wlHIf+YvM0N1V1hQyf+aL35+
 BPqxlyw4H65eMWIN/63yWhcxrLwNCdgY1WDWGoiW8KVCCHwJAmrXukFvXjsvShLQJavWRgKH
 eea12T9XtLc6qY/DEi2/rZvjOCKsMjnc1CYW71jbofaQP6lJsmC+RPWrnL/kjZyVrVrg7/Jo
 GemLmi/Ny7nLAOt6uL0MC/Mwld14Yud57Qz6VTDGSOvpNacbkJtcCwL3KZDBfSDnZtSbeclY
 srXoMnFXEJJjKJ6kcJrZDYPrNPkgFpSId/WKJ5pZBoRsKH/w2OdxwtXKCYHksMCiI4+4fVFD
 WlmVNYzW8ZKXjAstLh+xGABkLVXs+0WjvC67iTZBXTmbYJ5eodv8U0dCIR/dxjK9wxVKbIr2
 D+UVbGlfqUuh1zzL68YsOg3L0Xc6TQglKVl6RxX87fCU8ycIs9pMbXeRDoJohflo8NUDpljm
 zqGlZxBjvb40p37ReJ+VfjWqAvVh+6JLaMpeva/2K1Nvr9O/DOkSRNetrd86PslrIwz8yP4l
 FaeG0dUwdRdnToNz6E8lbTVOwximW+nwEqOZUs1pQNKDejruN7Xnorr7wVBfp6zZmFCcmlw9
 8pSMV3p85wg6nqJnBkQNTzlljycBvZLVvqc6hPOSXpXf5tjkuUVWgtbCc8TDEQFx8Phkgda6
 K1LNuQINBFNg91oBEADp3vwjw8tQBnNfYJNJMs6AXC8PXB5uApT1pJ0fioaXvifPNL6gzsGt
 AF53aLeqB7UXuByHr8Bmsz7BvwA06XfXXdyLQP+8Oz3ZnUpw5inDIzLpRbUuAjI+IjUtguIK
 AkU1rZNdCXMOqEwCaomRitwaiX9H7yiDTKCUaqx8yAuAQWactWDdyFii2FA7IwVlD/GBqMWV
 weZsMfeWgPumKB3jyElm1RpkzULrtKbu7MToMH2fmWqBtTkRptABkY7VEd8qENKJBZKJGisk
 Fk6ylp8VzZdwbAtEDDTGK00Vg4PZGiIGbQo8mBqbc63DY+MdyUEksTTu2gTcqZMm/unQUJA8
 xB4JrTAyljo/peIt6lsQa4+/eVolfKL1t1C3DY8f4wMoqnZORagnWA2oHsLsYKvcnqzA0QtY
 IIb1S1YatV+MNMFf3HuN7xr/jWlfdt59quXiOHU3qxIzXJo/OfC3mwNW4zQWJkG233UOf6YE
 rmrSaTIBTIWF8CxGY9iXPaJGNYSUa6R/VJS09EWeZgRz9Gk3h5AyDrdo5RFN9HNwOj41o0cj
 eLDF69092Lg5p5isuOqsrlPi5imHKcDtrXS7LacUI6H0c8onWoH9LuW99WznEtFgPJg++TAv
 f9M2x57Gzl+/nYTB5/Kpl1qdPPC91zUipiKbnF5f8bQpol0WC+ovmQARAQABiQIfBBgBAgAJ
 BQJTYPdaAhsMAAoJEESRkPMjWr074+0P/iEcN27dx3oBTzoeGEBhZUVQRZ7w4A61H/vW8oO8
 IPkZv9kFr5pCfIonmHEbBlg6yfjeHXwF5SF2ywWRKkRsFHpaFWywxqk9HWXu8cGR1pFsrwC3
 EdossuVbEFNmhjHvcAo11nJ7JFzPTEnlPjE6OY9tEDwl+kp1WvyXqNk9bosaX8ivikhmhB47
 7BA3Kv8uUE7UL6p7CBdqumaOFISi1we5PYE4P/6YcyhQ9Z2wH6ad2PpwAFNBwxSu+xCrVmaD
 skAwknf6UVPN3bt67sFAaVgotepx6SPhBuH4OSOxVHMDDLMu7W7pJjnSKzMcAyXmdjON05Sz
 SaILwfceByvHAnvcFh2pXK9U4E/SyWZDJEcGRRt79akzZxls52stJK/2Tsr0vKtZVAwogiaK
 uSp+m6BRQcVVhTo/Kq3E0tSnsTHFeIO6QFHKJCJv4FRE3Dmtz15lueihUBowsq9Hk+u3UiLo
 SmrMAZ6KgA4SQxB2p8/M53kNJl92HHc9nc//aCQDi1R71NyhtSx+6PyivoBkuaKYs+S4pHmt
 sFE+5+pkUNROtm4ExLen4N4OL6Kq85mWGf2f6hd+OWtn8we1mADjDtdnDHuv+3E3cacFJPP/
 wFV94ZhqvW4QcyBWcRNFA5roa7vcnu/MsCcBoheR0UdYsOnJoEpSZswvC/BGqJTkA2sf
To: Dave Hansen <dave.hansen@intel.com>
Message-ID: <a3bfe739-228e-26fe-90f7-4a4f8ceb3a9a@inria.fr>
Date: Wed, 13 Feb 2019 09:12:14 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <CAPcyv4jF7ZyKaFDw7nb04UvWkVWGJdLGkZDQ1g=X7i+kdu7JRg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Le 13/02/2019 à 01:30, Dan Williams a écrit :
> On Tue, Feb 12, 2019 at 11:59 AM Brice Goglin <Brice.Goglin@inria.fr> wrote:
>> # ndctl disable-region all
>> # ndctl zero-labels all
>> # ndctl enable-region region0
>> # ndctl create-namespace -r region0 -t pmem -m devdax
>> {
>>   "dev":"namespace0.0",
>>   "mode":"devdax",
>>   "map":"dev",
>>   "size":"1488.37 GiB (1598.13 GB)",
>>   "uuid":"ad0096d7-3fe7-4402-b529-ad64ed0bf789",
>>   "daxregion":{
>>     "id":0,
>>     "size":"1488.37 GiB (1598.13 GB)",
>>     "align":2097152,
>>     "devices":[
>>       {
>>         "chardev":"dax0.0",
>>         "size":"1488.37 GiB (1598.13 GB)"
>>       }
>>     ]
>>   },
>>   "align":2097152
>> }
>> # ndctl enable-namespace namespace0.0
>> # echo -n dax0.0 > /sys/bus/dax/drivers/device_dax/remove_id
>> <hang>
>>
>> I tried with and without dax_pmem_compat loaded, but it doesn't help.
> I think this is due to:
>
>   a9f1ffdb6a20 device-dax: Auto-bind device after successful new_id
>
> I missed that this path is also called in the remove_id path. Thanks
> for the bug report! I'll get this fixed up.


Now that remove_id is fixed, things fails later in Dave's procedure:

# echo -n dax0.0 > /sys/bus/dax/drivers/device_dax/remove_id
# echo -n dax0.0 > /sys/bus/dax/drivers/device_dax/unbind
# echo -n dax0.0 > /sys/bus/dax/drivers/kmem/new_id
# echo -n dax0.0 > /sys/bus/dax/drivers/kmem/bind
-bash: echo: write error: No such device

(And nothing seems to have changed in /sys/devices/system/memory/*/state)

Brice


