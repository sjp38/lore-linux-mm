Date: Fri, 18 Feb 2005 16:52:25 -0500 (EST)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [RFC][PATCH] Memory Hotplug
In-Reply-To: <1108685111.6482.40.camel@localhost>
Message-ID: <Pine.LNX.4.61.0502181650381.4052@chimarrao.boston.redhat.com>
References: <1108685033.6482.38.camel@localhost> <1108685111.6482.40.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII; format=flowed
Content-ID: <Pine.LNX.4.61.0502181650383.4052@chimarrao.boston.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, lhms <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Thu, 17 Feb 2005, Dave Hansen wrote:

> The attached patch is a prototype implementation of memory hot-add.  It
> allows you to boot your system, and add memory to it later.  Why would
> you want to do this?

I want it so I can grow Xen guests after they have been booted
up.  Being able to hot-add memory is essential for dynamically
resizing the memory of various guest OSes, to readjust them for
the workload.

Memory hot-remove isn't really needed with Xen, the balloon
driver takes care of that.

> I can post individual patches if anyone would like to comment on them.

I'm interested.  I want to get this stuff working with Xen ;)

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
