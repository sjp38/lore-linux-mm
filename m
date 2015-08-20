Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id D7C426B0038
	for <linux-mm@kvack.org>; Thu, 20 Aug 2015 03:44:40 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so28382235wic.1
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 00:44:40 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fm10si6894382wjc.203.2015.08.20.00.44.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 20 Aug 2015 00:44:39 -0700 (PDT)
Subject: Re: [PATCH V2] mm:memory hot-add: memory can not been added to
 movable zone
References: <1440055685-6083-1-git-send-email-liuchangsheng@inspur.com>
 <55D584C7.7060101@suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55D58566.4040709@suse.cz>
Date: Thu, 20 Aug 2015 09:44:38 +0200
MIME-Version: 1.0
In-Reply-To: <55D584C7.7060101@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Changsheng Liu <liuchangsheng@inspur.com>, akpm@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, yanxiaofeng@inspur.com, fandd@inspur.com, Changsheng Liu <liuchangcheng@inspur.com>

On 08/20/2015 09:41 AM, Vlastimil Babka wrote:
> want to hot-remove and don't want movable zones (which limit what kind
> of allocations are possible), is there a way to prevent memory being
> movable after your patch?

Oh, and not enabling CONFIG_MOVABLE_NODE is not sufficient here IMHO, as 
users might want to use a distro kernel that has the option enabled, but 
still not want to use it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
