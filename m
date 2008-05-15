Date: Thu, 15 May 2008 18:37:37 +0100
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: [PATCH 3/3] slob: record page flag overlays explicitly
Message-ID: <20080515173737.GA21787@shadowen.org>
References: <exportbomb.1210871946@pinky> <1210872010.0@pinky>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1210872010.0@pinky>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Jeremy Fitzhardinge <jeremy@goop.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, May 15, 2008 at 06:20:10PM +0100, Andy Whitcroft wrote:

>  static inline void clear_slob_page(struct slob_page *sp)
>  {
> -	__clear_bit(PG_active, &sp->flags);
> +	__clear_bit(PG_slob_free, &sp->flags);
>  }

Bah, this hunk is wrong.  Seems this is not the latest version.  Will
replace this patch momentarily.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
