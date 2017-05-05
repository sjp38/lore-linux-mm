Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8CC0C6B0038
	for <linux-mm@kvack.org>; Fri,  5 May 2017 11:33:46 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id p8so2670078uaa.4
        for <linux-mm@kvack.org>; Fri, 05 May 2017 08:33:46 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id q132si2623080vkd.146.2017.05.05.08.33.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 May 2017 08:33:45 -0700 (PDT)
Subject: Re: [PATCH v3 4/4] mm: Adaptive hash table scaling
References: <1488432825-92126-1-git-send-email-pasha.tatashin@oracle.com>
 <1488432825-92126-5-git-send-email-pasha.tatashin@oracle.com>
 <20170303153247.f16a31c95404c02a8f3e2c5f@linux-foundation.org>
 <20170426201126.GA32407@dhcp22.suse.cz>
 <40f72efa-3928-b3c6-acca-0740f1a15ba4@oracle.com>
 <429c8506-c498-0599-4258-7bac947fe29c@oracle.com>
 <20170505133029.GC31461@dhcp22.suse.cz>
From: Pasha Tatashin <pasha.tatashin@oracle.com>
Message-ID: <e7c61dec-9d57-957b-7ff5-8247fa51eafb@oracle.com>
Date: Fri, 5 May 2017 11:33:36 -0400
MIME-Version: 1.0
In-Reply-To: <20170505133029.GC31461@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-fsdevel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>



On 05/05/2017 09:30 AM, Michal Hocko wrote:
> On Thu 04-05-17 14:28:51, Pasha Tatashin wrote:
>> BTW, I am OK with your patch on top of this "Adaptive hash table" patch, but
>> I do not know what high_limit should be from where HASH_ADAPT will kick in.
>> 128M sound reasonable to you?
> 
> For simplicity I would just use it unconditionally when no high_limit is
> set. What would be the problem with that?

Sure, that sounds good.

  If you look at current users
> (and there no new users emerging too often) then most of them just want
> _some_ scaling. The original one obviously doesn't scale with large
> machines. Are you OK to fold my change to your patch or you want me to
> send a separate patch? AFAIK Andrew hasn't posted this patch to Linus
> yet.
> 

I would like a separate patch because mine has soaked in mm tree for a 
while now.

Thank you,
Pasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
