Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 808CD6B0069
	for <linux-mm@kvack.org>; Mon, 19 Sep 2016 06:11:27 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id c84so200190445pfj.2
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 03:11:27 -0700 (PDT)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id f6si28310474pay.257.2016.09.19.03.11.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Sep 2016 03:11:26 -0700 (PDT)
Received: by mail-pa0-x22e.google.com with SMTP id id6so47297546pad.3
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 03:11:26 -0700 (PDT)
Subject: Re: [PATCH v2 1/3] drivers/of: recognize status property of dt memory
 nodes
References: <1473883618-14998-1-git-send-email-arbab@linux.vnet.ibm.com>
 <1473883618-14998-2-git-send-email-arbab@linux.vnet.ibm.com>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <bdbcc833-1a56-69aa-b433-ec4ce685d3cd@gmail.com>
Date: Mon, 19 Sep 2016 20:11:39 +1000
MIME-Version: 1.0
In-Reply-To: <1473883618-14998-2-git-send-email-arbab@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Reza Arbab <arbab@linux.vnet.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Stewart Smith <stewart@linux.vnet.ibm.com>, Alistair Popple <apopple@au1.ibm.com>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, devicetree@vger.kernel.org, linux-mm@kvack.org



On 15/09/16 06:06, Reza Arbab wrote:
> Respect the standard dt "status" property when scanning memory nodes in
> early_init_dt_scan_memory(), so that if the property is present and not
> "okay", no memory will be added.
> 
> The use case at hand is accelerator or device memory, which may be
> unusable until post-boot initialization of the memory link. Such a node
> can be described in the dt as any other, given its status is "disabled".
> Per the device tree specification,
> 
> "disabled"
> 	Indicates that the device is not presently operational, but it
> 	might become operational in the future (for example, something
> 	is not plugged in, or switched off).
> 
> Once such memory is made operational, it can then be hotplugged.
> 
> Signed-off-by: Reza Arbab <arbab@linux.vnet.ibm.com>

Makes sense, so basically a /memory@  with missing status or status = "okay"
are added, others are skipped. No memblocks corresponding to those nodes
are created either.

Balbir Singh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
