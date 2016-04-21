Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id AE2D96B028F
	for <linux-mm@kvack.org>; Thu, 21 Apr 2016 00:16:00 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id vv3so93211380pab.2
        for <linux-mm@kvack.org>; Wed, 20 Apr 2016 21:16:00 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id k86si21618237pfj.248.2016.04.20.21.15.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Apr 2016 21:15:59 -0700 (PDT)
Received: by mail-pa0-x230.google.com with SMTP id zm5so24705126pac.0
        for <linux-mm@kvack.org>; Wed, 20 Apr 2016 21:15:59 -0700 (PDT)
Subject: Re: [PATCH] powerpc/mm: Always use STRICT_MM_TYPECHECKS
References: <1461209879-15044-1-git-send-email-mpe@ellerman.id.au>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <571853FA.5080901@gmail.com>
Date: Thu, 21 Apr 2016 14:15:54 +1000
MIME-Version: 1.0
In-Reply-To: <1461209879-15044-1-git-send-email-mpe@ellerman.id.au>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@ozlabs.org
Cc: Paul Mackerras <paulus@samba.org>, aneesh.kumar@linux.vnet.ibm.com, linux-mm@kvack.org



On 21/04/16 13:37, Michael Ellerman wrote:
> Testing done by Paul Mackerras has shown that with a modern compiler
> there is no negative effect on code generation from enabling
> STRICT_MM_TYPECHECKS.
> 
> So remove the option, and always use the strict type definitions.
> 

Should we wait for Aneesh's patches before merging this in. I like the reduction
in the definition of page level metadata so for that

Acked-by: Balbir Singh <bsingharora@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
