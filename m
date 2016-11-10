Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 625516B026D
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 19:56:25 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id a8so74934092pfg.0
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 16:56:25 -0800 (PST)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id w5si1874278pgj.87.2016.11.09.16.56.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Nov 2016 16:56:24 -0800 (PST)
Received: by mail-pf0-x242.google.com with SMTP id n85so1976532pfi.3
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 16:56:24 -0800 (PST)
Subject: Re: [PATCH v6 4/4] of/fdt: mark hotpluggable memory
References: <1478562276-25539-1-git-send-email-arbab@linux.vnet.ibm.com>
 <1478562276-25539-5-git-send-email-arbab@linux.vnet.ibm.com>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <aea94234-b3d8-1484-d3ab-39e562d7901d@gmail.com>
Date: Thu, 10 Nov 2016 11:56:02 +1100
MIME-Version: 1.0
In-Reply-To: <1478562276-25539-5-git-send-email-arbab@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Andrew Morton <akpm@linux-foundation.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, devicetree@vger.kernel.org, Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Stewart Smith <stewart@linux.vnet.ibm.com>, Alistair Popple <apopple@au1.ibm.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org



On 08/11/16 10:44, Reza Arbab wrote:
> When movable nodes are enabled, any node containing only hotpluggable
> memory is made movable at boot time.
> 
> On x86, hotpluggable memory is discovered by parsing the ACPI SRAT,
> making corresponding calls to memblock_mark_hotplug().
> 
> If we introduce a dt property to describe memory as hotpluggable,
> configs supporting early fdt may then also do this marking and use
> movable nodes.

This looks much better, like the other comments pointed out

We need documentation around the changes. One quick question

Have you tested this across all combinations of skiboot/kexec/SLOF boots?

Balbir Singh.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
