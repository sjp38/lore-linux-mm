Date: Thu, 7 Nov 2002 14:46:25 -0500
From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: Usage of get_user_pages() in fs/aio.c
Message-ID: <20021107144625.B30214@redhat.com>
References: <20021106211538.M659@nightmaster.csn.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20021106211538.M659@nightmaster.csn.tu-chemnitz.de>; from ingo.oeser@informatik.tu-chemnitz.de on Wed, Nov 06, 2002 at 09:15:38PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Nov 06, 2002 at 09:15:38PM +0100, Ingo Oeser wrote:
> What this can cause is clear ;-)
> 
> Simple fix would be to replace "info->mmap_size" with "nr_pages",
> that you compute just some lines above.

Whoops.  Yeah, that's a bug.  It hasn't actually been noticed in 
testing because the array of pages is freshly allocated from mmap 
and thus stops filling the array at nr_pages, but it could be 
exploited by a hostile user.  I'll feed that patch up asap.

		-ben
-- 
"Do you seek knowledge in time travel?"
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
