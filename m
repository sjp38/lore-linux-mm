Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 396606B0005
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 08:10:12 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id f126so34285808wma.3
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 05:10:12 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a203si850236wme.4.2016.07.13.05.10.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Jul 2016 05:10:10 -0700 (PDT)
Subject: Re: [PATCH 0/4] [RFC][v4] Workaround for Xeon Phi PTE A/D bits
 erratum
References: <20160701174658.6ED27E64@viggo.jf.intel.com>
 <1467412092.7422.56.camel@kernel.crashing.org>
 <9c09c63c-5c2a-20a4-d68b-a6dc2f88ecaa@suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <829f2f03-8492-841d-869f-7fd7add9cb27@suse.cz>
Date: Wed, 13 Jul 2016 14:10:07 +0200
MIME-Version: 1.0
In-Reply-To: <9c09c63c-5c2a-20a4-d68b-a6dc2f88ecaa@suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, linux-kernel@vger.kernel.org
Cc: x86@kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, bp@alien8.de, ak@linux.intel.com, mhocko@suse.com

On 07/13/2016 01:37 PM, Vlastimil Babka wrote:
>> > With the errata, don't you have a situation where a processor in the second
>> > category will write and set D despite P having been cleared (due to the
>> > race) and thus causing us to miss the transfer of that D to the struct
>> > page and essentially completely miss that the physical page is dirty ?
> Seems to me like this is indeed possible, but...

Nevermind, I have read the v3 thread now, where Dave says [1] that 
setting the D bit due to the erratum doesn't mean that the page is 
really actually written to (it's not). So there shouldn't be any true 
dirty bit to leave behind.

[1] http://marc.info/?l=linux-mm&m=146738965614826&w=2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
