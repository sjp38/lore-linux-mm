Message-ID: <3D9B6F7E.1060004@us.ibm.com>
Date: Wed, 02 Oct 2002 15:13:18 -0700
From: Dave Hansen <haveblue@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH]  4KB stack + irq stack for x86
References: <3D9B62AC.30607@us.ibm.com> <20021002174320.J28857@redhat.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@redhat.com>
Cc: linux-kernel@vger.kernel.org, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Benjamin LaHaise wrote:
> On Wed, Oct 02, 2002 at 02:18:36PM -0700, Dave Hansen wrote:
> 
>>I've resynced Ben's patch against 2.5.40.  However, I'm getting some 
>>strange failures.  The patch is good enough to pass LTP, but 
>>consistently freezes when I run tcpdump on it.
> 
> Try running tcpdump with the stack checking patch applied.  That should 
> give you a decent backtrace for the problem.

My first suspicion was that it was just overflowing, but not getting 
the message out.  I just realized that my latest testing (the last 24 
hours) was on the original patch, not the updated one that you posted 
later, which included the stack checking.  I'm sure that I was having 
the same problem with the overflow checking enabled and _not_ getting 
any errors from it, but I'll redo the testing for my sanity's sake.

-- 
Dave Hansen
haveblue@us.ibm.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
