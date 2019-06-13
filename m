Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 852F2C31E4A
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 07:53:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 40ADF2084D
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 07:53:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazon.com header.i=@amazon.com header.b="e8++ugwV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 40ADF2084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=amazon.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AB2296B000D; Thu, 13 Jun 2019 03:53:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A63D46B000E; Thu, 13 Jun 2019 03:53:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8DDC56B0010; Thu, 13 Jun 2019 03:53:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 64E9A6B000D
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 03:53:01 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id b7so15959214qkk.3
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 00:53:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language:precedence;
        bh=N/M6zv80rhKW/q7L4/nxWlBtMDnUMiMdW8i5qd39XQo=;
        b=UNCh0o8c6N9/FFzywZ1M9B1XK63ur3OBFCrS4TJ9evFQfopA/XywP2pdhGUbIivaYa
         RqKrjsk1kZJRRi4rbhjuPeYwcngawAv9qn6S1R2PeoZG884Lvi831syABAVK1/3KXJ63
         gQdAvimINJX8+ve5NicCp1eyTN4B043jiRb5cr+QZjsMOnozhStFoERg4NGXHRcPqqKM
         1f0D9EXXGgXrChkZwhaxoiDsReebiy8KcIozkR62ySyKASkzGB2CyFJeU/4uHygF0hMw
         F6rmx2PrPtphCKW2YX/P+Fp0yhlVJP1FxWD/on/KFJxLaqYaV4bWSVxbrt5vpi7+m/Wj
         wWfA==
X-Gm-Message-State: APjAAAU0dijOnMEGpCF35NCkXgVO6AspAwhlwNqXL85QnXrFEkdBc6F1
	pk7KvKp7PqixW7VGMfKv87OvEXuChda22cFBMt5pgrM6U2jXG0bIJq+PtPqr3y0iQUWrWEeYl+N
	SKHS8+iYc+M+IisznjD0fTUfKU0qHjJnl9a+8rbfwOirvNg3efiGg6mP7cjVPilg3vA==
X-Received: by 2002:aed:24d9:: with SMTP id u25mr75808476qtc.111.1560412381074;
        Thu, 13 Jun 2019 00:53:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw5rb+KiOepxAFCKoDTPgFQayTlf6NXGnBJX6DlRVkmfWlW+3yk2hUAJzciTTIkX2iwaVB+
X-Received: by 2002:aed:24d9:: with SMTP id u25mr75808441qtc.111.1560412380323;
        Thu, 13 Jun 2019 00:53:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560412380; cv=none;
        d=google.com; s=arc-20160816;
        b=kOcT/EI4uTc6UonLHuSwepdzeindWv/zDpZroU/Vuj5kndY6zWRmneflDPSdMLeaQb
         lr6pEhHO66uq9P8dtJAdmWHLG8SrjMKZmu7sc9lBynuITrhl07TCuyp+XHl7Se6bbzHD
         UHHclO0wxN/zqlqG+3iD52C1bWA8cWr48nUXmSZ/fXLdDUrdZ2IOHK6D2woDnZMUh3wC
         HjA0skJeaMlBIHG0LirbZYbELU3hydp2gGcCTGD03aTfhXDSMjMLReKjemX2FGFbTHuC
         a8xDr1lwu5xDFwy1g4HV/eD0izWin+oRoiKmlFaDhyZyw9e1I/0vJgfXHGcEPjDYQqvr
         t8/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=precedence:content-language:content-transfer-encoding:in-reply-to
         :mime-version:user-agent:date:message-id:from:references:cc:to
         :subject:dkim-signature;
        bh=N/M6zv80rhKW/q7L4/nxWlBtMDnUMiMdW8i5qd39XQo=;
        b=oYGl4C8hwc/usYJbWacHBp6aslVg3LEpAGxGo8eeWBQ+ZBj3ayHPcK3FYxNdb5h1wp
         dfP6FHgbvQ4U8PogExFRrZLDV8w0aBOWvyT8Z7W7JWuEipR28TegtAqn5f2iC4v7n9ej
         Dv/mx0qYubPY/5neHvOnDuZKToOnOCsVZnwZL2eDlm6RkY6p9YphhSRxdOWmL8IPdT0T
         ENTO6+Lp3UqH49zb6FZgAviCF7eslepyarmRjXhlpoh5oQCsCq4EViZ3gRCjd5fPeNJC
         G3GTrJv+iVPdeMr0rcf8KZbC9NVsecWR6XQvSIY+0y0vKgmKsE6XXJ4cA4lCHHiBlDhn
         Itvg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazon.com header.s=amazon201209 header.b=e8++ugwV;
       spf=pass (google.com: domain of prvs=060300392=graf@amazon.com designates 72.21.198.25 as permitted sender) smtp.mailfrom="prvs=060300392=graf@amazon.com";
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amazon.com
Received: from smtp-fw-4101.amazon.com (smtp-fw-4101.amazon.com. [72.21.198.25])
        by mx.google.com with ESMTPS id i63si1260652qtb.366.2019.06.13.00.53.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 00:53:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=060300392=graf@amazon.com designates 72.21.198.25 as permitted sender) client-ip=72.21.198.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazon.com header.s=amazon201209 header.b=e8++ugwV;
       spf=pass (google.com: domain of prvs=060300392=graf@amazon.com designates 72.21.198.25 as permitted sender) smtp.mailfrom="prvs=060300392=graf@amazon.com";
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amazon.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=amazon.com; i=@amazon.com; q=dns/txt; s=amazon201209;
  t=1560412380; x=1591948380;
  h=subject:to:cc:references:from:message-id:date:
   mime-version:in-reply-to:content-transfer-encoding;
  bh=N/M6zv80rhKW/q7L4/nxWlBtMDnUMiMdW8i5qd39XQo=;
  b=e8++ugwVOvqUA1TMV/hLnhbv3ISLZJQ0yXUyOHYM0Fby7TgNm1uIHXFx
   FQSbisxVAQBiSeLRcDUPODaofPsQD08eQKIpRUn3YcGsJ2iWJm5tvBGXo
   uafH1yKUVdePIzoDA7TwLUkMCeLxqnSFPq8lN++RT/+hTd9s2BVE+aGIx
   8=;
X-IronPort-AV: E=Sophos;i="5.62,369,1554768000"; 
   d="scan'208";a="770159556"
Received: from iad6-co-svc-p1-lb1-vlan3.amazon.com (HELO email-inbound-relay-2a-538b0bfb.us-west-2.amazon.com) ([10.124.125.6])
  by smtp-border-fw-out-4101.iad4.amazon.com with ESMTP; 13 Jun 2019 07:52:58 +0000
Received: from EX13MTAUWC001.ant.amazon.com (pdx1-ws-svc-p6-lb9-vlan3.pdx.amazon.com [10.236.137.198])
	by email-inbound-relay-2a-538b0bfb.us-west-2.amazon.com (Postfix) with ESMTPS id 64BE5A1B79;
	Thu, 13 Jun 2019 07:52:57 +0000 (UTC)
Received: from EX13D20UWC001.ant.amazon.com (10.43.162.244) by
 EX13MTAUWC001.ant.amazon.com (10.43.162.135) with Microsoft SMTP Server (TLS)
 id 15.0.1367.3; Thu, 13 Jun 2019 07:52:56 +0000
Received: from 38f9d3867b82.ant.amazon.com (10.43.162.225) by
 EX13D20UWC001.ant.amazon.com (10.43.162.244) with Microsoft SMTP Server (TLS)
 id 15.0.1367.3; Thu, 13 Jun 2019 07:52:53 +0000
Subject: Re: [RFC 00/10] Process-local memory allocations for hiding KVM
 secrets
To: Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>,
	Nadav Amit <namit@vmware.com>
CC: Marius Hillenbrand <mhillenb@amazon.de>, kvm list <kvm@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, Kernel Hardening
	<kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>,
	Alexander Graf <graf@amazon.de>, David Woodhouse <dwmw@amazon.co.uk>, "the
 arch/x86 maintainers" <x86@kernel.org>, Peter Zijlstra <peterz@infradead.org>
References: <20190612170834.14855-1-mhillenb@amazon.de>
 <eecc856f-7f3f-ed11-3457-ea832351e963@intel.com>
 <A542C98B-486C-4849-9DAC-2355F0F89A20@amacapital.net>
 <CALCETrXHbS9VXfZ80kOjiTrreM2EbapYeGp68mvJPbosUtorYA@mail.gmail.com>
From: Alexander Graf <graf@amazon.com>
Message-ID: <459e2273-bc27-f422-601b-2d6cdaf06f84@amazon.com>
Date: Thu, 13 Jun 2019 09:52:51 +0200
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <CALCETrXHbS9VXfZ80kOjiTrreM2EbapYeGp68mvJPbosUtorYA@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Originating-IP: [10.43.162.225]
X-ClientProxiedBy: EX13D17UWB004.ant.amazon.com (10.43.161.132) To
 EX13D20UWC001.ant.amazon.com (10.43.162.244)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 13.06.19 03:30, Andy Lutomirski wrote:
> On Wed, Jun 12, 2019 at 1:27 PM Andy Lutomirski <luto@amacapital.net> wrote:
>>
>>
>>> On Jun 12, 2019, at 12:55 PM, Dave Hansen <dave.hansen@intel.com> wrote:
>>>
>>>> On 6/12/19 10:08 AM, Marius Hillenbrand wrote:
>>>> This patch series proposes to introduce a region for what we call
>>>> process-local memory into the kernel's virtual address space.
>>> It might be fun to cc some x86 folks on this series.  They might have
>>> some relevant opinions. ;)
>>>
>>> A few high-level questions:
>>>
>>> Why go to all this trouble to hide guest state like registers if all the
>>> guest data itself is still mapped?
>>>
>>> Where's the context-switching code?  Did I just miss it?
>>>
>>> We've discussed having per-cpu page tables where a given PGD is only in
>>> use from one CPU at a time.  I *think* this scheme still works in such a
>>> case, it just adds one more PGD entry that would have to context-switched.
>> Fair warning: Linus is on record as absolutely hating this idea. He might change his mind, but it’s an uphill battle.
> I looked at the patch, and it (sensibly) has nothing to do with
> per-cpu PGDs.  So it's in great shape!


Thanks a lot for the very timely review!


>
> Seriously, though, here are some very high-level review comments:
>
> Please don't call it "process local", since "process" is meaningless.
> Call it "mm local" or something like that.


Naming is hard, yes :). Is "mmlocal" obvious enough to most readers? I'm 
not fully convinced, but I don't find it better or worse than proclocal. 
So whatever flies with the majority works for me :).


> We already have a per-mm kernel mapping: the LDT.  So please nix all
> the code that adds a new VA region, etc, except to the extent that
> some of it consists of valid cleanups in and of itself.  Instead,
> please refactor the LDT code (arch/x86/kernel/ldt.c, mainly) to make
> it use a more general "mm local" address range, and then reuse the
> same infrastructure for other fancy things.  The code that makes it


I don't fully understand how those two are related. Are you referring to 
the KPTI enabling code in there? That just maps the LDT at the same 
address in both kernel and user mappings, no?

So you're suggesting we use the new mm local address as LDT address 
instead and have that mapped in both kernel and user space? This patch 
set today maps "mm local" data only in kernel space, not in user space, 
as it's meant for kernel data structures.

So I'm not really seeing the path to adapt any of the LDT logic to this. 
Could you please elaborate?


> KASLR-able should be in its very own patch that applies *after* the
> code that makes it all work so that, when the KASLR part causes a
> crash, we can bisect it.


That sounds very reasonable, yes.


>
> + /*
> + * Faults in process-local memory may be caused by process-local
> + * addresses leaking into other contexts.
> + * tbd: warn and handle gracefully.
> + */
> + if (unlikely(fault_in_process_local(address))) {
> + pr_err("page fault in PROCLOCAL at %lx", address);
> + force_sig_fault(SIGSEGV, SEGV_MAPERR, (void __user *)address, current);
> + }
> +
>
> Huh?  Either it's an OOPS or you shouldn't print any special
> debugging.  As it is, you're just blatantly leaking the address of the
> mm-local range to malicious user programs.


Yes, this is a left over bit from an idea that we discussed and rejected 
yesterday. The idea was to have a DEBUG config option that allows 
proclocal memory to leak into other processes, but print debug output so 
that it's easier to catch bugs. After discussion, I think we managed to 
convince everyone that an OOPS is the better tool to find bugs :).

Any trace of this will disappear in the next version.


>
> Also, you should IMO consider using this mechanism for kmap_atomic().


It might make sense to use it for kmap_atomic() for debug purposes, as 
it ensures that other users can no longer access the same mapping 
through the linear map. However, it does come at quite a big cost, as we 
need to shoot down the TLB of all other threads in the system. So I'm 
not sure it's of general value?


Alex


> Hi, Nadav!

