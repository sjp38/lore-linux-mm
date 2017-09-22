Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0C7CC6B0253
	for <linux-mm@kvack.org>; Fri, 22 Sep 2017 02:12:56 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id x78so348721pff.7
        for <linux-mm@kvack.org>; Thu, 21 Sep 2017 23:12:56 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v1sor1543574pgq.130.2017.09.21.23.12.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Sep 2017 23:12:55 -0700 (PDT)
Date: Fri, 22 Sep 2017 16:12:43 +1000
From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: [PATCH 1/6] mm: introduce an additional vma bit for powerpc
 pkey
Message-ID: <20170922161243.7d03a5b6@firefly.ozlabs.ibm.com>
In-Reply-To: <1505524870-4783-2-git-send-email-linuxram@us.ibm.com>
References: <1505524870-4783-1-git-send-email-linuxram@us.ibm.com>
	<1505524870-4783-2-git-send-email-linuxram@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com

On Fri, 15 Sep 2017 18:21:05 -0700
Ram Pai <linuxram@us.ibm.com> wrote:

> Currently only 4bits are allocated in the vma flags to hold 16
> keys. This is sufficient for x86. PowerPC  supports  32  keys,
> which needs 5bits. This patch allocates an  additional bit.
> 
> Signed-off-by: Ram Pai <linuxram@us.ibm.com>
> ---

Acked-by: Balbir Singh <bsingharora@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
