Date: Tue, 25 Feb 2003 20:14:59 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: RE: Silly question: How to map a user space page in kernel space?
Message-ID: <7550000.1046232898@[10.10.2.4]>
In-Reply-To: <A46BBDB345A7D5118EC90002A5072C780A7D57BB@orsmsx116.jf.intel.com>
References: <A46BBDB345A7D5118EC90002A5072C780A7D57BB@orsmsx116.jf.intel.com
 >
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Perez-Gonzalez, Inaky" <inaky.perez-gonzalez@intel.com>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>> > I have a user space page (I know the 'struct page *' and I did a
>> > get_page() on it so it doesn't go away to swap) and I need to be able
>> > to access it with normal pointers (to do a bunch of atomic operations
>> > on it). I cannot use get_user() and friends, just pointers.
>> > 
>> > So, the question is, how can I map it into the kernel space in a
>> > portable manner? Am I missing anything very basic here?
>> 
>> kmap or kmap_atomic
> 
> I am trying to use kmap_atomic(), but what is the meaning of the second
> argument, km_type? I cannot find it anywhere, or at least the difference
> between KM_USER0 and KM_USER1, which I am guessing are the ones I need.

Each type is for a different usage, and you need to ensure that two things
can't reuse the same type at once. As long as interrupts, or whatever could
disturb you can't use what you use, you're OK. Note that you can't hold
kmap_atomic over a schedule (presumably this means no pre-emption either).
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
