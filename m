Date: Wed, 17 Oct 2007 20:41:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Patch 002/002](memory hotplug) rearrange patch for notifier of
 memory hotplug
Message-Id: <20071017204128.99cad4b6.akpm@linux-foundation.org>
In-Reply-To: <20071018122210.514D.Y-GOTO@jp.fujitsu.com>
References: <20071018120343.5146.Y-GOTO@jp.fujitsu.com>
	<20071018122210.514D.Y-GOTO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Christoph Lameter <clameter@sgi.com>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 18 Oct 2007 12:23:34 +0900 Yasunori Goto <y-goto@jp.fujitsu.com> wrote:

>  	writeback_set_ratelimit();
> +
> +	if (onlined_pages)
> +		memory_notify(MEM_ONLINE, &arg);

perhaps that open-coded writeback_set_ratelimit() should become a
notifier callback.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
