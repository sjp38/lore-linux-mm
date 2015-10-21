Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 855256B0254
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 04:10:07 -0400 (EDT)
Received: by pacfv9 with SMTP id fv9so49855409pac.3
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 01:10:07 -0700 (PDT)
Received: from e28smtp03.in.ibm.com (e28smtp03.in.ibm.com. [122.248.162.3])
        by mx.google.com with ESMTPS id ae3si11553748pad.156.2015.10.21.01.10.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Oct 2015 01:10:06 -0700 (PDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <weiyang@linux.vnet.ibm.com>;
	Wed, 21 Oct 2015 13:40:03 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id EC4361258062
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 13:39:49 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t9L89fsv27525172
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 13:39:42 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t9L89cW5017713
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 13:39:41 +0530
Date: Wed, 21 Oct 2015 16:09:38 +0800
From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] mm/slub: use get_order() instead of fls()
Message-ID: <20151021080938.GA8207@richards-mbp.cn.ibm.com>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
References: <1443488787-2232-1-git-send-email-weiyang@linux.vnet.ibm.com>
 <1443488787-2232-2-git-send-email-weiyang@linux.vnet.ibm.com>
 <560A46FC.8050205@iki.fi>
 <20151021074219.GA6931@Richards-MacBook-Pro.local>
 <562747A8.8050307@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <562747A8.8050307@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>, Pekka Enberg <penberg@iki.fi>, cl@linux.com, penberg@kernel.org, rientjes@google.com, linux-mm@kvack.org

On Wed, Oct 21, 2015 at 10:07:04AM +0200, Vlastimil Babka wrote:
>On 10/21/2015 09:42 AM, Wei Yang wrote:
>>On Tue, Sep 29, 2015 at 11:08:28AM +0300, Pekka Enberg wrote:
>>>On 09/29/2015 04:06 AM, Wei Yang wrote:
>>>>get_order() is more easy to understand.
>>>>
>>>>This patch just replaces it.
>>>>
>>>>Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
>>>
>>>Reviewed-by: Pekka Enberg <penberg@kernel.org>
>>
>>Is this patch accepted or not?
>>
>>I don't receive an "Apply" or "Accepted", neither see it in a git tree. Not
>>sure if I missed something or the process is different as I know?
>
>You should probably resend and include Andrew Morton in To/CC, instead of
>just linux-mm.

Oh, got it.

Thanks

-- 
Richard Yang
Help you, Help me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
