Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 5422A6B0098
	for <linux-mm@kvack.org>; Thu, 17 Oct 2013 12:12:36 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id w10so2988144pde.23
        for <linux-mm@kvack.org>; Thu, 17 Oct 2013 09:12:36 -0700 (PDT)
Message-ID: <52600C49.7070306@sr71.net>
Date: Thu, 17 Oct 2013 09:11:53 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/8] mm: pcp: rename percpu pageset functions
References: <20131015203536.1475C2BE@viggo.jf.intel.com> <20131015203538.35606A47@viggo.jf.intel.com> <alpine.DEB.2.02.1310161831090.15575@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1310161831090.15575@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Cody P Schafer <cody@linux.vnet.ibm.com>, Andi Kleen <ak@linux.intel.com>, cl@gentwo.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>

On 10/16/2013 06:32 PM, David Rientjes wrote:
>> > +static void pageset_setup_from_batch_size(struct per_cpu_pageset *p,
>> > +					unsigned long batch)
>> >  {
>> > -	pageset_update(&p->pcp, 6 * batch, max(1UL, 1 * batch));
>> > +	unsigned long high;
>> > +	high = 6 * batch;
>> > +	if (!batch)
>> > +		batch = 1;
> high = 6 * batch should be here?

Ahh, nice catch, thanks.  I'll fix that up and resend.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
