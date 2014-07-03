Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 973B26B0035
	for <linux-mm@kvack.org>; Wed,  2 Jul 2014 22:23:36 -0400 (EDT)
Received: by mail-wg0-f51.google.com with SMTP id x12so11881334wgg.22
        for <linux-mm@kvack.org>; Wed, 02 Jul 2014 19:23:36 -0700 (PDT)
Received: from e28smtp04.in.ibm.com (e28smtp04.in.ibm.com. [122.248.162.4])
        by mx.google.com with ESMTPS id y20si17418700wie.93.2014.07.02.19.23.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 02 Jul 2014 19:23:35 -0700 (PDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <weiyang@linux.vnet.ibm.com>;
	Thu, 3 Jul 2014 07:53:31 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 34EED394003E
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 07:53:29 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s632Opp111010550
	for <linux-mm@kvack.org>; Thu, 3 Jul 2014 07:54:51 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s632NSff001279
	for <linux-mm@kvack.org>; Thu, 3 Jul 2014 07:53:28 +0530
Date: Thu, 3 Jul 2014 10:23:26 +0800
From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: mm: slub: invalid memory access in setup_object
Message-ID: <20140703022326.GA5174@richard>
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

The result of the simple test is the same. And my laptop works a whole day
with this patch.

Thanks

>
>And we still don't know why Sasha's kernel went oops.

-- 
Richard Yang
Help you, Help me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
