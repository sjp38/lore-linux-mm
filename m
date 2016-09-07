Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0B5A96B0038
	for <linux-mm@kvack.org>; Tue,  6 Sep 2016 21:12:50 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id 10so1908315ual.2
        for <linux-mm@kvack.org>; Tue, 06 Sep 2016 18:12:50 -0700 (PDT)
Received: from mail-qt0-x244.google.com (mail-qt0-x244.google.com. [2607:f8b0:400d:c0d::244])
        by mx.google.com with ESMTPS id f30si22248777qki.232.2016.09.06.18.12.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Sep 2016 18:12:49 -0700 (PDT)
Received: by mail-qt0-x244.google.com with SMTP id 38so34452qte.2
        for <linux-mm@kvack.org>; Tue, 06 Sep 2016 18:12:49 -0700 (PDT)
Subject: Re: [PATCH] mm:Avoid soft lockup due to possible attempt of double
 locking object's lock in __delete_object
References: <1472582112-9059-1-git-send-email-xerofoify@gmail.com>
 <20160831075421.GA15732@e104818-lin.cambridge.arm.com>
 <33981.1472677706@turing-police.cc.vt.edu>
 <6b5d162b-c09d-85c0-752f-a18f35bbbb5c@gmail.com>
 <1473209511.32433.179.camel@redhat.com>
From: nick <xerofoify@gmail.com>
Message-ID: <563d8230-4a58-cb5f-ef3e-b89745234252@gmail.com>
Date: Tue, 6 Sep 2016 21:12:47 -0400
MIME-Version: 1.0
In-Reply-To: <1473209511.32433.179.camel@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Valdis.Kletnieks@vt.edu, Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 2016-09-06 08:51 PM, Rik van Riel wrote:
> On Wed, 2016-08-31 at 17:28 -0400, nick wrote:
>>  
>> Rather then argue since that will go nowhere. I am posing actual
>> patches that have been tested on
>> hardware. 
> 
> But not by you, apparently.
> 
> The patch below was first posted by somebody else
> in 2013: https://lkml.org/lkml/2013/7/11/93
> 
> When re-posting somebody else's patch, you need to
> preserve their From: and Signed-off-by: headers.
> 
> See Documentation/SubmittingPatches for the details
> on that.
> 
> Pretending that other people's code is your own
> is not only very impolite, it also means that
> the origin of the code, and permission to distribute
> it under the GPL, are in question.
> 
> Will you promise to not claim other people's code as
> your own?
> 
I wasn't aware of that. Seems it was fixed before I got to 
it but was never merged. Next time I will double check if the
patch work is already out there. Also have this patch but the
commit message needs to be reworked:
