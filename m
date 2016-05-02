Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CA18D6B007E
	for <linux-mm@kvack.org>; Sun,  1 May 2016 21:05:48 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e190so371859611pfe.3
        for <linux-mm@kvack.org>; Sun, 01 May 2016 18:05:48 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id w127si196236pfb.38.2016.05.01.18.05.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 May 2016 18:05:47 -0700 (PDT)
Received: by mail-pa0-x235.google.com with SMTP id iv1so67530443pac.2
        for <linux-mm@kvack.org>; Sun, 01 May 2016 18:05:47 -0700 (PDT)
Subject: Re: [RFC 1/5] powerpc: Rename context.vdso_base to context.vdso
References: <20151202121918.GA4523@arm.com>
 <1461856737-17071-1-git-send-email-cov@codeaurora.org>
 <1461856737-17071-2-git-send-email-cov@codeaurora.org>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <5726A7D5.7030305@gmail.com>
Date: Mon, 2 May 2016 11:05:25 +1000
MIME-Version: 1.0
In-Reply-To: <1461856737-17071-2-git-send-email-cov@codeaurora.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Covington <cov@codeaurora.org>, Catalin Marinas <catalin.marinas@arm.com>, criu@openvz.org, Laurent Dufour <ldufour@linux.vnet.ibm.com>, Will Deacon <Will.Deacon@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Arnd Bergmann <arnd@arndb.de>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-arch@vger.kernel.org, linux-mm@kvack.org



On 29/04/16 01:18, Christopher Covington wrote:
> In order to share remap and unmap support for the VDSO with other
> architectures without duplicating the code, we need a common name and type
> for the address of the VDSO. An informal survey of the architectures
> indicates unsigned long vdso is popular. Change the variable name in
> powerpc from mm->context.vdso_base to simply mm->context.vdso.
> 

Could you please provide additional details on why the remap/unmap operations are required?
This patch does rename, but should it abstract via a function acesss to vmap field using arch_* operations? Not sure

Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
