In-Reply-To: <20061207174627.63300ccf.akpm@osdl.org>
References: <45789124.1070207@mvista.com> <20061207143611.7a2925e2.akpm@osdl.org> <04710480e9f151439cacdf3dd9d507d1@mvista.com> <20061207174627.63300ccf.akpm@osdl.org>
Mime-Version: 1.0 (Apple Message framework v624)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Message-Id: <df54053fca85900fab7864e0f05ed2c8@mvista.com>
Content-Transfer-Encoding: 7bit
From: david singleton <dsingleton@mvista.com>
Subject: Re: new procfs memory analysis feature
Date: Thu, 7 Dec 2006 17:53:06 -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Dec 7, 2006, at 5:46 PM, Andrew Morton wrote:

> On Thu, 7 Dec 2006 17:07:22 -0800
> david singleton <dsingleton@mvista.com> wrote:
>
>> Attached is the 2.6.19 patch.
>
> It still has the overflow bug.
>> +       do {
>> +               ptent = *pte;
>> +               if (pte_present(ptent)) {
>> +                       page = vm_normal_page(vma, addr, ptent);
>> +                       if (page) {
>> +                               if (pte_dirty(ptent))
>> +                                       mapcount = 
>> -page_mapcount(page);
>> +                               else
>> +                                       mapcount = 
>> page_mapcount(page);
>> +                       } else {
>> +                               mapcount = 1;
>> +                       }
>> +               }
>> +               seq_printf(m, " %d", mapcount);
>> +
>> +       } while (pte++, addr += PAGE_SIZE, addr != end);
>
> Well that's cute.  As long as both seq_file and pte-pages are of size
> PAGE_SIZE, and as long as pte's are more than three bytes, this will 
> not
> overflow the seq_file output buffer.
>
> hm.  Unless the pages are all dirty and the mapcounts are all 10000.  I
> think it will overflow then?
>

I guess that could happen?    Any suggestions?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
