Message-ID: <423B6373.8030107@yahoo.com.au>
Date: Sat, 19 Mar 2005 10:25:39 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Bug in __alloc_pages()?
References: <4238D1DC.8070004@us.ibm.com> <4238D8C1.3080805@yahoo.com.au> <423B52FE.6030101@us.ibm.com>
In-Reply-To: <423B52FE.6030101@us.ibm.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Dobson <colpatch@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>, "Bligh, Martin J." <mbligh@aracnet.com>
List-ID: <linux-mm.kvack.org>

Matthew Dobson wrote:

> 
> Agreed.  It seems unlikely, but not entirely impossible.  All it would 
> take is one sloppily coded driver, right?  How about this patch instead?
> 

Sure that would be fine with me. It kind of makes the logic
explicit, as Martin said.

Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
