Date: Fri, 14 Nov 2003 12:29:21 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: 2.6.0-test9-mm3
Message-ID: <100480000.1068841761@flay>
In-Reply-To: <200311141110.12671.pbadari@us.ibm.com>
References: <20031112233002.436f5d0c.akpm@osdl.org> <98290000.1068836914@flay> <200311141110.12671.pbadari@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>, Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> > - Several ext2 and ext3 allocator fixes.  These need serious testing on
>> > big SMP.
>> 
>> OK, ext3 survived a swatting on the 16-way as well. It's still slow as
>> snot, but it does work ;-) No changes from before, methinks.
>> 
>> Diffprofile for kernbench (-j) from ext2 to ext3 on mm3
>> 
>>      27022    16.3% total
>>      24069    53.3% default_idle
>>        583     2.4% page_remove_rmap
>>        539   248.4% fd_install
>>        478   388.6% __blk_queue_bounce
> 
> What driver are you using ? Why are you bouncing ?

qlogicisp. Because the driver is crap? ;-)

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
