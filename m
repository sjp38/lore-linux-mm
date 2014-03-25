Return-Path: <owner-linux-mm@kvack.org>
Date: Tue, 25 Mar 2014 14:57:27 -0400
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [PATCH] aio: ensure access to ctx->ring_pages is correctly serialised
Message-ID: <20140325185727.GU4173@kvack.org>
References: <532A80B1.5010002@cn.fujitsu.com> <20140320143207.GA3760@redhat.com> <20140320163004.GE28970@kvack.org> <532B9C54.80705@cn.fujitsu.com> <20140321183509.GC23173@kvack.org> <533077CE.6010204@oracle.com> <20140324190743.GJ4173@kvack.org> <5331C13C.8030507@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5331C13C.8030507@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Gu Zheng <guz.fnst@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Dave Jones <davej@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, jmoyer@redhat.com, kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, miaox@cn.fujitsu.com, linux-aio@kvack.org, fsdevel <linux-fsdevel@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi Sasha,

On Tue, Mar 25, 2014 at 01:47:40PM -0400, Sasha Levin wrote:
> On 03/24/2014 03:07 PM, Benjamin LaHaise wrote:
...
> >Yeah, that's a problem -- thanks for the report.  The ring_lock mutex can't
> >be nested inside of mmap_sem, as aio_read_events_ring() can take a page
> >fault while holding ring_mutex.  That makes the following change required.
> >I'll fold this change into the patch that caused this issue.
> 
> Yup, that does the trick.
> 
> Could you please add something to document why this is a trylock instead of 
> a lock? If
> I were reading the code there's no way I'd understand what's the reason 
> behind it
> without knowing of this bug report.

Done.  I've updated the patch in my aio-next.git tree, so it should be in 
tomorrow's linux-next, and will give it one last day for any further problem 
reports.  Thanks for testing!

		-ben

> Thanks,
> Sasha

-- 
"Thought is the essence of where you are now."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
