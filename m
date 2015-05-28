Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id A4F196B006C
	for <linux-mm@kvack.org>; Thu, 28 May 2015 09:59:37 -0400 (EDT)
Received: by wizk4 with SMTP id k4so148013158wiz.1
        for <linux-mm@kvack.org>; Thu, 28 May 2015 06:59:37 -0700 (PDT)
Received: from cvs.linux-mips.org (eddie.linux-mips.org. [148.251.95.138])
        by mx.google.com with ESMTP id h5si4825154wiy.49.2015.05.28.06.59.35
        for <linux-mm@kvack.org>;
        Thu, 28 May 2015 06:59:36 -0700 (PDT)
Received: from localhost.localdomain ([127.0.0.1]:59061 "EHLO linux-mips.org"
        rhost-flags-OK-OK-OK-FAIL) by eddie.linux-mips.org with ESMTP
        id S27013067AbbE1N7c40lwZ (ORCPT <rfc822;linux-mm@kvack.org>);
        Thu, 28 May 2015 15:59:32 +0200
Date: Thu, 28 May 2015 15:59:06 +0200
From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH 3/5] mm/hugetlb: remove arch_prepare/release_hugepage
 from arch headers
Message-ID: <20150528135905.GD1179@linux-mips.org>
References: <1432813957-46874-1-git-send-email-dingel@linux.vnet.ibm.com>
 <1432813957-46874-4-git-send-email-dingel@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1432813957-46874-4-git-send-email-dingel@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dominik Dingel <dingel@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, Russell King <linux@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, James Hogan <james.hogan@imgtec.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux390@de.ibm.com, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@ezchip.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andrew Morton <akpm@linux-foundation.org>, Zhang Zhen <zhenzhang.zhang@huawei.com>, David Rientjes <rientjes@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Nathan Lynch <nathan_lynch@mentor.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Andy Lutomirski <luto@amacapital.net>, Michael Holzheu <holzheu@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Paolo Bonzini <pbonzini@redhat.com>, "Jason J. Herne" <jjherne@linux.vnet.ibm.com>, Davidlohr Bueso <dave@stgolabs.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Luiz Capitulino <lcapitulino@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org

On Thu, May 28, 2015 at 01:52:35PM +0200, Dominik Dingel wrote:

Acked-by: Ralf Baechle <ralf@linux-mips.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
