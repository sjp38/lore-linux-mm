From: Lion Vollnhals <lion.vollnhals@web.de>
Subject: Re: Fix interface for memory hotplug in 2.6.13-mm3
Date: Fri, 16 Sep 2005 14:49:21 +0200
References: <20050916101541.D1B1.Y-GOTO@jp.fujitsu.com>
In-Reply-To: <20050916101541.D1B1.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200509161449.21413.lion.vollnhals@web.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Andrew Morton <akpm@osdl.org>, Dave Hansen <haveblue@us.ibm.com>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Friday 16 September 2005 03:48, Yasunori Goto wrote:
> 
> Hi Andrew-san.
> 
> I found old unsuitable interfaces for memory hotplug in 2.6.13-mm3.
> 
> The third argument of sparse_add_one_section() was changed from mem_map
> to nr_pages. And the third argument of add/remove_memory() was removed.
> However, both still remain at a few place.
> 

Seems good to me.

Signed-off-by: Lion Vollnhals <webmaster@schiggl.de>


-- 
Lion Vollnhals
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
