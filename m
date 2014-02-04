Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f171.google.com (mail-ea0-f171.google.com [209.85.215.171])
	by kanga.kvack.org (Postfix) with ESMTP id 6EF496B0035
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 02:17:20 -0500 (EST)
Received: by mail-ea0-f171.google.com with SMTP id f15so4124021eak.2
        for <linux-mm@kvack.org>; Mon, 03 Feb 2014 23:17:19 -0800 (PST)
Received: from ofcsgdbm.dwd.de (ofcsgdbm.dwd.de. [141.38.3.245])
        by mx.google.com with ESMTP id w5si18472359eef.172.2014.02.03.23.17.18
        for <linux-mm@kvack.org>;
        Mon, 03 Feb 2014 23:17:19 -0800 (PST)
Received: from localhost (localhost [127.0.0.1])
	by ofcsgdn3.dwd.de (Postfix) with ESMTP id AA58953E64
	for <linux-mm@kvack.org>; Tue,  4 Feb 2014 07:17:18 +0000 (UTC)
Received: from ofcsgdn3.dwd.de ([127.0.0.1])
	by localhost (ofcsgdn3.csg.lan [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id YShJR67qoOk7 for <linux-mm@kvack.org>;
	Tue,  4 Feb 2014 07:17:18 +0000 (UTC)
Date: Tue, 4 Feb 2014 07:17:18 +0000 (GMT)
From: Holger Kiehl <Holger.Kiehl@dwd.de>
Subject: Re: Need help in bug in isolate_migratepages_range
In-Reply-To: <alpine.DEB.2.02.1402031602060.10778@chino.kir.corp.google.com>
Message-ID: <alpine.LRH.2.02.1402040713220.13901@diagnostix.dwd.de>
References: <alpine.LRH.2.02.1401312037340.6630@diagnostix.dwd.de> <20140203122052.GC2495@dhcp22.suse.cz> <alpine.LRH.2.02.1402031426510.13382@diagnostix.dwd.de> <20140203162036.GJ2495@dhcp22.suse.cz> <52EFC93D.3030106@suse.cz>
 <alpine.DEB.2.02.1402031602060.10778@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.cz>, linux-kernel <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org

On Mon, 3 Feb 2014, David Rientjes wrote:

> On Mon, 3 Feb 2014, Vlastimil Babka wrote:
>
>> It seems to come from balloon_page_movable() and its test page_count(page) ==
>> 1.
>>
>
> Hmm, I think it might be because compound_head() == NULL here.  Holger,
> this looks like a race condition when allocating a compound page, did you
> only see it once or is it actually reproducible?
>
No, this only happened once. It is not reproducable, the system was running
for four days without problems. And before this kernel, five years without
any problems.

Thanks,
Holger

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
