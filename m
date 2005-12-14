Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id jBEGUT4u025811
	for <linux-mm@kvack.org>; Wed, 14 Dec 2005 11:30:29 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jBEGW8GC037438
	for <linux-mm@kvack.org>; Wed, 14 Dec 2005 09:32:08 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id jBEGUSj2015042
	for <linux-mm@kvack.org>; Wed, 14 Dec 2005 09:30:28 -0700
Message-ID: <43A048A1.6050705@us.ibm.com>
Date: Wed, 14 Dec 2005 08:30:25 -0800
From: Matthew Dobson <colpatch@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 4/6] Slab Prep: slab_destruct()
References: <439FCECA.3060909@us.ibm.com> <439FD08E.3020401@us.ibm.com> <84144f020512140037k5d687c66x35e3e29519764fb7@mail.gmail.com>
In-Reply-To: <84144f020512140037k5d687c66x35e3e29519764fb7@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-kernel@vger.kernel.org, andrea@suse.de, Sridhar Samudrala <sri@us.ibm.com>, pavel@suse.cz, Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Pekka Enberg wrote:
> On 12/14/05, Matthew Dobson <colpatch@us.ibm.com> wrote:
> 
>>Create a helper function for slab_destroy() called slab_destruct().  Remove
>>some ifdefs inside functions and generally make the slab destroying code
>>more readable prior to slab support for the Critical Page Pool.
> 
> 
> Looks good. How about calling it slab_destroy_objs instead?
> 
>                           Pekka

I called it slab_destruct() because it's the part of the old slab_destroy()
that called the slab destructor to destroy the slab's objects.
slab_destroy_objs() is reasonable as well, though, and I can live with that.

Thanks!

-Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
