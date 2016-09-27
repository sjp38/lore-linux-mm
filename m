Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id CE6A96B028C
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 20:19:32 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 21so419385336pfy.3
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 17:19:32 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d132si27519674pfg.218.2016.09.26.17.19.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Sep 2016 17:19:32 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8R0IsqU112036
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 20:19:31 -0400
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
	by mx0a-001b2d01.pphosted.com with ESMTP id 25q5ms62pr-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 20:19:31 -0400
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Mon, 26 Sep 2016 18:19:30 -0600
Date: Mon, 26 Sep 2016 19:19:19 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 5/5] mm: enable CONFIG_MOVABLE_NODE on powerpc
References: <1474828616-16608-1-git-send-email-arbab@linux.vnet.ibm.com>
 <1474828616-16608-6-git-send-email-arbab@linux.vnet.ibm.com>
 <1474924541.2857.258.camel@kernel.crashing.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <1474924541.2857.258.camel@kernel.crashing.org>
Message-Id: <20160927001919.sriijnhnu3c2jkck@arbab-laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Stewart Smith <stewart@linux.vnet.ibm.com>, Alistair Popple <apopple@au1.ibm.com>, Balbir Singh <bsingharora@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, devicetree@vger.kernel.org, linux-mm@kvack.org

On Tue, Sep 27, 2016 at 07:15:41AM +1000, Benjamin Herrenschmidt wrote:
>What is that business with a command line argument ? Do that mean that
>we'll need some magic command line argument to properly handle LPC memory
>on CAPI devices or GPUs ? If yes that's bad ... kernel arguments should
>be a last resort.

Well, movable_node is just a boolean, meaning "allow nodes which contain 
only movable memory". It's _not_ like "movable_node=10,13-15,17", if 
that's what you were thinking.

>We should have all the information we need from the device-tree.
>
>Note also that we shouldn't need to create those nodes at boot time,
>we need to add the ability to create the whole thing at runtime, we may know
>that there's an NPU with an LPC window in the system but we won't know if it's
>used until it is and for CAPI we just simply don't know until some PCI device
>gets turned into CAPI mode and starts claiming LPC memory...

Yes, this is what is planned for, if I'm understanding you correctly.

In the dt, the PCI device node has a phandle pointing to the memory 
node. The memory node describes the window into which we can hotplug at 
runtime.

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
