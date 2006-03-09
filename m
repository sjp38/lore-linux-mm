Date: Thu, 9 Mar 2006 04:00:55 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH: 010/017](RFC) Memory hotplug for new nodes v.3.
 (allocate wait table)
Message-Id: <20060309040055.21f3ec2d.akpm@osdl.org>
In-Reply-To: <20060308213301.0036.Y-GOTO@jp.fujitsu.com>
References: <20060308213301.0036.Y-GOTO@jp.fujitsu.com>
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
>  +		/* we can use kmalloc() in run time */
>  +		do {
>  +			table_size = zone->wait_table_size
>  +					* sizeof(wait_queue_head_t);
>  +			zone->wait_table = kmalloc(table_size, GFP_ATOMIC);

Again, GFP_KERNEL would be better is possible.

Won't this place the node's wait_table into a different node's memory?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
