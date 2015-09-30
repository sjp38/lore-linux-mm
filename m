Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 593316B0038
	for <linux-mm@kvack.org>; Tue, 29 Sep 2015 22:24:13 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so23399838pab.3
        for <linux-mm@kvack.org>; Tue, 29 Sep 2015 19:24:13 -0700 (PDT)
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com. [202.81.31.142])
        by mx.google.com with ESMTPS id px2si22188518pbb.156.2015.09.29.19.24.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Tue, 29 Sep 2015 19:24:12 -0700 (PDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <weiyang@linux.vnet.ibm.com>;
	Wed, 30 Sep 2015 12:24:08 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 038512BB004D
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 12:24:05 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t8U2NuJV61079622
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 12:24:04 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t8U2NVG9010011
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 12:23:32 +1000
Date: Wed, 30 Sep 2015 10:23:14 +0800
From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] mm/slub: use get_order() instead of fls()
Message-ID: <20150930022314.GA4058@Richards-MacBook-Pro.local>
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

Thanks Pekka ~

-- 
Richard Yang
Help you, Help me

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
