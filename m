Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 09C176B0032
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 04:45:20 -0500 (EST)
Received: by mail-wg0-f44.google.com with SMTP id y19so1812136wgg.3
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 01:45:19 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 2si40592743wjy.148.2015.01.13.01.45.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 13 Jan 2015 01:45:18 -0800 (PST)
Message-ID: <54B4E92D.5050800@suse.cz>
Date: Tue, 13 Jan 2015 10:45:17 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 1/1 linux-next] mm,compaction: move suitable_migration_target()
 under CONFIG_COMPACTION
References: <1420301068-19447-1-git-send-email-fabf@skynet.be> <54AC1991.9060908@suse.cz> <1453795579.577520.1420839030684.open-xchange@webmail.nmp.proximus.be>
In-Reply-To: <1453795579.577520.1420839030684.open-xchange@webmail.nmp.proximus.be>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fabian Frederick <fabf@skynet.be>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

On 01/09/2015 10:30 PM, Fabian Frederick wrote:
> 
> 
>> On 06 January 2015 at 18:21 Vlastimil Babka <vbabka@suse.cz> wrote:
>>
>>
>> On 01/03/2015 05:04 PM, Fabian Frederick wrote:
>> > suitable_migration_target() is only used by isolate_freepages()
>> > Define it under CONFIG_COMPACTION || CONFIG_CMA is not needed.
>> >
>> > Fix the following warning:
>> > mm/compaction.c:311:13: warning: 'suitable_migration_target' defined
>> > but not used [-Wunused-function]
>> >
>> > Signed-off-by: Fabian Frederick <fabf@skynet.be>
>>
>> I agree, I would just move it to the section where isolation_suitable() and
>> related others are, maybe at the end of this section below
>> update_pageblock_skip()?
> 
> Yes of course, that would solve the warning as well.

So, send a v2? :)
Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
