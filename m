Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id DC0CA6B0006
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 03:46:01 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id n2-v6so593709edr.5
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 00:46:01 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z3-v6si998814edj.223.2018.07.03.00.46.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 00:46:00 -0700 (PDT)
Subject: Re: [REGRESSION] "Locked" and "Pss" in /proc/*/smaps are the same
From: Vlastimil Babka <vbabka@suse.cz>
References: <69eb77f7-c8cc-fdee-b44f-ad7e522b8467@gmail.com>
 <ebf6c7fb-fec3-6a26-544f-710ed193c154@suse.cz>
Message-ID: <f19dd0ba-7fe7-57d9-6872-aa6498f75d42@suse.cz>
Date: Tue, 3 Jul 2018 09:45:59 +0200
MIME-Version: 1.0
In-Reply-To: <ebf6c7fb-fec3-6a26-544f-710ed193c154@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Lindroth <thomas.lindroth@gmail.com>, dancol@google.com, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-api@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On 07/03/2018 09:36 AM, Vlastimil Babka wrote:
> On 07/01/2018 08:31 PM, Thomas Lindroth wrote:
>> While looking around in /proc on my v4.14.52 system I noticed that
>> all processes got a lot of "Locked" memory in /proc/*/smaps. A lot
>> more memory than a regular user can usually lock with mlock().
>>
>> commit 493b0e9d945fa9dfe96be93ae41b4ca4b6fdb317 (v4.14-rc1) seems
>> to have changed the behavior of "Locked".

Oops, I forgot, thanks for the nice report :)

Vlastimil
