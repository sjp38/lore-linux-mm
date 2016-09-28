Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E0C7C6B0279
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 16:05:24 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id l138so51927063wmg.3
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 13:05:24 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u1si10345785wjx.280.2016.09.28.13.05.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 28 Sep 2016 13:05:23 -0700 (PDT)
Subject: Re: [PATCH] fs/select: add vmalloc fallback for select(2)
References: <20160922152831.24165-1-vbabka@suse.cz>
 <006101d21565$b60a8a70$221f9f50$@alibaba-inc.com>
 <20160923172434.7ad8f2e0@roar.ozlabs.ibm.com> <57E55CBB.5060309@akamai.com>
 <5014387d-43da-03f6-a74b-2dc4fbf4fe32@suse.cz>
 <20160927212458.3ab42b41@roar.ozlabs.ibm.com>
 <063D6719AE5E284EB5DD2968C1650D6DB010A97D@AcuExch.aculab.com>
 <20160927214229.2b0b49ac@roar.ozlabs.ibm.com>
 <92d1ec2c-3246-bd1f-eae5-53ca425ab315@suse.cz>
 <063D6719AE5E284EB5DD2968C1650D6DB010AAC6@AcuExch.aculab.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <32941b8b-ec1a-fc5c-90aa-e2372680f1b3@suse.cz>
Date: Wed, 28 Sep 2016 22:04:50 +0200
MIME-Version: 1.0
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB010AAC6@AcuExch.aculab.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Laight <David.Laight@ACULAB.COM>, Nicholas Piggin <npiggin@gmail.com>
Cc: Jason Baron <jbaron@akamai.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, 'Alexander Viro' <viro@zeniv.linux.org.uk>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 'Michal Hocko' <mhocko@kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>

On 09/28/2016 06:30 PM, David Laight wrote:
> From: Vlastimil Babka
>> Sent: 27 September 2016 12:51
> ...
>> Process name suggests it's part of db2 database. It seems it has to implement
>> its own interface to select() syscall, because glibc itself seems to have a
>> FD_SETSIZE limit of 1024, which is probably why this wasn't an issue for all the
>> years...
> 
> ISTR the canonical way to increase the size being to set FD_SETSIZE
> to a larger value before including any of the headers.
> 
> Or doesn't that work with linux and glibc ??

Doesn't seem so.

> 
> 	David
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
