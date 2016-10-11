Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 977EE6B0038
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 08:26:24 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id gg9so14080908pac.6
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 05:26:24 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id n17si681838pgd.291.2016.10.11.05.26.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Oct 2016 05:26:23 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id s8so653998pfj.2
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 05:26:23 -0700 (PDT)
Subject: Re: [PATCH v4 4/5] mm: make processing of movable_node arch-specific
References: <1475778995-1420-1-git-send-email-arbab@linux.vnet.ibm.com>
 <1475778995-1420-5-git-send-email-arbab@linux.vnet.ibm.com>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <235f2d20-cf84-08df-1fb4-08ee258fdc52@gmail.com>
Date: Tue, 11 Oct 2016 23:26:19 +1100
MIME-Version: 1.0
In-Reply-To: <1475778995-1420-5-git-send-email-arbab@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Stewart Smith <stewart@linux.vnet.ibm.com>, Alistair Popple <apopple@au1.ibm.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, devicetree@vger.kernel.org, linux-mm@kvack.org



On 07/10/16 05:36, Reza Arbab wrote:
> Currently, CONFIG_MOVABLE_NODE depends on X86_64. In preparation to
> enable it for other arches, we need to factor a detail which is unique
> to x86 out of the generic mm code.
> 
> Specifically, as documented in kernel-parameters.txt, the use of
> "movable_node" should remain restricted to x86:
> 
> movable_node    [KNL,X86] Boot-time switch to enable the effects
>                 of CONFIG_MOVABLE_NODE=y. See mm/Kconfig for details.
> 
> This option tells x86 to find movable nodes identified by the ACPI SRAT.
> On other arches, it would have no benefit, only the undesired side
> effect of setting bottom-up memblock allocation.
> 
> Since #ifdef CONFIG_MOVABLE_NODE will no longer be enough to restrict
> this option to x86, move it to an arch-specific compilation unit
> instead.
> 
> Signed-off-by: Reza Arbab <arbab@linux.vnet.ibm.com>

Acked-by: Balbir Singh <bsingharora@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
