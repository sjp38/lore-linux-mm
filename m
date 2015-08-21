Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 0F7306B0253
	for <linux-mm@kvack.org>; Fri, 21 Aug 2015 08:43:10 -0400 (EDT)
Received: by pdbmi9 with SMTP id mi9so26418494pdb.3
        for <linux-mm@kvack.org>; Fri, 21 Aug 2015 05:43:09 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id t5si12760080pdi.57.2015.08.21.05.43.08
        for <linux-mm@kvack.org>;
        Fri, 21 Aug 2015 05:43:09 -0700 (PDT)
Message-ID: <55D71CD9.8000109@internode.on.net>
Date: Fri, 21 Aug 2015 22:13:05 +0930
From: Arthur Marsh <arthur.marsh@internode.on.net>
MIME-Version: 1.0
Subject: Re: difficult to pinpoint exhaustion of swap between 4.2.0-rc6 and
 4.2.0-rc7
References: <55D4A462.3070505@internode.on.net> <55D58CEB.9070701@suse.cz> <55D6ECBD.60303@internode.on.net> <55D70D80.5060009@suse.cz> <55D71021.7030803@suse.cz>
In-Reply-To: <55D71021.7030803@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>



Vlastimil Babka wrote on 21/08/15 21:18:
> On 08/21/2015 01:37 PM, Vlastimil Babka wrote:
>>
>> That, said, looking at the memory values:
>>
>> rc6: Free+Buffers+A/I(Anon)+A/I(File)+Slab = 6769MB
>> rc7: ...                                   = 4714MB
>>
>> That's 2GB unaccounted for.
>
> So one brute-force way to see who allocated those 2GB is to use the
> page_owner debug feature. You need to enable CONFIG_PAGE_OWNER and then
> follow the Usage part of Documentation/vm/page_owner.txt
> If you can do that, please send the sorted_page_owner.txt for rc7 when
> it's semi-nearing the exhausted swap. Then you could start doing a
> comparison run with rc6, but maybe it will be easy to figure from the
> rc7 log already. Thanks.
>

I'm currently rebuilding the rc7 kernel with CONFIG_PAGE_OWNER=y and 
will test that.

Arthur.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
