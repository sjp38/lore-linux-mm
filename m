Return-Path: <SRS0=sWz3=SD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18632C43381
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 23:06:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CDD5C20880
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 23:06:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CDD5C20880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5C6D06B0003; Mon,  1 Apr 2019 19:06:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 575DF6B0005; Mon,  1 Apr 2019 19:06:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4191A6B0007; Mon,  1 Apr 2019 19:06:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 090C16B0003
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 19:06:02 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id u78so8319497pfa.12
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 16:06:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=EtKHIy8fQa/h8PAhFjMfd95BFLV40kjPqj5XwEyKlRI=;
        b=mmyyqAkwPsUiSDTzzSGmrTgJRz+MNqeBaO5Hzs40whqfGYZ1BHcvmntBSG3DL92+zg
         qQCz/DqbczPfmEvUTIX7g+tDHf5sQq+9a1DXB6Fotylb7VfUUseOilo0ev+fhkt1kFCm
         JNE7HG5XoAnAX4XTibzhAP6KfgBneS7kguh/fkBWCLzqdgEowJIq1TgDNX9H71ZiOPDk
         l12FeHHW8RvV5c0Z2GGHF27H/i9OiQX3ofmSGGINi2ETe3d3Fo+JnAO2e9CYy97Ke2oP
         TtP/HP/DEB+DwVxx/S+O+SlVb40yvaoIsGHJQHhGu4rvm4eKxuvB4jMC/rPGThmdR8+t
         gnFg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAXRdOH3qfmPLq21iop4wiqGNLR0Ase+1I3d7BgM9V4qNl+aloZY
	avJfJeNkcwLAA6zAtdZw+W6BiTSuXM+q32ervTjnCc6Cg71gI6kfQ4IycrKTUBzv7IRFuXSiNby
	HQk4QIPCELjyd6Hy3ujJlBiklrCoof3ZsZSXDZqnzYuhGDSKL38rHauc5VKhONRFCVA==
X-Received: by 2002:a17:902:e48c:: with SMTP id cj12mr19568582plb.93.1554159961611;
        Mon, 01 Apr 2019 16:06:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyLOHNPnIR3SCkp+hThrz0Arv5jMHgfAK1ME6lZbEav5mjEXhOoTB5MyeSaCbh8B6nSvieP
X-Received: by 2002:a17:902:e48c:: with SMTP id cj12mr19568518plb.93.1554159960796;
        Mon, 01 Apr 2019 16:06:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554159960; cv=none;
        d=google.com; s=arc-20160816;
        b=n52ouSk2HQ1Mcv+L+5/1q6mayrl515X436j9ECIyy6Heh6D9nD6GnXkMHYIcOgjDOi
         zkcSGb3GEJGzCKTWjCI4m2IW1pN9PCd5iO3QOOkfSBKzoVwHHJpnHH86Q9qP0WOSMsMe
         F1j6Aax0UBw52pEbUX9sFMWEFcfj2wzvNOwnz27MjObNsm4vm9nbcil+fZ7O9mMfvRjq
         ouXw/C1ooSuAvwLVTycGjsVKlAnpykti8UDl05hsUmuPsn1I2PdwcDrVQR6xkjZP5VPq
         tH0xdQHZ1ncoZbQylZmoIX4HEuvIt/+KtiPZyUzovUXhjoRXNQQd34sDO8hBy4HA3aP1
         kWbw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=EtKHIy8fQa/h8PAhFjMfd95BFLV40kjPqj5XwEyKlRI=;
        b=k3bMd9q7TOxaD0uUAClJzWBIx1eYMofDqJ99xaizQRotHcQaAP8bvjYIa2j9oE5qH5
         faQsYmRweFRN1PxOE2KHQ52HdYNe0tWqOdd8XWtieNEAQn7C8wEn7ZtS11gXtx6++alo
         7nsYFPm+92diSCoUeXl+vlcxS6HGm5nJq/F21GA1mFBWnLT3+l6L3gKygnF8evnnC6Sj
         L2J1wGdgHm8s7fdo3l/GVMlJA22iYs5dCeZJNH9QiBZUgvevy10ATV9XRfbYsMuBN3s7
         T1exUePBr2QBINCiZZoU9QIPvkBQb5dpDFleMmoPtyKrQeGxfmO7z5hcAjn7cT8KaV9H
         6cNg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m26si9767657pfi.247.2019.04.01.16.06.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Apr 2019 16:06:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 51957B59;
	Mon,  1 Apr 2019 23:06:00 +0000 (UTC)
Date: Mon, 1 Apr 2019 16:05:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: linux-mm@kvack.org
Subject: Re: [PATCH] Bump vm.mmap_min_addr on 64-bit
Message-Id: <20190401160559.6e945d8d235ae16006702bfc@linux-foundation.org>
In-Reply-To: <20190401050613.GA16287@avx2>
References: <20190401050613.GA16287@avx2>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 1 Apr 2019 08:06:13 +0300 Alexey Dobriyan <adobriyan@gmail.com> wrote:

> No self respecting 64-bit program should ever touch that lowly 32-bit
> part of address space.
>
> ...
>
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -306,7 +306,8 @@ config KSM
>  config DEFAULT_MMAP_MIN_ADDR
>          int "Low address space to protect from user allocation"
>  	depends on MMU
> -        default 4096
> +	default 4096 if !64BIT
> +	default 4294967296 if 64BIT
>          help
>  	  This is the portion of low virtual memory which should be protected
>  	  from userspace allocation.  Keeping a user from writing to low pages
> --- a/security/Kconfig
> +++ b/security/Kconfig
> @@ -129,7 +129,8 @@ config LSM_MMAP_MIN_ADDR
>  	int "Low address space for LSM to protect from user allocation"
>  	depends on SECURITY && SECURITY_SELINUX
>  	default 32768 if ARM || (ARM64 && COMPAT)
> -	default 65536
> +	default 65536 if !64BIT
> +	default 4294967296 if 64BIT
>  	help
>  	  This is the portion of low virtual memory which should be protected
>  	  from userspace allocation.  Keeping a user from writing to low pages

Gee.  Do we have any idea what effect this will have upon all userspace
programs, some of which do inexplicably weird things?

What's the benefit?

