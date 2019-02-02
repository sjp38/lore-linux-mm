Return-Path: <SRS0=HJeg=QJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7392FC282DB
	for <linux-mm@archiver.kernel.org>; Sat,  2 Feb 2019 06:57:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3AE1320870
	for <linux-mm@archiver.kernel.org>; Sat,  2 Feb 2019 06:57:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3AE1320870
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CFF488E0014; Sat,  2 Feb 2019 01:57:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C86858E0001; Sat,  2 Feb 2019 01:57:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B4F818E0014; Sat,  2 Feb 2019 01:57:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 850298E0001
	for <linux-mm@kvack.org>; Sat,  2 Feb 2019 01:57:55 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id 42so11133710qtr.7
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 22:57:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=+r2/nz6E9bzJ8BapN2IMO+3bxDXPVlT/LkkJKlmeSng=;
        b=g6jwbtkdV5uzYrwdV4k9TVeojkFvoZ82luRFv4YxpV4DFLZvgbQkKD/ZZKA4ptg6nk
         FqQHIBZUC28knLqRZGSpJh/S0Y0uVVaYR561RRyE73xILq9jAQobAsNu6kz+9UgOpWx1
         Z9o/ZDqJ0NAEMiPRc9/r71Npq3daEUPGJiT2i6NuWVUNolSTt6WtMjv7AM1atr9VVqyq
         ryfkbTH9jJo1Am9HDJcThIKMIfylwFOfETPEMiESDZObIhrvNUBG/G5vQo2B+GLcOa6V
         pPhH5nk7auZ4tsWpx4A+UN76ioVN79O7z94ThIM7ckJa1KW5bfi0kAT+c76N9vPKeNV5
         3L3Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukcO+xM3ajl9D7Fl2hwWLSvWC7+JEvKbG/S7wRZyPrVkrZEx1/bY
	fzDo55rp8OOhRso62ZC094rcTDc/NRkOx4yY3qCdpLGzFkYVcLtRJZnO6s9SDsklipu2G8eACUa
	qUsuN9ju6bGfwOEQbGXiUI9N8kgDGL46dhlbSARz54FU0x/JO1165pVuH+6wRfoTbaw==
X-Received: by 2002:aed:3263:: with SMTP id y90mr40497254qtd.269.1549090675249;
        Fri, 01 Feb 2019 22:57:55 -0800 (PST)
X-Google-Smtp-Source: ALg8bN42CzowX0Grj5uJbpZzW3nMiPT3bXpMrjw61CUh6G6yjFYKShn9dU3FxQrGGm06Sep0yfOF
X-Received: by 2002:aed:3263:: with SMTP id y90mr40497232qtd.269.1549090674550;
        Fri, 01 Feb 2019 22:57:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549090674; cv=none;
        d=google.com; s=arc-20160816;
        b=dVxvUM8PuzHfsKM4UD00YeKSeClW4/u/N78g7goELVWXZBwBdc9BEs0wVGKe2Sa9lk
         sL0gBzNdc/3XGeg2Bzxf+yChuEdA9t9G8TgymWXoQhdoln23qC2NitDDg0CaJ1vHfEtz
         ohxr2F36O1HuTOWve1AY+jtHba0ueN8r1SAi2LGYE/+1dVegXIy2rMpIcQUnsNaX18pD
         xNoyK11HtCf2Mc16W5yLYcam/iVkZQnxDvSOeg6+DlHtskPPPsP48lxV7+dBkXpkJHHd
         BuTQCn119UqwglknicB5Ape7SAQy7d32KP1XyFLBim5eL0zR+hTLaZPM7/uCpwDafIds
         jzRw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=+r2/nz6E9bzJ8BapN2IMO+3bxDXPVlT/LkkJKlmeSng=;
        b=gO3Lj+pe+Z/VevLy1Z/YFvfFdXbOFBodxDcIN38HGO1gby8umCLfBlD69Cgwj06FtA
         Q4d08nlJSbmxlB9SEeNFacg76BAHZIovgBESoRNp8OUbXR4MUtaJFmwdWZNINuC/Ga6z
         nYwSclBm6NStp/DOpeWzhqk11TX//S0w6oKrSQTT0l4p+bwUSqgZcje/4fzEyiRs5XDl
         aK2ibjxG/lo8wzGR2VyfhtoMVIFhY/jFmbu7lMjLl9LmVYRG0C8jdLdvdzUVQFvqhojx
         drWGTrxINhcAgddKTTAH7LtMQgxLA6aJsbQkNn5mvr52voJhwJYe3C5SEgRk+AZHuuXJ
         S2tA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j90si134855qtd.27.2019.02.01.22.57.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 22:57:54 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 022E989AE6;
	Sat,  2 Feb 2019 06:57:53 +0000 (UTC)
Received: from xz-x1 (ovpn-12-23.pek2.redhat.com [10.72.12.23])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id B6F7C5C20D;
	Sat,  2 Feb 2019 06:57:43 +0000 (UTC)
Date: Sat, 2 Feb 2019 14:57:41 +0800
From: Peter Xu <peterx@redhat.com>
To: Fengguang Wu <fengguang.wu@intel.com>
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
Message-ID: <20190202065741.GA1011@xz-x1>
References: <20181226131446.330864849@intel.com>
 <20181226133351.894160986@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20181226133351.894160986@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Sat, 02 Feb 2019 06:57:53 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Dec 26, 2018 at 09:15:00PM +0800, Fengguang Wu wrote:
> VM is associated with an address space and not a specific thread.
> 
> >From Documentation/virtual/kvm/api.txt:
>    Only run VM ioctls from the same process (address space) that was used
>    to create the VM.

Hi, Fengguang,

AFAIU the commit message only explains why a kvm object needs to bind
to a single mm object (say, the reason why there is kvm->mm) however
not the reverse (say, the reason why there is mm->kvm), while the
latter is what this patch really needs?

I'm thinking whether it's legal for multiple VMs to run on a single mm
address space.  I don't see a limitation so far but it's very possible
I am just missing something there (if there is, IMHO they might be
something nice to put into the commit message?).  Thanks,

> 
> CC: Nikita Leshenko <nikita.leshchenko@oracle.com>
> CC: Christian Borntraeger <borntraeger@de.ibm.com>
> Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
> ---
>  include/linux/mm_types.h |   11 +++++++++++
>  virt/kvm/kvm_main.c      |    3 +++
>  2 files changed, 14 insertions(+)
> 
> --- linux.orig/include/linux/mm_types.h	2018-12-23 19:58:06.993417137 +0800
> +++ linux/include/linux/mm_types.h	2018-12-23 19:58:06.993417137 +0800
> @@ -27,6 +27,7 @@ typedef int vm_fault_t;
>  struct address_space;
>  struct mem_cgroup;
>  struct hmm;
> +struct kvm;
>  
>  /*
>   * Each physical page in the system has a struct page associated with
> @@ -496,6 +497,10 @@ struct mm_struct {
>  		/* HMM needs to track a few things per mm */
>  		struct hmm *hmm;
>  #endif
> +
> +#if IS_ENABLED(CONFIG_KVM)
> +		struct kvm *kvm;
> +#endif
>  	} __randomize_layout;
>  
>  	/*
> @@ -507,6 +512,12 @@ struct mm_struct {
>  
>  extern struct mm_struct init_mm;
>  
> +#if IS_ENABLED(CONFIG_KVM)
> +static inline struct kvm *mm_kvm(struct mm_struct *mm) { return mm->kvm; }
> +#else
> +static inline struct kvm *mm_kvm(struct mm_struct *mm) { return NULL; }
> +#endif
> +
>  /* Pointer magic because the dynamic array size confuses some compilers. */
>  static inline void mm_init_cpumask(struct mm_struct *mm)
>  {
> --- linux.orig/virt/kvm/kvm_main.c	2018-12-23 19:58:06.993417137 +0800
> +++ linux/virt/kvm/kvm_main.c	2018-12-23 19:58:06.993417137 +0800
> @@ -727,6 +727,7 @@ static void kvm_destroy_vm(struct kvm *k
>  	struct mm_struct *mm = kvm->mm;
>  
>  	kvm_uevent_notify_change(KVM_EVENT_DESTROY_VM, kvm);
> +	mm->kvm = NULL;
>  	kvm_destroy_vm_debugfs(kvm);
>  	kvm_arch_sync_events(kvm);
>  	spin_lock(&kvm_lock);
> @@ -3224,6 +3225,8 @@ static int kvm_dev_ioctl_create_vm(unsig
>  		fput(file);
>  		return -ENOMEM;
>  	}
> +
> +	kvm->mm->kvm = kvm;
>  	kvm_uevent_notify_change(KVM_EVENT_CREATE_VM, kvm);
>  
>  	fd_install(r, file);
> 
> 

Regards,

-- 
Peter Xu

