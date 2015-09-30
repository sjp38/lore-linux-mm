Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 2A9EE82F69
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 19:43:22 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so55559103pac.2
        for <linux-mm@kvack.org>; Wed, 30 Sep 2015 16:43:21 -0700 (PDT)
Received: from e28smtp08.in.ibm.com (e28smtp08.in.ibm.com. [122.248.162.8])
        by mx.google.com with ESMTPS id pp2si4234274pbb.235.2015.09.30.16.43.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Wed, 30 Sep 2015 16:43:21 -0700 (PDT)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <weiyang@linux.vnet.ibm.com>;
	Thu, 1 Oct 2015 05:13:18 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 956013940061
	for <linux-mm@kvack.org>; Thu,  1 Oct 2015 05:13:14 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t8UNhDHW19268000
	for <linux-mm@kvack.org>; Thu, 1 Oct 2015 05:13:13 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t8UNhDA1009964
	for <linux-mm@kvack.org>; Thu, 1 Oct 2015 05:13:13 +0530
Date: Thu, 1 Oct 2015 07:43:09 +0800
From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/slub: calculate start order with reserved in
 consideration
Message-ID: <20150930234309.GA1225@Richards-MBP.lan>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
References: <1443580202-4311-1-git-send-email-weiyang@linux.vnet.ibm.com>
 <alpine.DEB.2.20.1509300852500.16540@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1509300852500.16540@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>, penberg@kernel.org, rientjes@google.com, linux-mm@kvack.org

On Wed, Sep 30, 2015 at 08:53:03AM -0500, Christoph Lameter wrote:
>On Wed, 30 Sep 2015, Wei Yang wrote:
>
>> In function slub_order(), the order starts from max(min_order,
>> get_order(min_objects * size)). When (min_objects * size) has different
>> order with (min_objects * size + reserved), it will skip this order by the
>> check in the loop.
>
>Acked-by: Christoph Lameter <cl@linux.com>

Christoph,

Glad to see your Ack.
Thanks :-)

BTW, do you have any comment for this patch "mm/slub: correct the comment in
calculate_order()"? I hope my understanding is correct.

-- 
Richard Yang
Help you, Help me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
