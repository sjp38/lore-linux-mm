Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5B2C36B0038
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 06:59:57 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 83so42827843pfx.1
        for <linux-mm@kvack.org>; Mon, 14 Nov 2016 03:59:57 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id u17si21945298pgo.250.2016.11.14.03.59.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Nov 2016 03:59:47 -0800 (PST)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH v6 4/4] of/fdt: mark hotpluggable memory
In-Reply-To: <1478562276-25539-5-git-send-email-arbab@linux.vnet.ibm.com>
References: <1478562276-25539-1-git-send-email-arbab@linux.vnet.ibm.com> <1478562276-25539-5-git-send-email-arbab@linux.vnet.ibm.com>
Date: Mon, 14 Nov 2016 22:59:43 +1100
Message-ID: <87bmxii85s.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Andrew Morton <akpm@linux-foundation.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, devicetree@vger.kernel.org, Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Stewart Smith <stewart@linux.vnet.ibm.com>, Alistair Popple <apopple@au1.ibm.com>, Balbir Singh <bsingharora@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org

Reza Arbab <arbab@linux.vnet.ibm.com> writes:

> When movable nodes are enabled, any node containing only hotpluggable
> memory is made movable at boot time.
>
> On x86, hotpluggable memory is discovered by parsing the ACPI SRAT,
> making corresponding calls to memblock_mark_hotplug().
>
> If we introduce a dt property to describe memory as hotpluggable,
> configs supporting early fdt may then also do this marking and use
> movable nodes.

So I'm not opposed to this, but it is a little vague.

What does the "hotpluggable" property really mean?

Is it just a hint to the operating system? (which may or may not be
Linux).

Or is it a direction, "this memory must be able to be hotunplugged"?

I think you're intending the former, ie. a hint, which is probably OK.
But it needs to be documented clearly.

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
