Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id 1FDF76B0031
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 22:06:56 -0400 (EDT)
Received: by mail-lb0-f178.google.com with SMTP id 10so7493746lbg.37
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 19:06:55 -0700 (PDT)
Received: from e28smtp07.in.ibm.com (e28smtp07.in.ibm.com. [122.248.162.7])
        by mx.google.com with ESMTPS id kr7si21179784lac.39.2014.07.01.19.06.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 01 Jul 2014 19:06:54 -0700 (PDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <weiyang@linux.vnet.ibm.com>;
	Wed, 2 Jul 2014 07:36:50 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 838A6E0044
	for <linux-mm@kvack.org>; Wed,  2 Jul 2014 07:38:07 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s622888j62980298
	for <linux-mm@kvack.org>; Wed, 2 Jul 2014 07:38:09 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s6226l43022774
	for <linux-mm@kvack.org>; Wed, 2 Jul 2014 07:36:47 +0530
Date: Wed, 2 Jul 2014 10:06:46 +0800
From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: mm: slub: invalid memory access in setup_object
Message-ID: <20140702020646.GB6961@richard>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
References: <53AAFDF7.2010607@oracle.com>
 <alpine.DEB.2.11.1406251228130.29216@gentwo.org>
 <alpine.DEB.2.02.1406301500410.13545@chino.kir.corp.google.com>
 <alpine.DEB.2.11.1407010956470.5353@gentwo.org>
 <20140701144947.5ce3f93729759d8f38d7813a@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140701144947.5ce3f93729759d8f38d7813a@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@gentwo.org>, David Rientjes <rientjes@google.com>, Sasha Levin <sasha.levin@oracle.com>, Wei Yang <weiyang@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>

On Tue, Jul 01, 2014 at 02:49:47PM -0700, Andrew Morton wrote:
>On Tue, 1 Jul 2014 09:58:52 -0500 (CDT) Christoph Lameter <cl@gentwo.org> wrote:
>
>> On Mon, 30 Jun 2014, David Rientjes wrote:
>> 
>> > It's not at all clear to me that that patch is correct.  Wei?
>> 
>> Looks ok to me. But I do not like the convoluted code in new_slab() which
>> Wei's patch does not make easier to read. Makes it difficult for the
>> reader to see whats going on.
>> 
>> Lets drop the use of the variable named "last".
>> 
>> 
>> Subject: slub: Only call setup_object once for each object
>> 
>> Modify the logic for object initialization to be less convoluted
>> and initialize an object only once.
>> 
>
>Well, um.  Wei's changelog was much better:
>
>: When a kmem_cache is created with ctor, each object in the kmem_cache will
>: be initialized before use.  In the slub implementation, the first object
>: will be initialized twice.
>: 
>: This patch avoids the duplication of initialization of the first object.
>: 
>: Fixes commit 7656c72b5a63: ("SLUB: add macros for scanning objects in a
>: slab").
>
>I can copy that text over and add the reported-by etc (ho hum) but I
>have a tiny feeling that this patch hasn't been rigorously tested? 
>Perhaps someone (Wei?) can do that?

Ok, I will apply this one and give a shot.

>
>And we still don't know why Sasha's kernel went oops.

Yep, if there is some procedure to reproduce it, I'd like to do it at my side.

-- 
Richard Yang
Help you, Help me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
