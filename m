Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 276656B0253
	for <linux-mm@kvack.org>; Thu, 11 Aug 2016 21:43:41 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 63so23448735pfx.0
        for <linux-mm@kvack.org>; Thu, 11 Aug 2016 18:43:41 -0700 (PDT)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id c83si5990080pfd.268.2016.08.11.18.43.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Aug 2016 18:43:40 -0700 (PDT)
Received: by mail-pa0-x244.google.com with SMTP id vy10so607469pac.0
        for <linux-mm@kvack.org>; Thu, 11 Aug 2016 18:43:40 -0700 (PDT)
Subject: Re: [PATCH 2/4] powerpc/mm: create numa nodes for hotplug memory
References: <1470680843-28702-1-git-send-email-arbab@linux.vnet.ibm.com>
 <1470680843-28702-3-git-send-email-arbab@linux.vnet.ibm.com>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <7ddeb774-1eb7-5529-912c-eb767b8623ce@gmail.com>
Date: Fri, 12 Aug 2016 11:43:32 +1000
MIME-Version: 1.0
In-Reply-To: <1470680843-28702-3-git-send-email-arbab@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>, Rob Herring <robh+dt@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Jonathan Corbet <corbet@lwn.net>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, devicetree@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 09/08/16 04:27, Reza Arbab wrote:
> When scanning the device tree to initialize the system NUMA topology,
> process dt elements with compatible id "ibm,hotplug-aperture" to create
> memoryless numa nodes.
> 
> These nodes will be filled when hotplug occurs within the associated
> address range.
> 
> Signed-off-by: Reza Arbab <arbab@linux.vnet.ibm.com>
> ---

Looks good to me

Acked-by: Balbir Singh <bsingharora@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
