Date: Wed, 13 Oct 2004 16:39:55 +1000
From: Nathan Scott <nathans@sgi.com>
Subject: Re: Page cache write performance issue
Message-ID: <20041013063955.GA2079@frodo>
References: <20041013054452.GB1618@frodo> <20041012231945.2aff9a00.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20041012231945.2aff9a00.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: piggin@cyberone.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-xfs@oss.sgi.com
List-ID: <linux-mm.kvack.org>

Hi Andrew,

On Tue, Oct 12, 2004 at 11:19:45PM -0700, Andrew Morton wrote:
> Nathan Scott <nathans@sgi.com> wrote:
> >
> >  So, any ideas what happened to 2.6.9?
> 
> Does reverting the below fix it up?

Reverting that one improves things slightly - I move up from
~4MB/sec to ~17MB/sec; thats just under a third of the 2.6.8
numbers I was seeing though, unfortunately.

cheers.

-- 
Nathan
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
