Date: Tue, 21 Mar 2006 13:11:53 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [PATCH: 017/017]Memory hotplug for new nodes v.4.(arch_register_node() for ia64)
In-Reply-To: <1142872744.10906.125.camel@localhost.localdomain>
References: <20060320183634.7E9C.Y-GOTO@jp.fujitsu.com> <1142872744.10906.125.camel@localhost.localdomain>
Message-Id: <20060321130425.E477.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> On Mon, 2006-03-20 at 18:57 +0900, Yasunori Goto wrote:
> > Current i386's code treats "parent node" in arch_register_node(). 
> > But, IA64 doesn't need it.
> 
> I'm not sure I understand.  What do you mean by "treats"?

Oops. My English may be wrong. :-(
I mean that i386 seems trying to make relationship of parent and child
among each node.

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
