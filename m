Date: Sun, 21 Nov 2004 13:13:43 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH]: 2/4 mm/swap.c cleanup
Message-Id: <20041121131343.333716cd.akpm@osdl.org>
In-Reply-To: <16800.47052.733779.713175@gargle.gargle.HOWL>
References: <16800.47052.733779.713175@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <nikita@clusterfs.com>
Cc: Linux-Kernel@vger.kernel.org, AKPM@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nikita Danilov <nikita@clusterfs.com> wrote:
>
> +#define pagevec_for_each_page(_v, _i, _p, _z)				\
>  +for (_i = 0, _z = NULL;							\
>  +     ((_i) < pagevec_count(_v) && (__guardloop(_v, _i, _p, _z), 1)) ||	\
>  +     (__postloop(_v, _i, _p, _z), 0);					\
>  +     (_i)++)

Sorry, this looks more like a dirtyup to me ;)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
