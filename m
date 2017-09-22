Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8ADCB6B0033
	for <linux-mm@kvack.org>; Fri, 22 Sep 2017 02:09:11 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id i130so396801pgc.5
        for <linux-mm@kvack.org>; Thu, 21 Sep 2017 23:09:11 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f63sor1560861pgc.51.2017.09.21.23.09.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Sep 2017 23:09:10 -0700 (PDT)
Date: Fri, 22 Sep 2017 16:08:59 +1000
From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: [PATCH 3/6] mm: display pkey in smaps if arch_pkeys_enabled()
 is true
Message-ID: <20170922160859.33a01da9@firefly.ozlabs.ibm.com>
In-Reply-To: <1505524870-4783-4-git-send-email-linuxram@us.ibm.com>
References: <1505524870-4783-1-git-send-email-linuxram@us.ibm.com>
	<1505524870-4783-4-git-send-email-linuxram@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com

On Fri, 15 Sep 2017 18:21:07 -0700
Ram Pai <linuxram@us.ibm.com> wrote:

> +#ifdef CONFIG_ARCH_HAS_PKEYS
> +	if (arch_pkeys_enabled())

Sorry, I missed this bit in my previous review
the patch makes sense

> +		seq_printf(m, "ProtectionKey:  %8u\n", vma_pkey(vma));
> +#endif
> +

Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
