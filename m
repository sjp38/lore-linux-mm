Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3842C43219
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 21:29:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7FC772075E
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 21:29:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=wdc.com header.i=@wdc.com header.b="c8jFQkMn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7FC772075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=wdc.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 371306B0008; Mon, 29 Apr 2019 17:29:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 321B56B000E; Mon, 29 Apr 2019 17:29:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1E9F76B0010; Mon, 29 Apr 2019 17:29:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id DA3A16B0008
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 17:29:45 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 63so826968pga.18
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 14:29:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:ironport-sdr:ironport-sdr:subject
         :to:cc:references:from:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=WVLlGCQbe2LOl9ozrgg8MqoDBz+qdg2hl5qQ7dFn3n0=;
        b=d7Q1aaPLiTecDueDdCrA2uV7ZPfO7C0s6vX9TSQkykRgGILHFPVNw+IdCDrR37vRel
         gxgci8DiDajEP5B0jGYbQusQWAw38SNTIqtl3apKJ4PodLsIY2ehZ8FTkAvWcJjEFzse
         SCSArelLG/5qzAewOWt/z43MLvR6DkttQYd94x9dztg1VyxK+wrnQWPhUHiq0Hoh+d85
         NT2CLTaqbaDG2T/3/r7F3xwhyFEiqmFEGPmNfT25px24s/LbVf8hsYW4OD3uYvFoPX1U
         NPJjpclInR0Qdr9coqtY4E+xv/D5n2P27KMzSnDzqB5y0zHJx8CA17DakvTPVT05Tkxz
         VgEw==
X-Gm-Message-State: APjAAAW68KOP5b+jRjJ1PnCkfYAKr9Z3tIGOc4+sl5PHLFbxwc80Tfii
	fIFhXPapgWS8w8kRYxDCdKpWmg/2dySu0200pT09P1Yc0gyXlX3RtLm9s58+mcJ8MOc8trtj6/i
	5WVLxxGoYc3WQVd2y0L6iCgFUp0qc8txahP/efo2BiR7+zkWEhjjNdHQa7SU3NP1aKQ==
X-Received: by 2002:a65:5886:: with SMTP id d6mr8939541pgu.295.1556573385562;
        Mon, 29 Apr 2019 14:29:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyeAieGbfi4T4zYsQRPN3d2FulQqm/iwgES6OG87wZZZY/QakmVO7hUFfkVgbXoacWt1vmg
X-Received: by 2002:a65:5886:: with SMTP id d6mr8939506pgu.295.1556573384899;
        Mon, 29 Apr 2019 14:29:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556573384; cv=none;
        d=google.com; s=arc-20160816;
        b=apkaLTWxXnnXw7xDtzcc0I7yzTqAvxyMAC5UZj9i9HsPBgwKlbIb2lAfO9wCGLuGbe
         gjRtDiZeLketi2k4jaO6axDoleo0Dl5g2xYnv6Mti51qY1+FS+KPpG/bEXw487Rav/Ct
         wExB3Azh4xlMv0d+dMRgK9LW4GFuunwYeQaEOCjfIs0vRfWZ351jHJKxmPDljx9rQ7/K
         jC2hLEklsI832aEvb78MtGVtGEaU6K6qljzz6fPpAcF2/6W5TXF9QR+pEmvP+zO+g9KN
         gARM4SE3Hz8SQtisgiS2owOFSG9Fy1KZeXMwpULXwOWwSWkdg33U4SCYCyS6AqJwg0LY
         NoIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :ironport-sdr:ironport-sdr:dkim-signature;
        bh=WVLlGCQbe2LOl9ozrgg8MqoDBz+qdg2hl5qQ7dFn3n0=;
        b=fJyIrtgm+95o27VQxAlXf7gLonWzarXcgpxK6nzWZeQams0c6cs+YINhTM3YG4vehI
         DzO4Lr6+N5VCYkMX8pzYkQXgzagW+99/EnWwYYyBgcTU/u4U2kSmSCVZmHnzBlxbHpwq
         841QxeJZqTUBx4PLQZf6icPgBl2K1eLS8aBjLL12hkyUNgN3RgaFoLqqxfLZrHGIZ2TE
         i1jsSQW1nB5F4mVtCmMwFT0MaL/T1iLtadf6QSu/3SPeHvNfkk2hO2b4Pyr/GiUPdFwk
         EnIDhMml3+0WG7iYo9Kdvut2FVabe0EmmEXy71CU/4CEP4yQewYVfy4RKLQMB+vkNIM0
         Jopg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@wdc.com header.s=dkim.wdc.com header.b=c8jFQkMn;
       spf=pass (google.com: domain of prvs=0155011cf=atish.patra@wdc.com designates 216.71.153.144 as permitted sender) smtp.mailfrom="prvs=0155011cf=atish.patra@wdc.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=wdc.com
Received: from esa5.hgst.iphmx.com (esa5.hgst.iphmx.com. [216.71.153.144])
        by mx.google.com with ESMTPS id c10si36014825pla.231.2019.04.29.14.29.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 14:29:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=0155011cf=atish.patra@wdc.com designates 216.71.153.144 as permitted sender) client-ip=216.71.153.144;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@wdc.com header.s=dkim.wdc.com header.b=c8jFQkMn;
       spf=pass (google.com: domain of prvs=0155011cf=atish.patra@wdc.com designates 216.71.153.144 as permitted sender) smtp.mailfrom="prvs=0155011cf=atish.patra@wdc.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=wdc.com
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple;
  d=wdc.com; i=@wdc.com; q=dns/txt; s=dkim.wdc.com;
  t=1556573385; x=1588109385;
  h=subject:to:cc:references:from:message-id:date:
   mime-version:in-reply-to:content-transfer-encoding;
  bh=tylJaZ3hdwgcoleztgKHgV+VyNuRMO/FYfLLBnr0sQI=;
  b=c8jFQkMnQPkyUP4JmmTR/Qq95PV1XIaX2PIAJTZHd7tf9ioXcmn4NPI/
   lxnBVYl6yCJvsUICvCS0Dms8kEHdBJxa6aKUXURekuxUsbfd6HmJbddNM
   aDyDujnnScbYHx7PEhGRJgsZsh5i4F/p7pCRvCMJb3xcSmgs5Q6OipqP3
   wqPqZyrR442YxZA/QSnKMH4WPPlgH/eE2xuj+jS3nrvRZPVjxs6QlAsVW
   5rHMpeUII0b3nqbXJQWs30B5zLplqkrzkn/t3qcdkn991goNSrQP7DVM6
   Z/mh6Z483EsR4pO24ogHsXeWCWfmn29JBEodw1JcsgZ+rNydcPKVTywOB
   w==;
X-IronPort-AV: E=Sophos;i="5.60,411,1549900800"; 
   d="scan'208";a="108317369"
Received: from uls-op-cesaip01.wdc.com (HELO uls-op-cesaep01.wdc.com) ([199.255.45.14])
  by ob1.hgst.iphmx.com with ESMTP; 30 Apr 2019 05:29:45 +0800
IronPort-SDR: NGrl4CSUtNdUHO1KHpve/dnbyoeECTsJMIzjIINx8i8Vr/WNVPQg6fNa3sIiScUs0RLQia3WQ2
 0/K6gBwbwzR9gLmM/GXxNZejwISnpPXku8TWSuM6DxAwOU32tNSNU4ysy9H/ehc8aDfeb/3G20
 jVRnuf1QFAFw0ppmOOcRmh4nigTBWhNQA8blbqLEewyckQB7vILYR1FCrfGMfv6I5G24u6i7P5
 FvlwwUy9SBIyAqnUaVPHEo2StkOrDD9bZz6ngvBI2ii1vk39eJqvgDv3qvhkabLKyrGwmqDbKA
 c4TvpSx7FU0upZKtiS5s6+qp
Received: from uls-op-cesaip02.wdc.com ([10.248.3.37])
  by uls-op-cesaep01.wdc.com with ESMTP; 29 Apr 2019 14:06:06 -0700
IronPort-SDR: 3DPb2PcWrl1lZn4c6cs7QX/GL1L2Mxk3qhbjtbqE5SnoEhVGLGsgYQp0Eb/dU+1MLJeRk4bK3V
 ++ljP17iEXBQXhrYVqDmr4IQi85GLF5yUyR9vBG9J79W2VBZ47HDcTonMJv8Q8Vp3og0a2fWCm
 gHe62TeuS05QO2Sgsw0CubbfQQpT6tj+1qYdgd6WTbZTEdI8miJdVoToYEPkSs41VfHPxeuTuj
 X4dDWhnvFJ9TTmKowheCJ/nsz7dfXizAcBxDYwXIRBfwu6nC4/zlIE8JC/pWnMdBoW4sCTmryI
 Mmk=
Received: from c02v91rdhtd5.sdcorp.global.sandisk.com (HELO [10.111.66.167]) ([10.111.66.167])
  by uls-op-cesaip02.wdc.com with ESMTP; 29 Apr 2019 14:29:44 -0700
Subject: Re: [PATCH v2 1/3] x86: Move DEBUG_TLBFLUSH option.
To: Ingo Molnar <mingo@kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Albert Ou <aou@eecs.berkeley.edu>, Andrew Morton
 <akpm@linux-foundation.org>, Anup Patel <anup@brainfault.org>,
 Borislav Petkov <bp@alien8.de>, Changbin Du <changbin.du@intel.com>,
 Gary Guo <gary@garyguo.net>, "H. Peter Anvin" <hpa@zytor.com>,
 Ingo Molnar <mingo@redhat.com>, Kees Cook <keescook@chromium.org>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "linux-riscv@lists.infradead.org" <linux-riscv@lists.infradead.org>,
 Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
 Palmer Dabbelt <palmer@sifive.com>, Thomas Gleixner <tglx@linutronix.de>,
 Vlastimil Babka <vbabka@suse.cz>,
 "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>,
 Christoph Hellwig <hch@infradead.org>
References: <20190429195759.18330-1-atish.patra@wdc.com>
 <20190429195759.18330-2-atish.patra@wdc.com>
 <20190429200554.GA102486@gmail.com>
From: Atish Patra <atish.patra@wdc.com>
Message-ID: <e80533d1-6d7c-c503-73d7-1a344a49aa37@wdc.com>
Date: Mon, 29 Apr 2019 14:29:43 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190429200554.GA102486@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/29/19 1:06 PM, Ingo Molnar wrote:
> 
> * Atish Patra <atish.patra@wdc.com> wrote:
> 
>> CONFIG_DEBUG_TLBFLUSH was added in 'commit 3df3212f9722 ("x86/tlb: add
>> tlb_flushall_shift knob into debugfs")' to support tlb_flushall_shift
>> knob. The knob was removed in 'commit e9f4e0a9fe27 ("x86/mm: Rip out
>> complicated, out-of-date, buggy TLB flushing")'.  However, the debug
>> option was never removed from Kconfig. It was reused in commit
>> '9824cf9753ec ("mm: vmstats: tlb flush counters")' but the commit text
>> was never updated accordingly.
> 
> Please, when you mention several commits, put them into new lines to make
> it readable, i.e.:
> 
>    3df3212f9722 ("x86/tlb: add tlb_flushall_shift knob into debugfs")
> 
> etc.
> 
Done.

>> Update the Kconfig option description as per its current usage.
>>
>> Take this opprtunity to make this kconfig option a common option as it
>> touches the common vmstat code. Introduce another arch specific config
>> HAVE_ARCH_DEBUG_TLBFLUSH that can be selected to enable this config.
> 
> "opprtunity"?
> 
>> +config HAVE_ARCH_DEBUG_TLBFLUSH
>> +	bool
>> +	depends on DEBUG_KERNEL
>> +
>> +config DEBUG_TLBFLUSH
>> +	bool "Save tlb flush statstics to vmstat"
>> +	depends on HAVE_ARCH_DEBUG_TLBFLUSH
>> +	help
>> +
>> +	Add tlbflush statstics to vmstat. It is really helpful understand tlbflush
>> +	performance and behavior. It should be enabled only for debugging purpose
>> +	by individual architectures explicitly by selecting HAVE_ARCH_DEBUG_TLBFLUSH.
> 
> "statstics"??
> 
> Please put a spell checker into your workflow or read what you are
> writing ...
> 

Apologies for the typos. Fixed them.

Regards,
Atish
> Thanks,
> 
> 	Ingo
> 

