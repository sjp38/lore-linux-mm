In-Reply-To: <1189850897.21778.301.camel@twins>
References: <C2A8AED2-363F-4131-863C-918465C1F4E1@cam.ac.uk> <1189850897.21778.301.camel@twins>
Mime-Version: 1.0 (Apple Message framework v752.3)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Message-Id: <C9A68AAE-0B37-4BB5-A9E6-66C186566940@cam.ac.uk>
Content-Transfer-Encoding: 7bit
From: Anton Altaparmakov <aia21@cam.ac.uk>
Subject: Re: VM/VFS bug with large amount of memory and file systems?
Date: Sat, 15 Sep 2007 11:50:23 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: marc.smith@esmail.mcc.edu, Peter Zijlstra <peterz@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

Thanks for looking into this.

On 15 Sep 2007, at 11:08, Peter Zijlstra wrote:
> On Sat, 2007-09-15 at 08:27 +0100, Anton Altaparmakov wrote:
>
> Please, don't word wrap log-files, they're hard enough to read without
> it :-(
>
> ( I see people do this more and more often, *WHY*? is that because we
> like 80 char lines, in code and email? )

I haven't word wrapped it at all.  The lines appear as whole lines in  
Apple Mail (my email client).  It must be your email client that is  
wrapping them...

> Anyway, looks like all of zone_normal is pinned in kernel allocations:
>
>> Sep 13 15:31:25 escabot Normal free:3648kB min:3744kB low:4680kB  
>> high: 5616kB active:0kB inactive:3160kB present:894080kB  
>> pages_scanned:5336 all_unreclaimable? yes
>
> Out of the 870 odd mb only 3 is on the lru.
>
> Would be grand it you could have a look at slabinfo and the like.

Ok, Marc, would you be able to do the copy to /dev/null again (booted  
without the ram=2G option) and when you see that most of the memory  
has gone run:

cat /proc/slabinfo > slabinfo.txt
cat /proc/meminfo > meminfo.txt
cat /proc/vmstat > vmstat.txt
cat /proc/zoneinfo > zoneinfo.txt

Then quickly abort the copy with "Ctrl+C" so hopefully you will not  
get a kernel panic...

Please send the content of the generated files.  Thanks.

That should hopefully show what in the kernel has eaten all the low  
memory...

Best regards,

	Anton
-- 
Anton Altaparmakov <aia21 at cam.ac.uk> (replace at with @)
Unix Support, Computing Service, University of Cambridge, CB2 3QH, UK
Linux NTFS maintainer, http://www.linux-ntfs.org/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
