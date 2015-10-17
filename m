Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f54.google.com (mail-vk0-f54.google.com [209.85.213.54])
	by kanga.kvack.org (Postfix) with ESMTP id F1F0482F64
	for <linux-mm@kvack.org>; Sat, 17 Oct 2015 09:25:04 -0400 (EDT)
Received: by vkha6 with SMTP id a6so82758826vkh.2
        for <linux-mm@kvack.org>; Sat, 17 Oct 2015 06:25:04 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id 80si8215772vkc.107.2015.10.17.06.25.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 17 Oct 2015 06:25:04 -0700 (PDT)
Message-ID: <1445088290.24309.60.camel@kernel.crashing.org>
Subject: Re: [PATCH 3/3] powerpc/mm: Add page soft dirty tracking
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Sat, 17 Oct 2015 18:54:50 +0530
In-Reply-To: <87a8rhit61.fsf@linux.vnet.ibm.com>
References: <cover.1444995096.git.ldufour@linux.vnet.ibm.com>
	 <b1ae177b872e901b01a4071c92c4db23a3323be3.1444995096.git.ldufour@linux.vnet.ibm.com>
	 <87a8rhit61.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Laurent Dufour <ldufour@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, xemul@parallels.com, linuxppc-dev@lists.ozlabs.org, mpe@ellerman.id.au, paulus@samba.org
Cc: criu@openvz.org

On Sat, 2015-10-17 at 17:49 +0530, Aneesh Kumar K.V wrote:
> This will break after
> https://lists.ozlabs.org/pipermail/linuxppc-dev/2015-October/135298.html
> 
> 
> A good option is to drop this patch from the series and let Andrew take
> the first two patches. You can send an updated version of patch 3 against
> linux-powerpc tree once Michael pulls that series to his tree. 

Or not ... I'm not comfortable with your series just yet for the reasons
I mentioned earlier (basically doubling the memory footprint of the page
tables).

They are already too big.

Cheers,
Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
