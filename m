Subject: Re: [patch] generic nonlinear mappings, 2.5.44-mm2-D0
From: "David S. Miller" <davem@rth.ninka.net>
In-Reply-To: <Pine.LNX.4.44.0210221936010.18790-100000@localhost.localdomain>
References: <Pine.LNX.4.44.0210221936010.18790-100000@localhost.localdomain>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 22 Oct 2002 15:27:55 -0700
Message-Id: <1035325675.16084.11.camel@rth.ninka.net>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@zip.com.au>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2002-10-22 at 10:57, Ingo Molnar wrote:
> -	flush_tlb_page(vma, addr);
> +	if (flush)
> +		flush_tlb_page(vma, addr);

You're still using page level flushes, even though we agreed that
a range flush one level up was more appropriate.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
