Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 031246B0069
	for <linux-mm@kvack.org>; Sat, 22 Oct 2016 21:51:18 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id d128so13612048wmf.2
        for <linux-mm@kvack.org>; Sat, 22 Oct 2016 18:51:17 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id t14si5357623wme.97.2016.10.22.18.51.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 22 Oct 2016 18:51:16 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9N1mp0F064823
	for <linux-mm@kvack.org>; Sat, 22 Oct 2016 21:51:15 -0400
Received: from e18.ny.us.ibm.com (e18.ny.us.ibm.com [129.33.205.208])
	by mx0b-001b2d01.pphosted.com with ESMTP id 26891yuqv9-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 22 Oct 2016 21:51:15 -0400
Received: from localhost
	by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Sat, 22 Oct 2016 21:51:14 -0400
Date: Sat, 22 Oct 2016 20:51:08 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 2/5] drivers/of: do not add memory for unavailable
 nodes
References: <1475778995-1420-1-git-send-email-arbab@linux.vnet.ibm.com>
 <1475778995-1420-3-git-send-email-arbab@linux.vnet.ibm.com>
 <2344394.NlaWgtFOqB@new-mexico>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <2344394.NlaWgtFOqB@new-mexico>
Message-Id: <20161023015107.527l4fvnh2nrup5u@arbab-vm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alistair Popple <apopple@au1.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>
Cc: linuxppc-dev@lists.ozlabs.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Stewart Smith <stewart@linux.vnet.ibm.com>, devicetree@vger.kernel.org, linux-kernel@vger.kernel.org, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>

Hi Alistair,

On Fri, Oct 21, 2016 at 05:22:54PM +1100, Alistair Popple wrote:
>From what I can tell it seems that kernels without this patch will try 
>and use this memory even if it is marked in the device-tree as 
>status="disabled" which could lead to problems for older kernels when 
>we start exporting this property from firmware.
>
>Arguably this might not be such a problem in practice as we probably 
>don't have many (if any) existing kernels that will boot on hardware 
>exporting these properties.

Yes, I think you've got it right.

>However given this patch seems fairly independent perhaps it is worth 
>sending as a separate fix if it is not going to make it into this 
>release?

Michael,

If this set as a whole is going to miss the release, would it be helpful 
for me to resend 1/5 and 2/5 as a separate set? They are the minimum 
needed to prevent the possible forward compatibility issue Alistair 
describes.

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
