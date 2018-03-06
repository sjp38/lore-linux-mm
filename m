Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 680366B0010
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 17:48:44 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id j21so135101wre.20
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 14:48:44 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id c22si1463164wme.230.2018.03.06.14.48.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Mar 2018 14:48:43 -0800 (PST)
Date: Tue, 6 Mar 2018 14:48:07 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v12 07/11] mm: Add address parameter to
 arch_validate_prot()
Message-Id: <20180306144807.30915bcffe6e640c3ad6279c@linux-foundation.org>
In-Reply-To: <349751cbd54fda6f4a223f941aa71bbfe7be77ce.1519227112.git.khalid.aziz@oracle.com>
References: <cover.1519227112.git.khalid.aziz@oracle.com>
	<349751cbd54fda6f4a223f941aa71bbfe7be77ce.1519227112.git.khalid.aziz@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, davem@davemloft.net, dave.hansen@linux.intel.com, bsingharora@gmail.com, nborisov@suse.com, aarcange@redhat.com, anthony.yznaga@oracle.com, mgorman@suse.de, linuxram@us.ibm.com, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com, jack@suse.cz, ross.zwisler@linux.intel.com, gregkh@linuxfoundation.org, tglx@linutronix.de, mhocko@suse.com, n-horiguchi@ah.jp.nec.com, jglisse@redhat.com, henry.willard@oracle.com, aneesh.kumar@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, Khalid Aziz <khalid@gonehiking.org>

On Wed, 21 Feb 2018 10:15:49 -0700 Khalid Aziz <khalid.aziz@oracle.com> wrote:

> A protection flag may not be valid across entire address space and
> hence arch_validate_prot() might need the address a protection bit is
> being set on to ensure it is a valid protection flag. For example, sparc
> processors support memory corruption detection (as part of ADI feature)
> flag on memory addresses mapped on to physical RAM but not on PFN mapped
> pages or addresses mapped on to devices. This patch adds address to the
> parameters being passed to arch_validate_prot() so protection bits can
> be validated in the relevant context.
> 
> Signed-off-by: Khalid Aziz <khalid.aziz@oracle.com>
> Cc: Khalid Aziz <khalid@gonehiking.org>
> Reviewed-by: Anthony Yznaga <anthony.yznaga@oracle.com>

Acked-by: Andrew Morton <akpm@linux-foundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
