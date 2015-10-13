Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 0ADBE6B0253
	for <linux-mm@kvack.org>; Tue, 13 Oct 2015 10:55:56 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so192312543wic.1
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 07:55:55 -0700 (PDT)
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com. [209.85.212.171])
        by mx.google.com with ESMTPS id h7si4488000wjz.55.2015.10.13.07.55.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Oct 2015 07:55:45 -0700 (PDT)
Received: by wieq12 with SMTP id q12so36666085wie.1
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 07:55:44 -0700 (PDT)
Subject: Re: Making per-cpu lists draining dependant on a flag
References: <56179E4F.5010507@kyup.com>
 <20151013144335.GB31034@dhcp22.suse.cz>
From: Nikolay Borisov <kernel@kyup.com>
Message-ID: <561D1B6F.8080509@kyup.com>
Date: Tue, 13 Oct 2015 17:55:43 +0300
MIME-Version: 1.0
In-Reply-To: <20151013144335.GB31034@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, mgorman@suse.de, Andrew Morton <akpm@linux-foundation.org>, Marian Marinov <mm@1h.com>, SiteGround Operations <operations@siteground.com>



On 10/13/2015 05:43 PM, Michal Hocko wrote:
> On Fri 09-10-15 14:00:31, Nikolay Borisov wrote:
>> Hello mm people,
>>
>>
>> I want to ask you the following question which stemmed from analysing
>> and chasing this particular deadlock:
>> http://permalink.gmane.org/gmane.linux.kernel/2056730
>>
>> To summarise it:
>>
>> For simplicity I will use the following nomenclature:
>> t1 - kworker/u96:0
>> t2 - kworker/u98:39
>> t3 - kworker/u98:7
> 
> Could you be more specific about the trace of all three parties?
> I am not sure I am completely following your description. Thanks!

Hi,

Maybe you'd want to check this thread:
http://thread.gmane.org/gmane.linux.kernel/2056996

Essentially, in the beginning I thought the problem could be in the
memory manager but after discussing with Jan Kara I thought the problem
doesn't like in the memory manager.


> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
