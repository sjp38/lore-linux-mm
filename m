Date: Tue, 21 Nov 2006 21:19:37 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] virtual memmap for sparsemem [1/2] arch independent part
Message-Id: <20061121211937.e25dceb8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20061121113708.GB8122@osiris.boeblingen.de.ibm.com>
References: <20061019172140.5a29962c.kamezawa.hiroyu@jp.fujitsu.com>
	<20061121113708.GB8122@osiris.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux-mm@kvack.org, linux-ia64@vger.kernel.org, schwidefsky@de.ibm.com
List-ID: <linux-mm.kvack.org>

On Tue, 21 Nov 2006 12:37:08 +0100
Heiko Carstens <heiko.carstens@de.ibm.com> wrote:

> > Todo
> > - fix vmalloc() case in memory hotadd. (maybe __get_vm_area() can be used.)
> 
> Better late than never, but here is a reply as well :)
> 
Thank you for comment.
I'm now stopping this because of piles of user troubles and Excels and Words ;)

> Is this supposed to replace ia64's vmem_map?
No. my aim is just to speed-up sparsemem. ia64/sparsemem's page_to_pfn()
pfn_to_page() is costly.

> I'm asking because on s390 we need a vmem_map too, but don't want to be
> limited by the sparsemem restrictions (especially SECTION_SIZE that is).
> In addition we have a shared memory device driver (dcss) with which it
> is possible to attach some shared memory. Because of that it is
> necessary to be able to add some additional struct pages on-the-fly.
> This is not very different to memory hotplug; I think it's even easier,
> since all we need are some initialized struct pages.
> 
> Currently I have a working prototype that does all that but still needs
> a lot of cleanup and some error handling. It is (of course) heavily
> inspired by ia64's vmem_map implementation.
> 
> I'd love to go for a generic implementation, but if that is based on
> sparsemem it doesn't make too much sense on s390.

'What type of vmem_map is supported ?' is maybe per-arch decision not generic.
If people dislikes Flat/Discontig/Sparsemem complication, some clean
up patch will be posted and discussion will start. If not, nothing will happen.

-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
