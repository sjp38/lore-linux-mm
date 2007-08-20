Subject: Re: [RFC 7/7] Switch of PF_MEMALLOC during writeout
References: <20070820215040.937296148@sgi.com>
	<20070820215317.441134723@sgi.com>
From: Andi Kleen <andi@firstfloor.org>
Date: 21 Aug 2007 01:08:06 +0200
In-Reply-To: <20070820215317.441134723@sgi.com>
Message-ID: <p73ps1hztwp.fsf@bingen.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@sgi.com> writes:

> Switch off PF_MEMALLOC during both direct and kswapd reclaim.
> 
> This works because we are not holding any locks at that point because
> reclaim is essentially complete. The write occurs when the memory on
> the zones is at the high water mark so it is unlikely that writeout
> will get into trouble. If so then reclaim can be called recursively to
> reclaim more pages.

What would stop multiple recursions in extreme low memory cases? Seems 
risky to me and risking stack overflow.  Perhaps define another flag to catch that?

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
