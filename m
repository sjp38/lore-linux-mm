Date: Thu, 9 Mar 2006 04:01:00 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH: 011/017](RFC) Memory hotplug for new nodes v.3. (start
 kswapd)
Message-Id: <20060309040100.0d258a25.akpm@osdl.org>
In-Reply-To: <20060308213333.0038.Y-GOTO@jp.fujitsu.com>
References: <20060308213333.0038.Y-GOTO@jp.fujitsu.com>
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
>  +EXPORT_SYMBOL(kswapd_run);

Does this need to be exported to modules?

If so, EXPORT_SYMBOL_GPL would be preferred, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
