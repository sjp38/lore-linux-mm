Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E58DD6B02A5
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 10:49:23 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id 31-v6so4950820edr.19
        for <linux-mm@kvack.org>; Thu, 25 Oct 2018 07:49:23 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t21-v6sor2594189ejf.20.2018.10.25.07.49.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Oct 2018 07:49:22 -0700 (PDT)
Date: Thu, 25 Oct 2018 14:49:20 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH 2/3] mm, slub: unify access to s->cpu_slab by replacing
 raw_cpu_ptr() with this_cpu_ptr()
Message-ID: <20181025144920.ics5alndk37rpm4s@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181025094437.18951-1-richard.weiyang@gmail.com>
 <20181025094437.18951-2-richard.weiyang@gmail.com>
 <01000166ab8007d8-7d1d4733-c13d-4e9d-b485-ae0846a5d78c-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <01000166ab8007d8-7d1d4733-c13d-4e9d-b485-ae0846a5d78c-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org

On Thu, Oct 25, 2018 at 01:53:06PM +0000, Christopher Lameter wrote:
>On Thu, 25 Oct 2018, Wei Yang wrote:
>
>> In current code, we use two forms to access s->cpu_slab
>>
>>   * raw_cpu_ptr()
>>   * this_cpu_ptr()
>
>Ok the only difference is that for CONFIG_DEBUG_PREEMPT we will do the
>debug checks twice.
>
>That tolerable I think but is this really a worthwhile change?

Agree.

My purpose is to make unify the access, looks easy for me to read the
code.

You can decide whether to change this or not :-)

-- 
Wei Yang
Help you, Help me
