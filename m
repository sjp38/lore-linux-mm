Return-Path: <owner-linux-mm@kvack.org>
Date: Fri, 28 Mar 2014 13:22:29 -0400
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: git pull -- [PATCH] aio: v2 ensure access to ctx->ring_pages is correctly serialised
Message-ID: <20140328172229.GH29656@kvack.org>
References: <20140327134653.GA22407@kvack.org> <CA+55aFzFgY4-26SO-MsFagzaj9JevkeeT1OJ3pjj-tcjuNCEeQ@mail.gmail.com> <CA+55aFx7vg2rvOu6Bu_e8+BB=ymoUMp0AM9JmAuUuSgo0LVEwg@mail.gmail.com> <20140327200851.GL17679@kvack.org> <CA+55aFy_sRnFu7KguAUAN5kbHk3Qa_0ZuATPU5i8LOyMMWZ_5g@mail.gmail.com> <20140327205749.GM17679@kvack.org> <CA+55aFyj2XFMkT1T=EPPw1CANt6atyFNmMaeaDm-p-NWfRNA+w@mail.gmail.com> <20140328145826.GE29656@kvack.org> <CA+55aFyye6K4ifJ778uZ_pNFKa7=R0KsKREmJkimEQxW3nDhDA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFyye6K4ifJ778uZ_pNFKa7=R0KsKREmJkimEQxW3nDhDA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Sasha Levin <sasha.levin@oracle.com>, Tang Chen <tangchen@cn.fujitsu.com>, Gu Zheng <guz.fnst@cn.fujitsu.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, stable <stable@vger.kernel.org>, linux-aio@kvack.org, linux-mm <linux-mm@kvack.org>

On Fri, Mar 28, 2014 at 10:08:47AM -0700, Linus Torvalds wrote:
> On Fri, Mar 28, 2014 at 7:58 AM, Benjamin LaHaise <bcrl@kvack.org> wrote:
> >
> > Here's a respin of that part.  I just moved the mutex initialization up so
> > that it's always valid in the err path.  I have also run this version of
> > the patch through xfstests and my migration test programs and it looks
> > okay.
> 
> Ok. I can't find any issues with this version. How critical is this?
> Should I take it now, or with more testing during the 3.15 merge
> window and then just have it picked up from stable? Do people actually
> trigger the bug in real life, or has this been more of a
> trinity/source code analysis thing?

I believe it was found by analysis.  I'd be okay with it baking for another 
week or two before pushing it to stable, as that gives the folks running 
various regression tests some more time to chime in.  Better to get it 
right than to have to push another fix.

		-ben
-- 
"Thought is the essence of where you are now."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
