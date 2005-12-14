Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id jBEGQj6k005583
	for <linux-mm@kvack.org>; Wed, 14 Dec 2005 11:26:45 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jBEGPsp9118722
	for <linux-mm@kvack.org>; Wed, 14 Dec 2005 09:25:54 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id jBEGQi86003066
	for <linux-mm@kvack.org>; Wed, 14 Dec 2005 09:26:44 -0700
Message-ID: <43A047C3.9060201@us.ibm.com>
Date: Wed, 14 Dec 2005 08:26:43 -0800
From: Matthew Dobson <colpatch@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 3/6] Slab Prep: get/return_object
References: <439FCECA.3060909@us.ibm.com> <439FD031.1040608@us.ibm.com> <84144f020512140019h1390c9eayf8b4b0dd03d8be1c@mail.gmail.com>
In-Reply-To: <84144f020512140019h1390c9eayf8b4b0dd03d8be1c@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-kernel@vger.kernel.org, andrea@suse.de, Sridhar Samudrala <sri@us.ibm.com>, pavel@suse.cz, Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Pekka Enberg wrote:
> Hi Matt,
> 
> On 12/14/05, Matthew Dobson <colpatch@us.ibm.com> wrote:
> 
>>Create 2 helper functions in mm/slab.c: get_object() and return_object().
>>These functions reduce some existing duplicated code in the slab allocator
>>and will be used when adding Critical Page Pool support to the slab allocator.
> 
> 
> May I suggest different naming, slab_get_obj and slab_put_obj ?
> 
>                                             Pekka

Sure.  Those sound much better than mine. :)

-Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
