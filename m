Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 832946B0006
	for <linux-mm@kvack.org>; Mon, 21 May 2018 19:02:50 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id s16-v6so10066730pfm.1
        for <linux-mm@kvack.org>; Mon, 21 May 2018 16:02:50 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id b9-v6si5547131plk.111.2018.05.21.16.02.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 May 2018 16:02:49 -0700 (PDT)
Subject: Re: Why do we let munmap fail?
References: <CAKOZuetOD6MkGPVvYFLj5RXh200FaDyu3sQqZviVRhTFFS3fjA@mail.gmail.com>
 <aacd607f-4a0d-2b0a-d8d9-b57c686d24fc@intel.com>
 <CAKOZuetDX905PeLt5cs7e_maSeKHrP0DgM1Kr3vvOb-+n=a7Gw@mail.gmail.com>
 <e6bdfa05-fa80-41d1-7b1d-51cf7e4ac9a1@intel.com>
 <CAKOZuev=Pa6FkvxTPbeA1CcYG+oF2JM+JVL5ELHLZ--7wyr++g@mail.gmail.com>
 <20eeca79-0813-a921-8b86-4c2a0c98a1a1@intel.com>
 <CAKOZuesoh7svdmdNY9md3N+vWGurigDLZ5_xDjwgU=uYdKkwqg@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <2e7fb27e-90b4-38d2-8ae1-d575d62c5332@intel.com>
Date: Mon, 21 May 2018 16:02:47 -0700
MIME-Version: 1.0
In-Reply-To: <CAKOZuesoh7svdmdNY9md3N+vWGurigDLZ5_xDjwgU=uYdKkwqg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Colascione <dancol@google.com>
Cc: linux-mm@kvack.org, Tim Murray <timmurray@google.com>, Minchan Kim <minchan@kernel.org>

On 05/21/2018 03:54 PM, Daniel Colascione wrote:
>> There are also certainly denial-of-service concerns if you allow
>> arbitrary numbers of VMAs.  The rbtree, for instance, is O(log(n)), but
>> I 'd be willing to be there are plenty of things that fall over if you
>> let the ~65k limit get 10x or 100x larger.
> Sure. I'm receptive to the idea of having *some* VMA limit. I just think
> it's unacceptable let deallocation routines fail.

If you have a resource limit and deallocation consumes resources, you
*eventually* have to fail a deallocation.  Right?
