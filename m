Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 3583D6B0038
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 03:42:33 -0400 (EDT)
Received: by pacfv9 with SMTP id fv9so49115070pac.3
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 00:42:32 -0700 (PDT)
Received: from e28smtp06.in.ibm.com (e28smtp06.in.ibm.com. [122.248.162.6])
        by mx.google.com with ESMTPS id pq10si11422492pbb.97.2015.10.21.00.42.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Oct 2015 00:42:32 -0700 (PDT)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <weiyang@linux.vnet.ibm.com>;
	Wed, 21 Oct 2015 13:12:28 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 2EA8B125805D
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 13:12:12 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay01.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t9L7gL0T10748324
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 13:12:21 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t9L7gKnX022711
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 13:12:20 +0530
Date: Wed, 21 Oct 2015 15:42:19 +0800
From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] mm/slub: use get_order() instead of fls()
Message-ID: <20151021074219.GA6931@Richards-MacBook-Pro.local>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
References: <1443488787-2232-1-git-send-email-weiyang@linux.vnet.ibm.com>
 <1443488787-2232-2-git-send-email-weiyang@linux.vnet.ibm.com>
 <560A46FC.8050205@iki.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <560A46FC.8050205@iki.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@iki.fi>
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>, cl@linux.com, penberg@kernel.org, rientjes@google.com, linux-mm@kvack.org

On Tue, Sep 29, 2015 at 11:08:28AM +0300, Pekka Enberg wrote:
>On 09/29/2015 04:06 AM, Wei Yang wrote:
>>get_order() is more easy to understand.
>>
>>This patch just replaces it.
>>
>>Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
>
>Reviewed-by: Pekka Enberg <penberg@kernel.org>

Is this patch accepted or not?

I don't receive an "Apply" or "Accepted", neither see it in a git tree. Not
sure if I missed something or the process is different as I know?

-- 
Richard Yang
Help you, Help me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
