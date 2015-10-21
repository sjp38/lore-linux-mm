Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 9B1EE6B0038
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 04:07:08 -0400 (EDT)
Received: by wikq8 with SMTP id q8so81018413wik.1
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 01:07:08 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s3si8465546wis.111.2015.10.21.01.07.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 21 Oct 2015 01:07:07 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm/slub: use get_order() instead of fls()
References: <1443488787-2232-1-git-send-email-weiyang@linux.vnet.ibm.com>
 <1443488787-2232-2-git-send-email-weiyang@linux.vnet.ibm.com>
 <560A46FC.8050205@iki.fi> <20151021074219.GA6931@Richards-MacBook-Pro.local>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <562747A8.8050307@suse.cz>
Date: Wed, 21 Oct 2015 10:07:04 +0200
MIME-Version: 1.0
In-Reply-To: <20151021074219.GA6931@Richards-MacBook-Pro.local>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <weiyang@linux.vnet.ibm.com>, Pekka Enberg <penberg@iki.fi>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, linux-mm@kvack.org

On 10/21/2015 09:42 AM, Wei Yang wrote:
> On Tue, Sep 29, 2015 at 11:08:28AM +0300, Pekka Enberg wrote:
>> On 09/29/2015 04:06 AM, Wei Yang wrote:
>>> get_order() is more easy to understand.
>>>
>>> This patch just replaces it.
>>>
>>> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
>>
>> Reviewed-by: Pekka Enberg <penberg@kernel.org>
>
> Is this patch accepted or not?
>
> I don't receive an "Apply" or "Accepted", neither see it in a git tree. Not
> sure if I missed something or the process is different as I know?

You should probably resend and include Andrew Morton in To/CC, instead 
of just linux-mm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
