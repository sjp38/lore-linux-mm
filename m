Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 691046B0031
	for <linux-mm@kvack.org>; Wed, 20 Nov 2013 01:58:53 -0500 (EST)
Received: by mail-pb0-f44.google.com with SMTP id rq2so3065789pbb.31
        for <linux-mm@kvack.org>; Tue, 19 Nov 2013 22:58:53 -0800 (PST)
Received: from psmtp.com ([74.125.245.134])
        by mx.google.com with SMTP id n8si13493543pax.160.2013.11.19.22.58.50
        for <linux-mm@kvack.org>;
        Tue, 19 Nov 2013 22:58:52 -0800 (PST)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <weiyang@linux.vnet.ibm.com>;
	Wed, 20 Nov 2013 12:28:45 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id B62EC3940057
	for <linux-mm@kvack.org>; Wed, 20 Nov 2013 12:28:42 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rAK6wb2n57999542
	for <linux-mm@kvack.org>; Wed, 20 Nov 2013 12:28:37 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rAK6wf3H016392
	for <linux-mm@kvack.org>; Wed, 20 Nov 2013 12:28:41 +0530
Date: Wed, 20 Nov 2013 14:58:40 +0800
From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/3] percpu: stop the loop when a cpu belongs to a new
 group
Message-ID: <20131120065840.GA10839@weiyang.vnet.ibm.com>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
References: <1382345893-6644-1-git-send-email-weiyang@linux.vnet.ibm.com>
 <20131027123008.GJ14934@mtj.dyndns.org>
 <20131028030055.GC15642@weiyang.vnet.ibm.com>
 <20131028113120.GB11541@mtj.dyndns.org>
 <20131028151746.GA7548@weiyang.vnet.ibm.com>
 <20131120030056.GA15273@weiyang.vnet.ibm.com>
 <20131120055121.GA13754@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131120055121.GA13754@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Nov 20, 2013 at 12:51:21AM -0500, Tejun Heo wrote:
>Hello,
>
>On Wed, Nov 20, 2013 at 11:00:56AM +0800, Wei Yang wrote:
>> What do you think about this one?
>> 
>> >
>> >From bd70498b9df47b25ff20054e24bb510c5430c0c3 Mon Sep 17 00:00:00 2001
>> >From: Wei Yang <weiyang@linux.vnet.ibm.com>
>> >Date: Thu, 10 Oct 2013 09:42:14 +0800
>> >Subject: [PATCH] percpu: optimize group assignment when cpu_distance_fn is
>> > NULL
>> >
>> >When cpu_distance_fn is NULL, all CPUs belongs to group 0. The original logic
>> >will continue to go through each CPU and its predecessor. cpu_distance_fn is
>> >always NULL when pcpu_build_alloc_info() is called from pcpu_page_first_chunk().
>> >
>> >By applying this patch, the time complexity will drop to O(n) form O(n^2) in
>> >case cpu_distance_fn is NULL.
>
>The test was put in the inner loop because the nesting was already too
>deep and cpu_distance_fn is unlikely to be NULL on machines where the
>number of CPUs is high enough to matter.  If that O(n^2) loop is gonna
>be a problem, it's gonna be a problem on large NUMA machines and we'll
>have to do something about it for cases where cpu_distance_fn exists
>anyway.

Tejun,

Yep, hope this will not bring some problem on a large NUMA machie when
cpu_distance_fn is not NULL.

>
>The patch is just extremely marginal.  Ah well... why not?  I'll apply
>it once -rc1 drops.
>
>Thanks.
>
>-- 
>tejun

-- 
Richard Yang
Help you, Help me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
