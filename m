Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 23E4082F64
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 21:10:15 -0400 (EDT)
Received: by pasz6 with SMTP id z6so70227170pas.2
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 18:10:14 -0700 (PDT)
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com. [202.81.31.143])
        by mx.google.com with ESMTPS id xm6si17098773pab.219.2015.10.21.18.10.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Oct 2015 18:10:14 -0700 (PDT)
Received: from localhost
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <weiyang@linux.vnet.ibm.com>;
	Thu, 22 Oct 2015 11:10:10 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 871D32CE8052
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 12:10:06 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t9M19wMw51642498
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 12:10:06 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t9M19X9I029950
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 12:09:34 +1100
Date: Thu, 22 Oct 2015 09:09:16 +0800
From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/3] mm/slub: use get_order() instead of fls()
Message-ID: <20151022010916.GA2595@Richards-MacBook-Pro.local>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
References: <1445421066-10641-1-git-send-email-weiyang@linux.vnet.ibm.com>
 <1445421066-10641-3-git-send-email-weiyang@linux.vnet.ibm.com>
 <alpine.DEB.2.20.1510210918520.5611@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1510210918520.5611@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org

On Wed, Oct 21, 2015 at 09:19:09AM -0500, Christoph Lameter wrote:
>On Wed, 21 Oct 2015, Wei Yang wrote:
>
>> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
>> Pekka Enberg <penberg@kernel.org>
>
>Acked-by: ?
>

Oh, missed copy.

Reviewed-by: Pekka Enberg <penberg@kernel.org>

-- 
Richard Yang
Help you, Help me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
