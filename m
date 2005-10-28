Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e35.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9SIsA6G002149
	for <linux-mm@kvack.org>; Fri, 28 Oct 2005 14:54:10 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9SIsAk9537842
	for <linux-mm@kvack.org>; Fri, 28 Oct 2005 12:54:10 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j9SIsAe6027077
	for <linux-mm@kvack.org>; Fri, 28 Oct 2005 12:54:10 -0600
Message-ID: <436273CF.2050707@us.ibm.com>
Date: Fri, 28 Oct 2005 11:54:07 -0700
From: Badari Pulavarty <pbadari@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC] madvise(MADV_TRUNCATE)
References: <1130366995.23729.38.camel@localhost.localdomain> <20051028034616.GA14511@ccure.user-mode-linux.org> <43624F82.6080003@us.ibm.com> <20051028184235.GC8514@ccure.user-mode-linux.org>
In-Reply-To: <20051028184235.GC8514@ccure.user-mode-linux.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Dike <jdike@addtoit.com>
Cc: Hugh Dickins <hugh@veritas.com>, akpm@osdl.org, andrea@suse.de, dvhltc@us.ibm.com, linux-mm <linux-mm@kvack.org>, Blaisorblade <blaisorblade@yahoo.it>
List-ID: <linux-mm.kvack.org>

Jeff Dike wrote:

> On Fri, Oct 28, 2005 at 09:19:14AM -0700, Badari Pulavarty wrote:
> 
>>My touch tests so far, doesn't really verify data after freeing. I was
>>thinking about writing cases. If I can use UML to do it, please send it
>>to me. I would rather test with real world case :)
> 
> 
> Grab and unpack http://www.user-mode-linux.org/~jdike/truncate.tar.bz2
> 
> That will give you a "linux" directory.
> 
> Make sure that your /tmp is tmpfs with > 192M of space.
> 
> Run UML - from above the linux directory, this would be something like
> 	linux/2.6/linux-2.6.14-rc5/obj/linux con0=fd:0,fd:1 con1=none con=pts ssl=pts umid=debian mem=192M ubda=linux/debian_22 devfs=nomount
> 
> Log in, the root password is "root".
> 
> Unplug some memory -
> 	linux/uml_mconsole debian config mem=-10M
> 
> Go back to the UML and try do to something - ps, ls, anything.
> 
> It will be hung on handling an infinite page fault loop due to a whole lot
> of pages having been zeroed all of a sudden.
> 
> This will happen even when you unplug 2 pages (mem=-8K).  Only one of them
> will be madvised because the other is used to keep track of the madvised
> pages.
> 
> I also included my patchset in there (linux/2.6/linux-2.6.14-rc5/patches) if
> you want to build UML from source.  Due to my not refreshing the hotplug 
> patch before making the tarball, it's not there.  So, I've attached it.
> 

Thank you. Its going to be Monday before I get to it.
I will let you know.

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
