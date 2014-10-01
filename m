Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9DEDD6B0069
	for <linux-mm@kvack.org>; Wed,  1 Oct 2014 17:18:45 -0400 (EDT)
Received: by mail-wg0-f51.google.com with SMTP id b13so1530857wgh.10
        for <linux-mm@kvack.org>; Wed, 01 Oct 2014 14:18:45 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id es9si3831507wib.61.2014.10.01.14.18.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 01 Oct 2014 14:18:44 -0700 (PDT)
Message-ID: <542C6FB2.8000503@suse.cz>
Date: Wed, 01 Oct 2014 23:18:42 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH] mm, compaction: using uninitialized_var insteads setting
 'flags' to 0 directly.
References: <1411961425-8045-1-git-send-email-Li.Xiubo@freescale.com> <542A5B5B.7060207@suse.cz> <alpine.DEB.2.02.1410011314180.21593@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1410011314180.21593@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Xiubo Li <Li.Xiubo@freescale.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mgorman@suse.de, minchan@kernel.org, Arnd Bergmann <arnd@arndb.de>

On 10/01/2014 10:16 PM, David Rientjes wrote:
>> On 09/29/2014 05:30 AM, Xiubo Li wrote:
>> > Setting 'flags' to zero will be certainly a misleading way to avoid
>> > warning of 'flags' may be used uninitialized. uninitialized_var is
>> > a correct way because the warning is a false possitive.
>> 
>> Agree.
>> 
>> > Signed-off-by: Xiubo Li <Li.Xiubo@freescale.com>
>> 
>> Acked-by: Vlastimil Babka <vbabka@suse.cz>
>> 
> 
> I thought we just discussed this when 
> mm-compaction-fix-warning-of-flags-may-be-used-uninitialized.patch was 
> merged and, although I liked it, it was stated that we shouldn't add any 
> new users of uninitialized_var().

Yeah but that discussion wasn't unfortunately CC'd on mailing lists. And my
interpretation of the outcome is that maybe we should try :)

Also note that Arnd sent this kind of fix first, but that thread missed mailing
lists as well. CCing him at least.

Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
