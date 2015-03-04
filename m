Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f46.google.com (mail-oi0-f46.google.com [209.85.218.46])
	by kanga.kvack.org (Postfix) with ESMTP id C2C096B0038
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 18:16:19 -0500 (EST)
Received: by oiav1 with SMTP id v1so8667692oia.9
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 15:16:19 -0800 (PST)
Received: from g9t5008.houston.hp.com (g9t5008.houston.hp.com. [15.240.92.66])
        by mx.google.com with ESMTPS id s124si2928915oif.116.2015.03.04.15.16.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Mar 2015 15:16:19 -0800 (PST)
Message-ID: <1425510939.17007.271.camel@misato.fc.hp.com>
Subject: Re: [PATCH v3 3/6] mm: Change ioremap to set up huge I/O mappings
From: Toshi Kani <toshi.kani@hp.com>
Date: Wed, 04 Mar 2015 16:15:39 -0700
In-Reply-To: <20150304220912.GA22518@gmail.com>
References: <1425404664-19675-1-git-send-email-toshi.kani@hp.com>
	 <1425404664-19675-4-git-send-email-toshi.kani@hp.com>
	 <20150304220912.GA22518@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com

On Wed, 2015-03-04 at 23:09 +0100, Ingo Molnar wrote:
> * Toshi Kani <toshi.kani@hp.com> wrote:
 :
> Hm, so I don't see where you set the proper x86 PAT table attributes 
> for the pmds.
> 
> MTRR's are basically a legacy mechanism, the proper way to set cache 
> attribute is PAT and I don't see where this generic code does that, 
> but I might be missing something?

It's done by x86 code, not by this generic code.  __ioremap_caller()
takes page_cache_mode and converts it to pgprot_t using the PAT table
attribute.  It then calls this generic func, ioremap_page_range().  When
creating a huge page mapping, pud_set_huge() and pmd_set_huge() handle
the relocation of the PAT bit.

Thanks,
-Toshi    

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
