Date: Sun, 2 Mar 2008 17:42:35 +0000
From: Rick van Rein <rick@vanrein.org>
Subject: Re: [PATCH 2.6.24] mm: BadRAM support for broken memory
Message-ID: <20080302174235.GA26902@phantom.vanrein.org>
References: <20080302134221.GA25196@phantom.vanrein.org> <2f11576a0803020901n715fda8esbfc0172f5a15ae3c@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2f11576a0803020901n715fda8esbfc0172f5a15ae3c@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <m-kosaki@ceres.dti.ne.jp>
Cc: Rick van Rein <rick@vanrein.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hello Kosaki,

> in general,
> Agreed with we need bad memory treatness.

Glad to hear that.

> >  +#define PG_badram              20      /* BadRam page */
> 
> some architecture use PG_reserved for treat bad memory.
> Why do you want introduce new page flag?

It is clearer to properly name a flag, I suppose.
Is the use that you are mentioning the intended, and only use of the flag?
If not, I think it is clearer to use a separate flag instead of overloading
one.

> for show_mem() improvement?

For code clarity.


Thanks,
 -Rick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
