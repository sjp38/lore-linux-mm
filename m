Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D4B6C6B2FE4
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 09:21:58 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id w44-v6so3640031edb.16
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 06:21:58 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z15-v6si984431edr.81.2018.08.24.06.21.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Aug 2018 06:21:57 -0700 (PDT)
Subject: Re: [GIT PULL] XArray for 4.19
References: <20180813161357.GB1199@bombadil.infradead.org>
 <0100016562b90938-02b97bb7-eddd-412d-8162-7519a70d4103-000000@email.amazonses.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <0c8ffb97-5896-148c-bff8-ffb92a60b307@suse.cz>
Date: Fri, 24 Aug 2018 15:21:55 +0200
MIME-Version: 1.0
In-Reply-To: <0100016562b90938-02b97bb7-eddd-412d-8162-7519a70d4103-000000@email.amazonses.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>, Matthew Wilcox <willy@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 08/22/2018 07:40 PM, Christopher Lameter wrote:
> On Mon, 13 Aug 2018, Matthew Wilcox wrote:
> 
>> Please consider pulling the XArray patch set.  The XArray provides an
>> improved interface to the radix tree data structure, providing locking
>> as part of the API, specifying GFP flags at allocation time, eliminating
>> preloading, less re-walking the tree, more efficient iterations and not
>> exposing RCU-protected pointers to its users.
> 
> Is this going in this cycle? I have a bunch of stuff on top of this to
> enable slab object migration.

I think you can just post those for review and say that they apply on
top of xarray git? Maybe also with your own git URL with those applied
for easier access? I'm curious but also sceptical that something so
major would get picked up to mmotm immediately :)
