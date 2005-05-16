Date: Mon, 16 May 2005 13:12:11 -0700 (PDT)
From: christoph <christoph@scalex86.org>
Subject: Re: [PATCH] Factor in buddy allocator alignment requirements in node
 memory alignment
In-Reply-To: <1116277014.1005.113.camel@localhost>
Message-ID: <Pine.LNX.4.62.0505161308010.25748@ScMPusgw>
References: <Pine.LNX.4.62.0505161204540.4977@ScMPusgw>
 <1116274451.1005.106.camel@localhost>  <Pine.LNX.4.62.0505161240240.13692@ScMPusgw>
  <1116276439.1005.110.camel@localhost>  <Pine.LNX.4.62.0505161253090.20839@ScMPusgw>
 <1116277014.1005.113.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, shai@scalex86.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 16 May 2005, Dave Hansen wrote:

> > > Do you know which pieces of code actually break if the alignment doesn't
> > > meet what that warning says?
> > 
> > I have seen nothing break but 4 MB allocations f.e. will not be allocated 
> > on a 4MB boundary with a 2 MB zone alignment. The page allocator always 
> > returnes properly aligned pages but 4MB allocations are an exception? 
> 
> I wasn't aware there was an alignment exception in the allocator for 4MB
> pages.  Could you provide some examples?

I never said that there was an aligment exception. The special case for 
4MB pages is created by the failure to properly align the zones in 
discontig.c.

But may be that is okay? Then we just need to remove the lines that 
detect the misalignment in the page allocator.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
