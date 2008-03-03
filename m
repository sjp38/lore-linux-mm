Date: Mon, 03 Mar 2008 12:21:27 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2.6.24] mm: BadRAM support for broken memory
In-Reply-To: <20080302174235.GA26902@phantom.vanrein.org>
References: <2f11576a0803020901n715fda8esbfc0172f5a15ae3c@mail.gmail.com> <20080302174235.GA26902@phantom.vanrein.org>
Message-Id: <20080303121335.1E7B.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rick van Rein <rick@vanrein.org>
Cc: kosaki.motohiro@jp.fujitsu.com, KOSAKI Motohiro <m-kosaki@ceres.dti.ne.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi Rick

> > >  +#define PG_badram              20      /* BadRam page */
> > 
> > some architecture use PG_reserved for treat bad memory.
> > Why do you want introduce new page flag?
> 
> It is clearer to properly name a flag, I suppose.
> Is the use that you are mentioning the intended, and only use of the flag?
> If not, I think it is clearer to use a separate flag instead of overloading
> one.

hmmm
unfortunately flag bit of struct page is very valuable resource
rather than diamond on current implementaion ;-)

if you can change to no introduce new page flag,
IMHO merge to mainline dramatically become easy.


> > for show_mem() improvement?
> 
> For code clarity.

agreed with your code is clarify. but...



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
