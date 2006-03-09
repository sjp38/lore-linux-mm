Date: Thu, 9 Mar 2006 04:01:04 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH: 012/017](RFC) Memory hotplug for new nodes v.3.
 (rebuild zonelists after online pages)
Message-Id: <20060309040104.6e6f5ccd.akpm@osdl.org>
In-Reply-To: <20060308213410.003A.Y-GOTO@jp.fujitsu.com>
References: <20060308213410.003A.Y-GOTO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: tony.luck@intel.com, ak@suse.de, jschopp@austin.ibm.com, haveblue@us.ibm.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Yasunori Goto <y-goto@jp.fujitsu.com> wrote:
>
> In current code, zonelist is considered to be build once, no modification.
>  But MemoryHotplug can add new zone/pgdat. It must be updated.
> 
>  This patch modifies build_all_zonelists(). 
>  By this, build_all_zonelist() can reconfig pgdat's zonelists.
> 
>  To update them safety, this patch use stop_machine_run().

Yup, that's a good way of doing it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
