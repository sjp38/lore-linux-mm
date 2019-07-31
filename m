Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5AFEDC32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 20:57:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A9312067D
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 20:57:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A9312067D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 85DBC8E0003; Wed, 31 Jul 2019 16:57:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 80E5B8E0001; Wed, 31 Jul 2019 16:57:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6AF328E0003; Wed, 31 Jul 2019 16:57:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 445268E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 16:57:22 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id e20so44059485pfd.3
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 13:57:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Ce9nkBsAwtLJUCS3a/UqY2gbJkh9us2DkIwpfeXiQzI=;
        b=VRZkJQRgAs2+S9lpSCT94Ub0LR+rN5Fz5qnDi1OhMEBit8vJNsv9gJTiJcyt74e+UE
         7NNOasc42GCSTbZjMpAaMh4pDHb2qttt2nMIEj03OGSFXTVM5OfNYFkXhYiTpPNDhOUR
         ALEK5pOTPJBd7g+eZptcRRiiWUnMebK7jZ6GyzbPQKuT6QrLOZuJEng/Uj6WGSPSFTG0
         kRL1H+1KBTI/2sS9b3+DegAc+UuQUpKWjvugZJNg4b09qYjehII2uMoXleD3ZhhoetpU
         WBEeP3EWVwgOSEGOGYqizTSj/5E8YESZiEDVRi9Rv5+atcE60BOr5nPEr7dL/hhujDAj
         cLDg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAXAdHNBWqpPRgKX5Xbu2VPOlfKChi/Tu5b4dDtMcrL2kTkmHXIn
	n4BRbbk0hDL0tMg0b86U+C+roTJfVVWUxAexOCg2Il0yeuylsc0xJ86OLnlKYFAr280SoabTzUy
	i/v0A9tpV+cwggWGjNw6Ntlc03RRMRhGXKR9Rnvzo7oqstYA19IIuTtdP0rwOdAF32A==
X-Received: by 2002:a17:902:3081:: with SMTP id v1mr124840604plb.169.1564606641789;
        Wed, 31 Jul 2019 13:57:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzg4bKVlox2jmbryXJ5oyE6rSvT8rDyzxAGnQB9ep3TiNMbJA0lXxYoVmtRu9Z/4OnV0nnm
X-Received: by 2002:a17:902:3081:: with SMTP id v1mr124840570plb.169.1564606640937;
        Wed, 31 Jul 2019 13:57:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564606640; cv=none;
        d=google.com; s=arc-20160816;
        b=N6WCLmZ8sYZvt3wEPsyrZvNJDGlDNCPUEPvvXQjb+/pp5VMwmUZza10cjjUcghL6GP
         OXF1IBPUJFmkFd+pIKj3dM0C8UOXg9fBJt7vDNk8xorVYJ1tKvH8nbgUs8tcEz0/yurN
         7I4mKKv7uqv9woX8ND6Q/rHhDi/WvP0o/SwvYVSPTivxuB/+KI7HwzwOvyUVKpKogAqw
         XUrnth6T+2pE2swP8Ul3EWZ9qJv/oeCaZSpURikRMD77fMnCsU0Qw28foTZKzaqJ+2Hh
         hA557oi4yQdFHehPyIjaFWbA/Hd1XlUfoz7YyRFIpBc2nxOlUQvN4VqBRkx7ZZo6U/VD
         HWtA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=Ce9nkBsAwtLJUCS3a/UqY2gbJkh9us2DkIwpfeXiQzI=;
        b=oSLi/qsc9iPZgD2rYOqJGO+HSVEiOmVkbNO//2t56SdzH9WQyy05+z1eD+cwfHoSfY
         E+73NsxDOrJVbJhTZSpbW+EC5Tt5FBKo+p5FooHBgFGSkwfxzL2szIqJ285bn960qKHy
         JXtSB+sY5a7K4fR3SVBzxZX05Y/P4Qjt8oq5H9qxhdMEde5o7ka+ZILoaXy973Lzm5Kd
         piDZfQV+0uxIICgYc+HhBiU/itb3njzNj5JX+IKbJx9qsB+icC7Eb+yQTR1MkFb2J78D
         vEvuC95yjbRz/GW+CAINBb/Kx4VdsHdkzJD6C3BRTEvbTOQ/IeeT0efcBMY/9DVEDozR
         /zYg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id d31si30243643pla.84.2019.07.31.13.57.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 13:57:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from X1 (unknown [76.191.170.112])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id BC89239AE;
	Wed, 31 Jul 2019 20:57:17 +0000 (UTC)
Date: Wed, 31 Jul 2019 13:57:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Greg Kroah-Hartman
 <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>,
 Pavel Tatashin <pasha.tatashin@soleen.com>, Michal Hocko <mhocko@suse.com>,
 Dan Williams <dan.j.williams@intel.com>, Oscar Salvador <osalvador@suse.de>
Subject: Re: [PATCH v1] drivers/base/memory.c: Don't store end_section_nr in
 memory blocks
Message-Id: <20190731135715.ddb4fccb5c4ee2f14f84a34a@linux-foundation.org>
In-Reply-To: <20190731122213.13392-1-david@redhat.com>
References: <20190731122213.13392-1-david@redhat.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 31 Jul 2019 14:22:13 +0200 David Hildenbrand <david@redhat.com> wrote:

> Each memory block spans the same amount of sections/pages/bytes. The size
> is determined before the first memory block is created. No need to store
> what we can easily calculate - and the calculations even look simpler now.
> 
> While at it, fix the variable naming in register_mem_sect_under_node() -
> we no longer talk about a single section.
> 
> ...
>
> --- a/include/linux/memory.h
> +++ b/include/linux/memory.h
> @@ -40,6 +39,8 @@ int arch_get_memory_phys_device(unsigned long start_pfn);
>  unsigned long memory_block_size_bytes(void);
>  int set_memory_block_size_order(unsigned int order);
>  
> +#define PAGES_PER_MEMORY_BLOCK (memory_block_size_bytes() / PAGE_SIZE)

Please let's not hide function calls inside macros which look like
compile-time constants!  Adding "()" to the macro would be a bit
better.  Making it a regular old inline C function would be better
still.  But I'd suggest just open-coding this at the macro's single
callsite.

