Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 7E1C86B0253
	for <linux-mm@kvack.org>; Fri, 21 Aug 2015 07:48:52 -0400 (EDT)
Received: by wijp15 with SMTP id p15so17638164wij.0
        for <linux-mm@kvack.org>; Fri, 21 Aug 2015 04:48:51 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gm12si14437670wjc.83.2015.08.21.04.48.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 21 Aug 2015 04:48:51 -0700 (PDT)
Subject: Re: difficult to pinpoint exhaustion of swap between 4.2.0-rc6 and
 4.2.0-rc7
References: <55D4A462.3070505@internode.on.net> <55D58CEB.9070701@suse.cz>
 <55D6ECBD.60303@internode.on.net> <55D70D80.5060009@suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55D71021.7030803@suse.cz>
Date: Fri, 21 Aug 2015 13:48:49 +0200
MIME-Version: 1.0
In-Reply-To: <55D70D80.5060009@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arthur Marsh <arthur.marsh@internode.on.net>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On 08/21/2015 01:37 PM, Vlastimil Babka wrote:
>
> That, said, looking at the memory values:
>
> rc6: Free+Buffers+A/I(Anon)+A/I(File)+Slab = 6769MB
> rc7: ...                                   = 4714MB
>
> That's 2GB unaccounted for.

So one brute-force way to see who allocated those 2GB is to use the 
page_owner debug feature. You need to enable CONFIG_PAGE_OWNER and then 
follow the Usage part of Documentation/vm/page_owner.txt
If you can do that, please send the sorted_page_owner.txt for rc7 when 
it's semi-nearing the exhausted swap. Then you could start doing a 
comparison run with rc6, but maybe it will be easy to figure from the 
rc7 log already. Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
