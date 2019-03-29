Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8162C43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 08:45:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 77DDA2082F
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 08:45:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 77DDA2082F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2FB936B000D; Fri, 29 Mar 2019 04:45:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A8F16B000E; Fri, 29 Mar 2019 04:45:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 19A076B0010; Fri, 29 Mar 2019 04:45:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B94006B000D
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 04:45:49 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id z98so753371ede.3
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 01:45:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=nDQ5WbNOR0W3AwMYulKYCDyCajVsgohaxGV63Fl2mcE=;
        b=cpVzPW0VL3R5aBdhyRcygcxUx7I8CpQrqXcf2T47Zd+7TlQL4vP+F3utHugwRklif4
         ltilOLgjMbJQO2s6SspWWZxwcLlLU0fx3fWP7nhUET3r30B9gNeNe4aKqS24R8bVmvxN
         zXwsbrP4WLTvoF4SjF/A+YD08E+nWOoc/g5yOp6IkeBqqHjt4l6lGtK7jYEYw0hoA0sg
         cGYCENVAjPDKVajdVkqZ7pbbnYegeQ486mM2PWxpgpL79XifRuo63vGuY2TQZM3ycyVn
         oRqYf+oHOQCxlNkRQrB3mYmitMg8zRQymT6YrXjyLQ18CaCgEXcM0TMF2em+ISUvbe3T
         5kIA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAX85KxCUa6G13/BsviP9Tg5j4j0RlDbBnvwMRJaKIXI74m7ulrh
	V7qsvhQu5WmaHucXDW7qefgiIZiZ0Hgd0W9vr6/eo9uWA8h1Cpm0rQId5hvLsCewtgMuc+ip3Zr
	qfxiXwkrVzfqo1lTCJkVfrBLKh5IApJKlQ2z9bZlfdNZDlT4AxyQgzV2GBe9D2RI=
X-Received: by 2002:a50:eb0c:: with SMTP id y12mr29701832edp.237.1553849149312;
        Fri, 29 Mar 2019 01:45:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwwIDClXZ7bsgRPJTdxpA8VGfYKFpL5gKsfJ0wxtu7SIPlbIQ+YUPO/dPkNN2flY2CKeKiY
X-Received: by 2002:a50:eb0c:: with SMTP id y12mr29701794edp.237.1553849148456;
        Fri, 29 Mar 2019 01:45:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553849148; cv=none;
        d=google.com; s=arc-20160816;
        b=fyK598U3s4TSo58wsDnr7SgZMDiEhW4svYoeYyqamDS+IsQi456yVUqi2bQMqyehqe
         YMLW4aVUvOVaHLeW/GvROhY/O2zryY/Z6k73gSeGFCqxn27EaezzPE9g+6sshY1y1NSK
         fQdH7MqWLRscG7BscArOnyT4Oiuic0CG2VV34ZVflZtsWpiIgJG98/RKbZh526kMY5qO
         DKhpAZgPTc7BBYfuHesXHYd4/262J6D/ITNnkbnXphreOTug1d+gjMjXIm8WCfk0mn6V
         dCw+PR6Hr/S8Yg+v++UrxTfs7res6PRv1jGxN+vpNOxiK5dhL7f5K5a+7DwVlrMDFNq8
         XRdg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=nDQ5WbNOR0W3AwMYulKYCDyCajVsgohaxGV63Fl2mcE=;
        b=ZgTfVN0aj1YKltwoRowABHlnOxt/eGLJ/A4SNFiA0AjjQvct8PJbbpa3QzhlmRTinC
         A5CV9e8wI8m2M2SzY3jhl2W8n3gALHdRsSYOtKNf5O77DAi+BawJgY9hmqwcB1nXRjsw
         K0+Y/zNfNtQkNgBfTFKO33TMtNwzimkRberbbI9X6q/aNyIZmOhZi78wou9LWbPIIfsB
         PhbkIc9r66ilRrRT+ZA+zFjsSFv+/iu2PZW1W5/5s2UIbU+7AtkNKjVxRvbeSW7UPe5K
         i0rUX7YGTXXKR4o8yzu0FKObbJFrXH1GWbsxULeCt1tzSIwErriXrXXFbhFltBDylL30
         Zjwg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [2620:113:80c0:5::2222])
        by mx.google.com with ESMTP id s4si678345edx.79.2019.03.29.01.45.48
        for <linux-mm@kvack.org>;
        Fri, 29 Mar 2019 01:45:48 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) client-ip=2620:113:80c0:5::2222;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id A0F54473E; Fri, 29 Mar 2019 09:45:47 +0100 (CET)
Date: Fri, 29 Mar 2019 09:45:47 +0100
From: Oscar Salvador <osalvador@suse.de>
To: David Hildenbrand <david@redhat.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com,
	Jonathan.Cameron@huawei.com, anshuman.khandual@arm.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 0/4] mm,memory_hotplug: allocate memmap from hotadded
 memory
Message-ID: <20190329084547.5k37xjwvkgffwajo@d104.suse.de>
References: <20190328134320.13232-1-osalvador@suse.de>
 <cc68ec6d-3ad2-a998-73dc-cb90f3563899@redhat.com>
 <efb08377-ca5d-4110-d7ae-04a0d61ac294@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <efb08377-ca5d-4110-d7ae-04a0d61ac294@redhat.com>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 28, 2019 at 04:31:44PM +0100, David Hildenbrand wrote:
> Correct me if I am wrong. I think I was confused - vmemmap data is still
> allocated *per memory block*, not for the whole added memory, correct?

No, vmemap data is allocated per memory-resource added.
In case a DIMM, would be a DIMM, in case a qemu memory-device, would be that
memory-device.
That is counting that ACPI does not split the DIMM/memory-device in several memory
resources.
If that happens, then acpi_memory_enable_device() calls __add_memory for every
memory-resource, which means that the vmemmap data will be allocated per
memory-resource.
I did not see this happening though, and I am not sure under which circumstances
can happen (I have to study the ACPI code a bit more).

The problem with allocating vmemmap data per memblock, is the fragmentation.
Let us say you do the following:

* memblock granularity 128M

(qemu) object_add memory-backend-ram,id=ram0,size=256M
(qemu) device_add pc-dimm,id=dimm0,memdev=ram0,node=1

This will create two memblocks (2 sections), and if we allocate the vmemmap
data for each corresponding section within it section(memblock), you only get
126M contiguous memory.

So, the taken approach is to allocate the vmemmap data corresponging to the
whole DIMM/memory-device/memory-resource from the beginning of its memory.

In the example from above, the vmemmap data for both sections is allocated from
the beginning of the first section:

memmap array takes 2MB per section, so 512 pfns.
If we add 2 sections:

[  pfn#0  ]  \
[  ...    ]  |  vmemmap used for memmap array
[pfn#1023 ]  /  

[pfn#1024 ]  \
[  ...    ]  |  used as normal memory
[pfn#65536]  /

So, out of 256M, we get 252M to use as a real memory, as 4M will be used for
building the memmap array.

Actually, it can happen that depending on how big a DIMM/memory-device is,
the first/s memblock is fully used for the memmap array (of course, this
can only be seen when adding a huge DIMM/memory-device).

-- 
Oscar Salvador
SUSE L3

