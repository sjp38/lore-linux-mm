Message-ID: <46CE69DE.9040807@redhat.com>
Date: Fri, 24 Aug 2007 01:17:18 -0400
From: Chris Snook <csnook@redhat.com>
MIME-Version: 1.0
Subject: Re: Drop caches - is this safe behavior?
References: <bd9320b30708231645x3c6524efi55dd2cf7b1a9ba51@mail.gmail.com>	 <bd9320b30708231707l67d2d9d0l436a229bd77a86f@mail.gmail.com>	 <46CE3617.6000708@redhat.com> <1187930857.6406.12.camel@norville.austin.ibm.com>
In-Reply-To: <1187930857.6406.12.camel@norville.austin.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Cc: mike <mike503@gmail.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dave Kleikamp wrote:
> On Thu, 2007-08-23 at 21:36 -0400, Chris Snook wrote:
> 
>> If you think the system is doing the wrong thing (and it doesn't sound 
>> like it is) you should be tweaking the vm.swappiness sysctl.  The 
>> default is 60, but lower values will make it behave more like you think 
>> it should be behaving, though you'll still probably see a tiny bit of 
>> swap usage.  Of course, if your webservers are primarily serving up 
>> static content, you'll want a higher value, since swapping anonymous 
>> memory will leave more free for the pagecache you're primarily working with.
> 
> swappiness deals with page cache, whereas writing "2" to drop_caches
> cleans out the inode and dentry caches.  Mike may be better off writing
> a high number (say 10000) to /proc/sys/vm/vfs_cache_pressure.  This
> would cause inode and dentry cache to be reclaimed sooner than other
> memory.
> 

Thanks, I was confusing this with dropping pagecache.

Mike --

	Try Dave's suggestion to increase vm.vfs_cache_pressure.  drop_pages 
should never be needed, regardless of which caches you're dropping.

	-- Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
