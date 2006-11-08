Date: Wed, 8 Nov 2006 10:56:48 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] Fix sys_move_pages when a NULL node list is passed.
Message-Id: <20061108105648.4a149cca.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20061103144243.4601ba76.sfr@canb.auug.org.au>
References: <20061103144243.4601ba76.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: clameter@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

On Fri, 3 Nov 2006 14:42:43 +1100
Stephen Rothwell <sfr@canb.auug.org.au> wrote:

> +		} else
> +			pm[i].node = 0;	/* anything to not match MAX_NUMNODES */
>  	}
>  	/* End marker */
>  	pm[nr_pages].node = MAX_NUMNODES;

I think node0 is always online...but this should be

pm[i].node = first_online_node; // /* any online node */

maybe.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
