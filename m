Subject: Re: Active Memory Defragmentation: Our implementation & problems
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <35380000.1075874735@[10.10.2.4]>
References: <20040204050915.59866.qmail@web9704.mail.yahoo.com>
	 <1075874074.14153.159.camel@nighthawk>  <35380000.1075874735@[10.10.2.4]>
Content-Type: text/plain
Message-Id: <1075875756.14153.251.camel@nighthawk>
Mime-Version: 1.0
Date: 03 Feb 2004 22:22:36 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Alok Mooley <rangdi@yahoo.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2004-02-03 at 22:05, Martin J. Bligh wrote:
> >> In order to move such pages, we will have to patch macros like
> >> "virt_to_phys" & other related macros, so that the address 
> >> translation for pages moved by us will take place vmalloc style, i.e.,
> >> via page tables, instead of direct +-3GB. Is it worth introducing such
> >> an overhead for address translation (vmalloc does it!)? If no, then is
> >> there another way out, or is it better to stick to our current
> >> definition of a movable page? 
> > 
> > Low memory kernel pages are a much bigger deal to defrag.  I've started
> > to think about these for hotplug memory and it just makes my head hurt. 
> > If you want to do this, you are right, you'll have to alter virt_to_phys
> > and company.  The best way I've seen this is with CONFIG_NONLINEAR:
> > http://lwn.net/2002/0411/a/discontig.php3
> > Those lookup tables are pretty fast, and have benefits to many areas
> > beyond defragmentation like NUMA and the memory hotplug projects.  
> 
> I don't think that helps you really - the mappings are usually done on
> chunks signficantly larger than one page, and we don't want to break
> away from using large pages for the kernel mappings.

Yeah, you're right about that one.  The defrag thing needs to deal with
much smaller sections than nonlinear does.  That pretty much leaves
being careful where you allocate.

--dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
