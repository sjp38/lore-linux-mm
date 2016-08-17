Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8C5C46B0038
	for <linux-mm@kvack.org>; Wed, 17 Aug 2016 05:20:35 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id 65so233423131uay.1
        for <linux-mm@kvack.org>; Wed, 17 Aug 2016 02:20:35 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k125si24727817wmg.9.2016.08.17.02.20.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 17 Aug 2016 02:20:34 -0700 (PDT)
Subject: Re: OOM killer changes
References: <d8116023-dcd4-8763-af77-f2889f84cdb6@Quantum.com>
 <20160801200926.GF31957@dhcp22.suse.cz>
 <3c022d92-9c96-9022-8496-aa8738fb7358@quantum.com>
 <20160801202616.GG31957@dhcp22.suse.cz>
 <b91f97ee-c369-43be-c934-f84b96260ead@Quantum.com>
 <27bd5116-f489-252c-f257-97be00786629@Quantum.com>
 <20160802071010.GB12403@dhcp22.suse.cz>
 <ccad54a2-be1e-44cf-b9c8-d6b34af4901d@quantum.com>
 <6cb37d4a-d2dd-6c2f-a65d-51474103bf86@Quantum.com>
 <d1f63745-b9e3-b699-8a5a-08f06c72b392@suse.cz>
 <20160816031222.GC16913@js1304-P5Q-DELUXE>
 <ef85bac4-cbaa-8def-bf76-11741301dc87@Quantum.com>
 <8db47fdf-2d6a-d234-479e-6cc81be98655@suse.cz>
 <a8e202e8-1906-c57a-b392-d1353b9190b6@Quantum.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <082f48bf-dacd-b65d-7e48-8c56b1a9f805@suse.cz>
Date: Wed, 17 Aug 2016 11:20:31 +0200
MIME-Version: 1.0
In-Reply-To: <a8e202e8-1906-c57a-b392-d1353b9190b6@Quantum.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 08/17/2016 11:11 AM, Ralf-Peter Rohbeck wrote:
> On 17.08.2016 00:56, Vlastimil Babka wrote:
>> And I really wonder how did all those unmovable pageblocks happen.
>> AFAICS zoneinfo shows that most of memory is occupied by file lru pages.
>> These should be movable.
>
> Is it the pressure on the page cache? Don't forget that I write to some
> disk drives (recently, 2) at media speed with dd if=/dev/zero bs=4M
> of=/dev/SDX.

Hmm page cache should be movable. But maybe it's different for writing 
to devices and not filesystems.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
