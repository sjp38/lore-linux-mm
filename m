Subject: Re: [Lhms-devel] [RFC] buddy allocator without bitmap  [2/4]
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <412DD1AA.8080408@jp.fujitsu.com>
References: <412DD1AA.8080408@jp.fujitsu.com>
Content-Type: text/plain
Message-Id: <1093535402.2984.11.camel@nighthawk>
Mime-Version: 1.0
Date: Thu, 26 Aug 2004 08:50:02 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lhms <lhms-devel@lists.sourceforge.net>, William Lee Irwin III <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2004-08-26 at 05:03, Hiroyuki KAMEZAWA wrote:
> -		MARK_USED(index + size, high, area);
> +		page[size].flags |= (1 << PG_private);
> +		page[size].private = high;
>   	}
>   	return page;
>   }
...
> +		/* Atomic operation is needless here */
> +		page->flags &= ~(1 << PG_private);

See linux/page_flags.h:

#define SetPagePrivate(page)    set_bit(PG_private, &(page)->flags)
#define ClearPagePrivate(page)  clear_bit(PG_private, &(page)->flags)
#define PagePrivate(page)       test_bit(PG_private, &(page)->flags)

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
