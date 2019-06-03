Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AF93FC04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 22:14:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6F1E726025
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 22:14:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="aob8T9zl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F1E726025
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA6536B0272; Mon,  3 Jun 2019 18:14:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E7D096B0273; Mon,  3 Jun 2019 18:14:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DBA3C6B0274; Mon,  3 Jun 2019 18:14:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id A48766B0272
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 18:14:19 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id z10so10881677pgf.15
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 15:14:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=FDE6zvtTwrbHl8WPxjXTvEih9Amlz6PfWOeObQ8U77I=;
        b=Kbt9zYbT7vqm2xeo1+l2AssUpuJheZ3UY+Q8k1WDQLlc8OuNKa3Zn7QAdB3Nu7OJsl
         //YggjUp5LvoqTDTOVcsDZOndUT0N/Sv/XIULHgLGIkOEyyUgvJqiqeDX8hwieJIwvcP
         e217QNyRqSgYdVJlK1/BCoSey3dqWo9OyX8NtqQv+s0bfuTN4EBH5k6QyEMvpRIVwZ3z
         TZugT9jU5AFJcB5kNqdl+FNhVtO6utk2hzUrsb1Ofeh+Pdrs3MgBNBjsWnkAj9NY+xeK
         ChKJ+6rYj6i71A5hs1tNGYJzMZ2iGWp/YwR1JADdkOmIFpusHQma/WbDgo0sRhn4pet7
         Ld8A==
X-Gm-Message-State: APjAAAWRVtwlyzri53/PAK6ITnSH+ByjANkRJjGTV1lRskK8NQ+xhwxa
	RiOXzKuGn+Z3tAutHB36daWBiR10pgnf5Z78XPMOQLbhY1fOwdAZErE0fkmy/Sk+nfwLfGNSEZN
	oBB19iJmBmWSpneST17JKXsafH8myGfU+IYSJvVC3v/TbB6e3FEJvRbauo3MelPYZpg==
X-Received: by 2002:a17:90a:5d0a:: with SMTP id s10mr32879767pji.94.1559600059307;
        Mon, 03 Jun 2019 15:14:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz463yjhiqhthEKExu2KMljB1WiGtuhWDCqf0Hgw2lvf5gJ76ChmcBOeoMfeY9UkYPZpL2m
X-Received: by 2002:a17:90a:5d0a:: with SMTP id s10mr32879712pji.94.1559600058541;
        Mon, 03 Jun 2019 15:14:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559600058; cv=none;
        d=google.com; s=arc-20160816;
        b=Sj30Udnmd1PWAXx44zW6eO8VcTgUHw/ZXTw3pk4cugTUTDWdW4Jt8tnbQ7iMYD8mQQ
         G6Qm/+u3lab00OWrzzo+DOMRy4Pz6Ftz8uUAb7Ld07b/1lgsoFii3RZUHuzSzXj61yS9
         uLWMr2B8+UshCTJLOTTZ45N9hzs50GTHbMsZYhbGFzZ4eT9oNokeON1YltITo+1KZ3An
         JPerLxZPBegWtpNW2JBGsxXZpEozL2JtxcXqjxyUTszK8Ma3dzhgvpu1FedRfhUmFwSQ
         jxwol2lBdgrdQ8TrzyE3+jWL6xeerIRJkkNKa9SiBsE+FcPGMGVfcBk64cUsHnl5cdoL
         Hdrw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=FDE6zvtTwrbHl8WPxjXTvEih9Amlz6PfWOeObQ8U77I=;
        b=ZlgX2pfxkTZfryGcmwwopJT0jSiGphNU9CR6iON9pm+ErMvoD8hNF6tt85D9cn1HiP
         SZtMKDWX1QKDcD8hBbVCygWr/VLUSeO2Evf8FTP0JMZPAc6j1tkk3K22/Un0QPvNHk5r
         tQ/3Du/X7DySMDiOV5j2gg0D1TuIcbDkWK4BXwn1H1A5KYEVVXnz3mFchkhXP2K47Pk1
         F3aT2ewcB43b7PjEQN8QJUdsN6R0ARIwzSxMMA+2r6xJ7voXokCGmFxaR++TJIRoPHNk
         wrC+1N/TLtKNSVEiMnPNC14CGi+ztcEPHbrYTdtEhaFjx913DS+guL3Aue8SXZRbi8R3
         RC1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=aob8T9zl;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q22si20776909pgl.309.2019.06.03.15.14.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 15:14:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=aob8T9zl;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id C577626025;
	Mon,  3 Jun 2019 22:14:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559600058;
	bh=cogaTUU7aIlPYLzxucrIMk9mt8HcFOph+/No3WD2v7o=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=aob8T9zlkLq6l2Wbv69TLZR6KHoylIhbaI/Ld9QVrHWaiHXUS51PLE60j+DBLLWzZ
	 yBHsQRpz0+BEGLgRQ79Bl8BnPpXh0YtnpXBOfzmSOgGY0HgILrBo00BIEaQT88wNB0
	 5PWTWxgWJATPNMlUuzaEvG0nkm7pSNg0Z28sBsu4=
Date: Mon, 3 Jun 2019 15:14:17 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: kbuild test robot <lkp@intel.com>
Cc: Kairui Song <kasong@redhat.com>, kbuild-all@01.org, Bhupesh Sharma
 <bhsharma@redhat.com>, Linux Memory Management List <linux-mm@kvack.org>
Subject: Re: [linux-next:master 3906/3985] fs/proc/vmcore.c:59:43: error:
 expected ')' before 'bool'
Message-Id: <20190603151417.2a637b3e73207802e2829606@linux-foundation.org>
In-Reply-To: <201906030232.nmc5yeSR%lkp@intel.com>
References: <201906030232.nmc5yeSR%lkp@intel.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 3 Jun 2019 02:35:34 +0800 kbuild test robot <lkp@intel.com> wrote:

> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   3c09c1950c8483eeeb4bf9615ecdcec7234c6790
> commit: 0f5a18299c6b7e1d6900d950006d3fad329f6c6e [3906/3985] vmcore: Add a kernel parameter novmcoredd
> config: x86_64-randconfig-g2-201921 (attached as .config)
> compiler: gcc-7 (Debian 7.3.0-1) 7.3.0
> reproduce:
>         git checkout 0f5a18299c6b7e1d6900d950006d3fad329f6c6e
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> If you fix the issue, kindly add following tag
> Reported-by: kbuild test robot <lkp@intel.com>
> 
> All errors (new ones prefixed by >>):
> 
> >> fs/proc/vmcore.c:59:43: error: expected ')' before 'bool'
>     core_param(novmcoredd, vmcoredd_disabled, bool, 0);
>                                               ^~~~
> 
> vim +59 fs/proc/vmcore.c
> 
>     57	
>     58	static bool vmcoredd_disabled;
>   > 59	core_param(novmcoredd, vmcoredd_disabled, bool, 0);
>     60	#endif /* CONFIG_PROC_VMCORE_DEVICE_DUMP */
>     61	

--- a/fs/proc/vmcore.c~vmcore-add-a-kernel-parameter-novmcoredd-fix-fix
+++ a/fs/proc/vmcore.c
@@ -21,6 +21,7 @@
 #include <linux/init.h>
 #include <linux/crash_dump.h>
 #include <linux/list.h>
+#include <linux/moduleparam.h>
 #include <linux/mutex.h>
 #include <linux/vmalloc.h>
 #include <linux/pagemap.h>
_

