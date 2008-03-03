From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH 2.6.24] mm: BadRAM support for broken memory
Date: Mon, 3 Mar 2008 16:32:47 +1100
References: <20080302134221.GA25196@phantom.vanrein.org> <2f11576a0803020901n715fda8esbfc0172f5a15ae3c@mail.gmail.com>
In-Reply-To: <2f11576a0803020901n715fda8esbfc0172f5a15ae3c@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200803031632.47888.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <m-kosaki@ceres.dti.ne.jp>
Cc: Rick van Rein <rick@vanrein.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Monday 03 March 2008 04:01, KOSAKI Motohiro wrote:
> Hi
>
> in general,
> Agreed with we need bad memory treatness.
>
> >  +#define PG_badram              20      /* BadRam page */
>
> some architecture use PG_reserved for treat bad memory.
> Why do you want introduce new page flag?
> for show_mem() improvement?

I'd like to get rid of PG_reserved at some point. So I'd
rather not overload it with more meanings ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
