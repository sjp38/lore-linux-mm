Return-Path: <SRS0=HJeg=QJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD29AC282D7
	for <linux-mm@archiver.kernel.org>; Sat,  2 Feb 2019 10:50:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 799CE20869
	for <linux-mm@archiver.kernel.org>; Sat,  2 Feb 2019 10:50:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 799CE20869
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CC7228E0016; Sat,  2 Feb 2019 05:50:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C73958E0001; Sat,  2 Feb 2019 05:50:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B62938E0016; Sat,  2 Feb 2019 05:50:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 730F38E0001
	for <linux-mm@kvack.org>; Sat,  2 Feb 2019 05:50:09 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id m16so6624357pgd.0
        for <linux-mm@kvack.org>; Sat, 02 Feb 2019 02:50:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=y5e9VKD9A/YYLPONivbrSKexuxaCuW8XMG8N4KdgAwk=;
        b=WSaSj5Oy3l1oXDrnYSHK8aHDDpx7yRNAO0fRKSlc9glY1RIfIMXb77YO4/vSYQHX02
         ADn860wE0HVAtu1eK6/L68fS6zkyc4dlmS94aQeBpdNaxglOyH8XaJhvnniV/wUqWO6P
         IIe/ypQn8BxCO/YriFrzo0oC+0HzoYrC4KyTQPLye2tHBdgZvINZRTGlDfP/9/Ucd8iL
         zuZZ/+BaChiClRfcKxGBYJhUvslFCisL20IIyWvIltGBJcy0LSOvGB7F58gqENphTqo8
         Y3MMnPxcF5Xm5qAKjVw8YgFDdhKTACOI4YMDL/wM5QhuTLXxxBFZh3WewXPqXi/U7tl0
         IdSg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fengguang.wu@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukclTh+ZU+RfugGlb9wub3Ww8nfK8ViOFLQMQoDBAjp7NOxWiy1j
	iYXmmeReURDUftka1eP4pce3dvkcxYlIdA6wMO4JwqO6MaQIN/iQQgPfrzj5G4YB2gYYs1LqHg6
	PdYRyNTjXujuOnhM3Q6FF6oC0rrrFXTolP8zewlmuOx0qt4JHXByVHMacxC6h9bNgUA==
X-Received: by 2002:a62:4618:: with SMTP id t24mr25759004pfa.139.1549104608990;
        Sat, 02 Feb 2019 02:50:08 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbC8PQOzzZ1xJR3iCyV1slqPHYFMAysnafwKAuK1Vm86ZFTfhsyRNbwNLvkinDNzSQ4apJu
X-Received: by 2002:a62:4618:: with SMTP id t24mr25758927pfa.139.1549104607029;
        Sat, 02 Feb 2019 02:50:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549104607; cv=none;
        d=google.com; s=arc-20160816;
        b=c2HOPh56ZzkhE/t5xA8fN179TY7UC7oPTs/b+IVtc+Y5k5sfoccT3iwSrsNYotZ30g
         P+v0950Bq7d85T9G34e50AF7Saol0tBlQt9VsX9XnE2Xs3a5mUey9lZjyWkwJv2s1Gvz
         iOaPREoCbaThoDyzpzbIvT85tfa0KyfRoeqSSXHDBUJVb8h8+47whR59Hth8TLvzay3S
         rEA4pRwsg2gObuvLe7c1wtr+IGmrhBXnLpAdXsuCvOWJRy097uVPnsviyFfJ937bMSI7
         tgAnqQtGhieNNnRuVcuakbcXp10WMKCr0iAyhi6/w5uSA/ZYQAJHG4dQRRKQBIgW110H
         CmGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=y5e9VKD9A/YYLPONivbrSKexuxaCuW8XMG8N4KdgAwk=;
        b=X5ZIFDBPi7UD4LYw6adQx8/X4cknuIG/VBoMmhJPUeim0OCWNGD+A1K9az736GzvOC
         O/zekKdLXkNnGc3bzs+ldUGwgI82Je56uRFJpE24DICE+X2/1wWwtqU4WMsg2+CNAcxk
         JPKs3S6XzkQMvfbjw6v/pUIPaYBg4JdXz3rNkmxYYMEj7AUNAN1dFg75KrNGb5GxZpR9
         NTtzGRFgl1dPbymN7J7HM96LxCbhs08QiwBEndjNrIzvF4ajDVceifqj53q+qMJYIDC/
         BBL7o/FFWvo3fHzBQef/AJBUKpaVJOhT8yOyAkC2qjAhjtnzAa/uszYsN4M8vXDx+Jyy
         l6qQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id g10si10987001plm.1.2019.02.02.02.50.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 02 Feb 2019 02:50:06 -0800 (PST)
Received-SPF: pass (google.com: domain of fengguang.wu@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 02 Feb 2019 02:50:06 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,552,1539673200"; 
   d="scan'208";a="130591685"
Received: from lzhan14x-mobl1.ccr.corp.intel.com (HELO wfg-t570.sh.intel.com) ([10.254.213.188])
  by FMSMGA003.fm.intel.com with ESMTP; 02 Feb 2019 02:50:02 -0800
Received: from wfg by wfg-t570.sh.intel.com with local (Exim 4.89)
	(envelope-from <fengguang.wu@intel.com>)
	id 1gpss6-0004tS-6L; Sat, 02 Feb 2019 18:50:02 +0800
Date: Sat, 2 Feb 2019 18:50:02 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
To: Peter Xu <peterx@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	Nikita Leshenko <nikita.leshchenko@oracle.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>, kvm@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, Fan Du <fan.du@intel.com>,
	Yao Yuan <yuan.yao@intel.com>, Peng Dong <dongx.peng@intel.com>,
	Huang Ying <ying.huang@intel.com>,
	Liu Jingqi <jingqi.liu@intel.com>,
	Dong Eddie <eddie.dong@intel.com>,
	Dave Hansen <dave.hansen@intel.com>,
	Zhang Yi <yi.z.zhang@linux.intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Paolo Bonzini <pbonzini@redhat.com>
Subject: Re: [RFC][PATCH v2 14/21] kvm: register in mm_struct
Message-ID: <20190202105002.amvqgvnkgfxpiowe@wfg-t540p.sh.intel.com>
References: <20181226131446.330864849@intel.com>
 <20181226133351.894160986@intel.com>
 <20190202065741.GA1011@xz-x1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190202065741.GA1011@xz-x1>
User-Agent: NeoMutt/20170609 (1.8.3)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Peter,

On Sat, Feb 02, 2019 at 02:57:41PM +0800, Peter Xu wrote:
>On Wed, Dec 26, 2018 at 09:15:00PM +0800, Fengguang Wu wrote:
>> VM is associated with an address space and not a specific thread.
>>
>> >From Documentation/virtual/kvm/api.txt:
>>    Only run VM ioctls from the same process (address space) that was used
>>    to create the VM.
>
>Hi, Fengguang,
>
>AFAIU the commit message only explains why a kvm object needs to bind
>to a single mm object (say, the reason why there is kvm->mm) however
>not the reverse (say, the reason why there is mm->kvm), while the
>latter is what this patch really needs?

Yeah good point. The addition of mm->kvm makes code in this patchset
simple. However if that field is considered not general useful for
other possible users, and the added space overheads is a concern, we
can instead do with a flag (saying the mm is referenced by some KVM),
and add extra lookup code to find out the exact kvm instance.

>I'm thinking whether it's legal for multiple VMs to run on a single mm
>address space.  I don't see a limitation so far but it's very possible
>I am just missing something there (if there is, IMHO they might be
>something nice to put into the commit message?).  Thanks,

So far one QEMU only starts one KVM. I cannot think of any strong
benefit to start multiple KVMs in one single QEMU, so it may well
remain so in future. Anyway it's internal data structure instead of
API, which can adapt to possible future changes.

Thanks,
Fengguang

>> CC: Nikita Leshenko <nikita.leshchenko@oracle.com>
>> CC: Christian Borntraeger <borntraeger@de.ibm.com>
>> Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
>> ---
>>  include/linux/mm_types.h |   11 +++++++++++
>>  virt/kvm/kvm_main.c      |    3 +++
>>  2 files changed, 14 insertions(+)
>>
>> --- linux.orig/include/linux/mm_types.h	2018-12-23 19:58:06.993417137 +0800
>> +++ linux/include/linux/mm_types.h	2018-12-23 19:58:06.993417137 +0800
>> @@ -27,6 +27,7 @@ typedef int vm_fault_t;
>>  struct address_space;
>>  struct mem_cgroup;
>>  struct hmm;
>> +struct kvm;
>>
>>  /*
>>   * Each physical page in the system has a struct page associated with
>> @@ -496,6 +497,10 @@ struct mm_struct {
>>  		/* HMM needs to track a few things per mm */
>>  		struct hmm *hmm;
>>  #endif
>> +
>> +#if IS_ENABLED(CONFIG_KVM)
>> +		struct kvm *kvm;
>> +#endif
>>  	} __randomize_layout;
>>
>>  	/*
>> @@ -507,6 +512,12 @@ struct mm_struct {
>>
>>  extern struct mm_struct init_mm;
>>
>> +#if IS_ENABLED(CONFIG_KVM)
>> +static inline struct kvm *mm_kvm(struct mm_struct *mm) { return mm->kvm; }
>> +#else
>> +static inline struct kvm *mm_kvm(struct mm_struct *mm) { return NULL; }
>> +#endif
>> +
>>  /* Pointer magic because the dynamic array size confuses some compilers. */
>>  static inline void mm_init_cpumask(struct mm_struct *mm)
>>  {
>> --- linux.orig/virt/kvm/kvm_main.c	2018-12-23 19:58:06.993417137 +0800
>> +++ linux/virt/kvm/kvm_main.c	2018-12-23 19:58:06.993417137 +0800
>> @@ -727,6 +727,7 @@ static void kvm_destroy_vm(struct kvm *k
>>  	struct mm_struct *mm = kvm->mm;
>>
>>  	kvm_uevent_notify_change(KVM_EVENT_DESTROY_VM, kvm);
>> +	mm->kvm = NULL;
>>  	kvm_destroy_vm_debugfs(kvm);
>>  	kvm_arch_sync_events(kvm);
>>  	spin_lock(&kvm_lock);
>> @@ -3224,6 +3225,8 @@ static int kvm_dev_ioctl_create_vm(unsig
>>  		fput(file);
>>  		return -ENOMEM;
>>  	}
>> +
>> +	kvm->mm->kvm = kvm;
>>  	kvm_uevent_notify_change(KVM_EVENT_CREATE_VM, kvm);
>>
>>  	fd_install(r, file);
>>
>>
>
>Regards,
>
>-- 
>Peter Xu
>

