Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id CC1626B004D
	for <linux-mm@kvack.org>; Wed, 30 Nov 2011 07:06:08 -0500 (EST)
Date: Wed, 30 Nov 2011 20:06:03 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/9] readahead: snap readahead request to EOF
Message-ID: <20111130120603.GA19834@localhost>
References: <20111129130900.628549879@intel.com>
 <20111129131456.145362960@intel.com>
 <20111129142958.GJ5635@quack.suse.cz>
 <20111130010604.GD11147@localhost>
 <20111130113719.GC4541@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111130113719.GC4541@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Linux Memory Management List <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

> > +	/* snap to EOF */
> > +	size += min(size, ra->ra_pages / 4);
>   I'd probably choose:
> 	size += min(size / 2, ra->ra_pages / 4);
>   to increase current window only to 3/2 and not twice but I don't have a

OK it looks good on large ra_pages. I'll use this form.

> strong opinion. Otherwise I think the code is fine now so you can add:
>   Acked-by: Jan Kara <jack@suse.cz>

Thanks! 

Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
