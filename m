Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2EBA96B0008
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 18:56:30 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id s21so11858862pfm.15
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 15:56:30 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q4-v6sor7257096plr.34.2018.03.26.15.56.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Mar 2018 15:56:29 -0700 (PDT)
Date: Tue, 27 Mar 2018 06:56:21 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH 1/2] mm/sparse: pass the __highest_present_section_nr + 1
 to alloc_func()
Message-ID: <20180326225621.GA79778@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20180326081956.75275-1-richard.weiyang@gmail.com>
 <alpine.DEB.2.20.1803261356380.251389@chino.kir.corp.google.com>
 <20180326223034.GA78976@WeideMacBook-Pro.local>
 <alpine.DEB.2.20.1803261546240.99792@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1803261546240.99792@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, dave.hansen@linux.intel.com, akpm@linux-foundation.org, mhocko@suse.com, linux-mm@kvack.org

On Mon, Mar 26, 2018 at 03:47:03PM -0700, David Rientjes wrote:
>On Tue, 27 Mar 2018, Wei Yang wrote:
>
>> >> In 'commit c4e1be9ec113 ("mm, sparsemem: break out of loops early")',
>> >> __highest_present_section_nr is introduced to reduce the loop counts for
>> >> present section. This is also helpful for usemap and memmap allocation.
>> >> 
>> >> This patch uses __highest_present_section_nr + 1 to optimize the loop.
>> >> 
>> >> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
>> >> ---
>> >>  mm/sparse.c | 2 +-
>> >>  1 file changed, 1 insertion(+), 1 deletion(-)
>> >> 
>> >> diff --git a/mm/sparse.c b/mm/sparse.c
>> >> index 7af5e7a92528..505050346249 100644
>> >> --- a/mm/sparse.c
>> >> +++ b/mm/sparse.c
>> >> @@ -561,7 +561,7 @@ static void __init alloc_usemap_and_memmap(void (*alloc_func)
>> >>  		map_count = 1;
>> >>  	}
>> >>  	/* ok, last chunk */
>> >> -	alloc_func(data, pnum_begin, NR_MEM_SECTIONS,
>> >> +	alloc_func(data, pnum_begin, __highest_present_section_nr+1,
>> >>  						map_count, nodeid_begin);
>> >>  }
>> >>  
>> >
>> >What happens if s/NR_MEM_SECTIONS/pnum/?
>> 
>> I have tried this :-)
>> 
>> The last pnum is -1 from next_present_section_nr().
>> 
>
>Lol.  I think it would make more sense for the second patch to come before 
>the first, but feel free to add
>

Thanks for your comment.

Do I need to reorder the patch and send v2?

>Acked-by: David Rientjes <rientjes@google.com>

-- 
Wei Yang
Help you, Help me
