Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id BFD366B0260
	for <linux-mm@kvack.org>; Fri, 13 May 2016 11:15:28 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id f14so30345785lbb.2
        for <linux-mm@kvack.org>; Fri, 13 May 2016 08:15:28 -0700 (PDT)
Received: from smtp.laposte.net (smtpoutz27.laposte.net. [194.117.213.102])
        by mx.google.com with ESMTPS id y9si22618161wje.220.2016.05.13.08.15.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 08:15:27 -0700 (PDT)
Received: from smtp.laposte.net (localhost [127.0.0.1])
	by lpn-prd-vrout015 (Postfix) with ESMTP id 026071C8DC3
	for <linux-mm@kvack.org>; Fri, 13 May 2016 17:15:27 +0200 (CEST)
Received: from lpn-prd-vrin001 (lpn-prd-vrin001.laposte [10.128.63.2])
	by lpn-prd-vrout015 (Postfix) with ESMTP id EF3C91C8DB1
	for <linux-mm@kvack.org>; Fri, 13 May 2016 17:15:26 +0200 (CEST)
Received: from lpn-prd-vrin001 (localhost [127.0.0.1])
	by lpn-prd-vrin001 (Postfix) with ESMTP id DCDFC366A0A
	for <linux-mm@kvack.org>; Fri, 13 May 2016 17:15:26 +0200 (CEST)
Message-ID: <5735EF8E.4000707@laposte.net>
Date: Fri, 13 May 2016 17:15:26 +0200
From: Sebastian Frias <sf84@laposte.net>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: add config option to select the initial overcommit
 mode
References: <5731CC6E.3080807@laposte.net>	<20160513080458.GF20141@dhcp22.suse.cz>	<573593EE.6010502@free.fr>	<5735A3DE.9030100@laposte.net>	<20160513120042.GK20141@dhcp22.suse.cz>	<5735CAE5.5010104@laposte.net>	<935da2a3-1fda-bc71-48a5-bb212db305de@gmail.com>	<5735D7FC.3070409@laposte.net> <20160513160142.2cc7d695@lxorguk.ukuu.org.uk>
In-Reply-To: <20160513160142.2cc7d695@lxorguk.ukuu.org.uk>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Cc: "Austin S. Hemmelgarn" <ahferroin7@gmail.com>, Michal Hocko <mhocko@kernel.org>, Mason <slash.tmp@free.fr>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

Hi Alan,

On 05/13/2016 05:01 PM, One Thousand Gnomes wrote:
> On Fri, 13 May 2016 15:34:52 +0200
> Sebastian Frias <sf84@laposte.net> wrote:
> 
>> Hi Austin,
>>
>> On 05/13/2016 03:11 PM, Austin S. Hemmelgarn wrote:
>>> On 2016-05-13 08:39, Sebastian Frias wrote:  
>>>>
>>>> My point is that it seems to be possible to deal with such conditions in a more controlled way, ie: a way that is less random and less abrupt.  
>>> There's an option for the OOM-killer to just kill the allocating task instead of using the scoring heuristic.  This is about as deterministic as things can get though.  
>>
>> By the way, why does it has to "kill" anything in that case?
>> I mean, shouldn't it just tell the allocating task that there's not enough memory by letting malloc return NULL?
> 
> Just turn off overcommit and it will do that. With overcommit disabled
> the kernel will not hand out address space in excess of memory plus swap.

I think I'm confused.
Michal just said:

   "And again, overcommit=never doesn't imply no-OOM. It just makes it less
likely. The kernel can consume quite some unreclaimable memory as well."

which I understand as the OOM-killer will still lurk around and could still wake up.

Will overcommit=never totally disable the OOM-Killer or not?

Best regards,

Sebastian


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
