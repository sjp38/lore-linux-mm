Date: Fri, 18 Feb 2005 20:48:32 -0500 (EST)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [RFC][PATCH] Memory Hotplug
In-Reply-To: <1108765246.6482.135.camel@localhost>
Message-ID: <Pine.LNX.4.61.0502182047020.19792@chimarrao.boston.redhat.com>
References: <1108685033.6482.38.camel@localhost>  <1108685111.6482.40.camel@localhost>
  <Pine.LNX.4.61.0502181650381.4052@chimarrao.boston.redhat.com>
 <1108765246.6482.135.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, lhms <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Fri, 18 Feb 2005, Dave Hansen wrote:

>> Memory hot-remove isn't really needed with Xen, the balloon
>> driver takes care of that.
>
> You can free up individual pages back to the hypervisor, but you might
> also want the opportunity to free up some unused mem_map if you shrink
> the partition by a large amount.

Agreed, though I rather like the fact that the code can
be introduced bit by bit, so the memory hot-remove code
(probably the most complex part) doesn't need to be
maintained out-of-tree for Xen, but can wait until it
is upstream.

>>> I can post individual patches if anyone would like to comment on them.
>>
>> I'm interested.  I want to get this stuff working with Xen ;)
>
> You can either pull them from here:
>
> 	http://www.sr71.net/patches/2.6.11/2.6.11-rc3-mhp1/broken-out/

Thanks, I'll take a stab at porting this functionality to Xen.

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
