Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 649146B0038
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 18:20:48 -0500 (EST)
Received: by mail-pa0-f70.google.com with SMTP id rf5so101045948pab.3
        for <linux-mm@kvack.org>; Mon, 14 Nov 2016 15:20:48 -0800 (PST)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id xn10si20060757pab.93.2016.11.14.15.20.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Nov 2016 15:20:47 -0800 (PST)
Received: by mail-pg0-x244.google.com with SMTP id e9so9717423pgc.1
        for <linux-mm@kvack.org>; Mon, 14 Nov 2016 15:20:47 -0800 (PST)
Subject: Re: [PATCH v7 4/5] of/fdt: mark hotpluggable memory
References: <1479160961-25840-1-git-send-email-arbab@linux.vnet.ibm.com>
 <1479160961-25840-5-git-send-email-arbab@linux.vnet.ibm.com>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <1723a465-fdf6-c12c-afb3-b486fc3a05ae@gmail.com>
Date: Tue, 15 Nov 2016 10:20:39 +1100
MIME-Version: 1.0
In-Reply-To: <1479160961-25840-5-git-send-email-arbab@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Andrew Morton <akpm@linux-foundation.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, devicetree@vger.kernel.org, Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Stewart Smith <stewart@linux.vnet.ibm.com>, Alistair Popple <apopple@au1.ibm.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org



On 15/11/16 09:02, Reza Arbab wrote:
> When movable nodes are enabled, any node containing only hotpluggable
> memory is made movable at boot time.
> 
> On x86, hotpluggable memory is discovered by parsing the ACPI SRAT,
> making corresponding calls to memblock_mark_hotplug().
> 
> If we introduce a dt property to describe memory as hotpluggable,
> configs supporting early fdt may then also do this marking and use
> movable nodes.
> 
> Signed-off-by: Reza Arbab <arbab@linux.vnet.ibm.com>
> Tested-by: Balbir Singh <bsingharora@gmail.com>

Also

Acked-by: Balbir Singh <bsingharora@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
