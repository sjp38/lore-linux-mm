Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id AE5FF6B025E
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 17:28:46 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id f123so129062812ywd.2
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 14:28:46 -0700 (PDT)
Received: from mail-it0-x244.google.com (mail-it0-x244.google.com. [2607:f8b0:4001:c0b::244])
        by mx.google.com with ESMTPS id e5si30380648itd.85.2016.08.31.14.28.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Aug 2016 14:28:45 -0700 (PDT)
Received: by mail-it0-x244.google.com with SMTP id e124so3984757ith.1
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 14:28:45 -0700 (PDT)
Subject: Re: [PATCH] mm:Avoid soft lockup due to possible attempt of double
 locking object's lock in __delete_object
References: <1472582112-9059-1-git-send-email-xerofoify@gmail.com>
 <20160831075421.GA15732@e104818-lin.cambridge.arm.com>
 <33981.1472677706@turing-police.cc.vt.edu>
From: nick <xerofoify@gmail.com>
Message-ID: <6b5d162b-c09d-85c0-752f-a18f35bbbb5c@gmail.com>
Date: Wed, 31 Aug 2016 17:28:43 -0400
MIME-Version: 1.0
In-Reply-To: <33981.1472677706@turing-police.cc.vt.edu>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Valdis.Kletnieks@vt.edu, Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 2016-08-31 05:08 PM, Valdis.Kletnieks@vt.edu wrote:
> On Wed, 31 Aug 2016 08:54:21 +0100, Catalin Marinas said:
>> On Tue, Aug 30, 2016 at 02:35:12PM -0400, Nicholas Krause wrote:
>>> This fixes a issue in the current locking logic of the function,
>>> __delete_object where we are trying to attempt to lock the passed
>>> object structure's spinlock again after being previously held
>>> elsewhere by the kmemleak code. Fix this by instead of assuming
>>> we are the only one contending for the object's lock their are
>>> possible other users and create two branches, one where we get
>>> the lock when calling spin_trylock_irqsave on the object's lock
>>> and the other when the lock is held else where by kmemleak.
>>
>> Have you actually got a deadlock that requires this fix?
> 
> Almost certainly not, but that's never stopped Nicholas before.  He's a well-known
> submitter of bad patches, usually totally incorrect, not even compile tested.
> 
> He's infamous enough that he's not allowed to post to any list hosted at vger.
>
Valdis,
Rather then argue since that will go nowhere. I am posing actual patches that have been tested on
hardware. Yes I known that is surprising but it's true.
