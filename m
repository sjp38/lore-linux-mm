Date: Thu, 20 Apr 2006 15:49:56 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Patch: 001/006] pgdat allocation for new node add (specify
 node id)
Message-Id: <20060420154956.1aa4acbe.akpm@osdl.org>
In-Reply-To: <20060420190338.EE4A.Y-GOTO@jp.fujitsu.com>
References: <20060420185123.EE48.Y-GOTO@jp.fujitsu.com>
	<20060420190338.EE4A.Y-GOTO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Yasunori Goto <y-goto@jp.fujitsu.com> wrote:
>
> +int add_memory(int nid, u64 start, u64 size)
>  +{
>  +	int ret;
>  +
>  +	/* call arch's memory hotadd */
>  +	ret = arch_add_memory(nid, start, size;
>  +
>  +	return ret;
>  +}

So this patch is missing a ), but your later patch which touches this code
actually has the ).  Which tells me that this isn't the correct version of
this patch.

I'll fix that all up, but I would ask you to carefully verify that the
patches which I merged are the ones which you meant to send, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
