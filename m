Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id CE90C6B0006
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 08:24:04 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id j11-v6so13088058edq.16
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 05:24:04 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f19-v6si9125028eje.41.2018.10.16.05.24.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Oct 2018 05:24:03 -0700 (PDT)
Subject: Re: [patch] mm, page_alloc: set num_movable in move_freepages()
References: <alpine.DEB.2.21.1810051355490.212229@chino.kir.corp.google.com>
 <20181005142143.30032b7a4fb9dc2b587a8c21@linux-foundation.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <31b62d5d-11f6-6a68-fa04-889c98b66d9b@suse.cz>
Date: Tue, 16 Oct 2018 14:24:01 +0200
MIME-Version: 1.0
In-Reply-To: <20181005142143.30032b7a4fb9dc2b587a8c21@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 10/5/18 11:21 PM, Andrew Morton wrote:
> On Fri, 5 Oct 2018 13:56:39 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:
> 
>> If move_freepages() returns 0 because zone_spans_pfn(), *num_movable can
> 
>      move_free_pages_block()?           !zone_spans_pfn()?

Also the subject would be more accurate if it said "initialize
num_movable in move_freepages_block()" ?

Otherwise,
Acked-by: Vlastimil Babka <vbabka@suse.cz>

>> hold the value from the stack because it does not get initialized in
>> move_freepages().
>>
>> Move the initialization to move_freepages_block() to guarantee the value
>> actually makes sense.
>>
>> This currently doesn't affect its only caller where num_movable != NULL,
>> so no bug fix, but just more robust.
>>
>> ...
> 
