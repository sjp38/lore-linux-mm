Message-ID: <4033A91B.3030801@am.sony.com>
Date: Wed, 18 Feb 2004 10:04:11 -0800
From: Tim Bird <tim.bird@am.sony.com>
MIME-Version: 1.0
Subject: Re: Non-GPL export of invalidate_mmap_range
References: <1077108694.4479.4.camel@laptop.fenrus.com>
In-Reply-To: <1077108694.4479.4.camel@laptop.fenrus.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: arjanv@redhat.com
Cc: Andrew Morton <akpm@osdl.org>, paulmck@us.ibm.com, hch@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I should know better than to stir up a hornets nest
by discussing GPL issues on this list... :)

Arjan van de Ven wrote:
> On Wed, 2004-02-18 at 01:19, Andrew Morton wrote:
>>Neat, but it's hard to see the relevance of this to your patch.
>>I don't see any licensing issues with the patch because the filesystem
>>which needs it clearly meets Linus's "this is not a derived work"
>>criteria.
> 
> it does?
...
> it needs no changes to the core kernel? *buzz*
Actually, this would tend towards an interpretation that
it was NOT a derived work.

That is, if a the Linux kernel must be modified in order
to run with a piece of software, that's one indicator
that the piece of software (when standing alone) may not
be derived from the kernel.  I am purposely avoiding the
"but what about when it's linked" argument.

=============================
Tim Bird
Architecture Group Co-Chair
CE Linux Forum
Senior Staff Engineer
Sony Electronics
E-mail: Tim.Bird@am.sony.com
=============================

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
