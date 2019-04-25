Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2EC75C10F03
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 12:30:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E162E2081C
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 12:30:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="RG6efg+w"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E162E2081C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 829346B0003; Thu, 25 Apr 2019 08:30:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7B23B6B0010; Thu, 25 Apr 2019 08:30:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A3B96B0269; Thu, 25 Apr 2019 08:30:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0DE056B0003
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 08:30:54 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id z29so11580601edb.4
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 05:30:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=67R0k05803KguupIDta7Ra/6RBriLS9l4FIpl33TABc=;
        b=GVKRvdqBkv5nxRqteY2AjQdyz4OqQcoHcEK9Icah0/IvJl4aVqI2nYoCb8FWif4WWE
         s1tc/KblLBq04dU4CEeT4FxrTOppksRGNBW69mreEqSmcqdg/Xus+YVzoC7i4fnJtvMA
         HCHugmpS82V+RSHVUEc3KeL4mu1hCgk3PaTxWKRORvYoWsmknbShCnKsU+WQhr3J/Uzy
         IJONWvq0h+4MjsYmO9apHQdjvwzgAS8KW8v3ZhzcUigeIFnjo1VsFtIwZ327O3QtUtgB
         hjFxaK+4SmXY+vuU3QuJywFOhQ3DCOsmZd1VfhfkbT3bn4pGLiXlODf+6g/vWUIGKi3d
         UhFQ==
X-Gm-Message-State: APjAAAX5HqE2UlpQwSnoHT6MZLKg3KGLKE1RLw3sJR6YtVJaNjvagz/L
	pr4FPOtxd6JUN9IA7ILTg3o9V4sM3fbCo9c5/U2epQC6UpwaJG6vedUyrTqXFCcfG1jDjONd0in
	CO1uviJJAUUDRPVzeCuoTOx9kiOONu7BbrsbT2Htu7BaZZMKxgZEkpaOFp/A0ZIjk4A==
X-Received: by 2002:a17:906:7496:: with SMTP id e22mr19641648ejl.45.1556195453590;
        Thu, 25 Apr 2019 05:30:53 -0700 (PDT)
X-Received: by 2002:a17:906:7496:: with SMTP id e22mr19641584ejl.45.1556195452408;
        Thu, 25 Apr 2019 05:30:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556195452; cv=none;
        d=google.com; s=arc-20160816;
        b=1AONTame9tzKWyXKfwoATpwMkJ7xmkdDp9NFgnRIN1HK1/Q0ysAes8WaFIhmwhwF+R
         EVHVi8aH9pCr3y5QiZSt9p7w3tHxHDuUGoymCBp0z6MOabgy1do1C1VQCVsC3WmjP/1k
         inpLbqH8ilitMwLrxzI1BhNeev6TTVYfvqhrxw/lG2jRcIJUW2W1xZrputaKU+zr5L2W
         z/XAihtdWEIa3Id1fxcl7yWAXVs73iTv1sYO/GmEWO/F7Pm17E+N6pnCN3F0julO2XrA
         ZKXhpZMPi1Kss4wGlGJGmfbbIsQ4Il2xPrGrg0LYulKNWJ++POaDYXxwgJVZyOOmc7sJ
         gr5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=67R0k05803KguupIDta7Ra/6RBriLS9l4FIpl33TABc=;
        b=CF8mFWnusgXBzdrPjZi4hBfnoZm0UKVayp/Wti+iMD/ARV/t0UN7HxliS59vqFzaXq
         NhbcNAVgSYZyUVQjigy/kt38TmPOrqRN/Wr4TrwJp8jedDfR17/89h9uPVHqPGJD76L4
         pBLTBt1t/Ut0EQLv3B3ZiUciwrzHR9eAEgv2RkQV7FEiP/Ng/AJgdHFudYhDH5SvnW+2
         qT5ZlC6ARj02m2L+KKOEnnT0AZSoRMlWFyEB/1HcSBMecC09lbfxhDP2mt84ag/0glc2
         vO4c5MoN3V8f20m4ew3024xRdXFB58dNaBhbFmO8UFj4YBkWN4PahG6fuXGeYApVZrM2
         waoQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=RG6efg+w;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i6sor3648629edd.12.2019.04.25.05.30.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Apr 2019 05:30:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=RG6efg+w;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=67R0k05803KguupIDta7Ra/6RBriLS9l4FIpl33TABc=;
        b=RG6efg+wINT5PtOxJThnJ7/GhcdJnGb39Z4ZiVojLVulIllPY6WegbUX1iE+KXv7ix
         hw7G3Q35WeIJFBq6h+DTKCSoq6Caf3U4HMLnir6Y2Fpepl+Yg62BlPdyDc+AfIeAdC6G
         T5q6JA5VpPnsEZbc1Y3THNGipkJEYTCX5YvtGmIytNOobkbu5pJOI8FPfiRA+c2salf8
         qIjHlzsMeZbUV6ujc/e+TQwLohjwZU6jQscEF+qeF4JPVtvV/MenGzVv1/zUdUKvFb4o
         XQFGsXg+neKHnqNqXD/JaZm33914fdkJ2/qSt+EWsmhg8bcDYJt8SzWMQ5M1Jr4er9q8
         DqAg==
X-Google-Smtp-Source: APXvYqwiC0RYDcdWaH93fKry+qe407e7uBBkYjvENxoUhOgx5lCTLYYQiqnziqtuQkVFJZxzsIpjW4zsSKchIjg+TPc=
X-Received: by 2002:a50:b68a:: with SMTP id d10mr1779006ede.79.1556195451949;
 Thu, 25 Apr 2019 05:30:51 -0700 (PDT)
MIME-Version: 1.0
References: <20190421014429.31206-1-pasha.tatashin@soleen.com>
 <20190421014429.31206-3-pasha.tatashin@soleen.com> <4ad3c587-6ab8-1307-5a13-a3e73cf569a5@redhat.com>
 <CAPcyv4h3+hU=MmB=RCc5GZmjLW_ALoVg_C4Z7aw8NQ=1LzPKaw@mail.gmail.com>
 <CA+CK2bDB5o4+NMc7==_ipVAZoEo7fdrkjZ4etU0LUCqxnmN-Rg@mail.gmail.com> <180d6250-8a6a-0b5d-642a-ec6648cb45b1@redhat.com>
In-Reply-To: <180d6250-8a6a-0b5d-642a-ec6648cb45b1@redhat.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Thu, 25 Apr 2019 08:30:40 -0400
Message-ID: <CA+CK2bBt0vHr9D+BuvM=GmjCMESu5iBiUTdvid_TaoE6j2daQg@mail.gmail.com>
Subject: Re: [v2 2/2] device-dax: "Hotremove" persistent memory that is used
 like normal RAM
To: David Hildenbrand <david@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>, James Morris <jmorris@namei.org>, 
	Sasha Levin <sashal@kernel.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Keith Busch <keith.busch@intel.com>, Vishal L Verma <vishal.l.verma@intel.com>, 
	Dave Jiang <dave.jiang@intel.com>, Ross Zwisler <zwisler@kernel.org>, 
	Tom Lendacky <thomas.lendacky@amd.com>, "Huang, Ying" <ying.huang@intel.com>, 
	Fengguang Wu <fengguang.wu@intel.com>, Borislav Petkov <bp@suse.de>, Bjorn Helgaas <bhelgaas@google.com>, 
	Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Takashi Iwai <tiwai@suse.de>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

>
> Yes, also I think you can let go of the device_lock in
> check_memblocks_offline_cb, lock_device_hotplug() should take care of
> this (see Documentation/core-api/memory-hotplug.rst - "locking internals")
>
Hi David,

Thank you for your comments. I went through memory-hotplug.rst, and I
still think that device_lock() is needed here. In this particular case
it can be replaced with something like READ_ONCE(), but for simplicity
it is better to have device_lock()/device_unlock() as this is not a
performance critical code.

I do not see any lock ordering issues with this code, as we are
holding lock_device_hotplug() first that prevents userland from
adding/removing memory during this check.

https://soleen.com/source/xref/linux/arch/powerpc/platforms/powernv/memtrace.c?r=98fa15f3#248

Here we have a similar code:
lock_device_hotplug();
   online_mem_block();
    device_online()
     device_lock(dev);

Pasha

