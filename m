Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id BF2126B0038
	for <linux-mm@kvack.org>; Mon,  3 Oct 2016 20:48:47 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id u84so136192221pfj.1
        for <linux-mm@kvack.org>; Mon, 03 Oct 2016 17:48:47 -0700 (PDT)
Received: from mail-pf0-x22e.google.com (mail-pf0-x22e.google.com. [2607:f8b0:400e:c00::22e])
        by mx.google.com with ESMTPS id ts1si791150pab.247.2016.10.03.17.48.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Oct 2016 17:48:47 -0700 (PDT)
Received: by mail-pf0-x22e.google.com with SMTP id i85so17862057pfa.3
        for <linux-mm@kvack.org>; Mon, 03 Oct 2016 17:48:46 -0700 (PDT)
Subject: Re: [PATCH v3 4/5] powerpc/mm: restore top-down allocation when using
 movable_node
References: <1474828616-16608-1-git-send-email-arbab@linux.vnet.ibm.com>
 <1474828616-16608-5-git-send-email-arbab@linux.vnet.ibm.com>
 <1474924351.2857.255.camel@kernel.crashing.org>
 <20160927001413.o72fqpfsnsxpu5qq@arbab-laptop>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <e161a34e-4e58-42f5-49ed-3e7913189eb9@gmail.com>
Date: Tue, 4 Oct 2016 11:48:30 +1100
MIME-Version: 1.0
In-Reply-To: <20160927001413.o72fqpfsnsxpu5qq@arbab-laptop>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Stewart Smith <stewart@linux.vnet.ibm.com>, Alistair Popple <apopple@au1.ibm.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, devicetree@vger.kernel.org, linux-mm@kvack.org



On 27/09/16 10:14, Reza Arbab wrote:
> On Tue, Sep 27, 2016 at 07:12:31AM +1000, Benjamin Herrenschmidt wrote:
>> In any case, if the memory hasn't been hotplug, this shouldn't be necessary as we shouldn't be considering it for allocation.
> 
> Right. To be clear, the background info I put in the commit log refers to x86, where the SRAT can describe movable nodes which exist at boot.  They're trying to avoid allocations from those nodes before they've been identified.
> 
> On power, movable nodes can only exist via hotplug, so that scenario can't happen. We can immediately go back to top-down allocation. That is the missing call being added in the patch.
> 

Can we fix cmdline_parse_movable_node() to do the right thing? I suspect that
code is heavily x86 only in the sense that no other arch needs it.

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
