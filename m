Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id E65376B0033
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 10:01:59 -0400 (EDT)
Date: Fri, 28 Jun 2013 09:43:25 -0400
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [PATCH v2] vmpressure: implement strict mode
Message-ID: <20130628094325.45f5139b@redhat.com>
In-Reply-To: <20130628043411.GA9100@teo>
References: <20130626231712.4a7392a7@redhat.com>
	<20130627150231.2bc00e3efcd426c4beef894c@linux-foundation.org>
	<20130628000201.GB15637@bbox>
	<20130627173433.d0fc6ecd.akpm@linux-foundation.org>
	<20130628005852.GA8093@teo>
	<20130627181353.3d552e64.akpm@linux-foundation.org>
	<20130628043411.GA9100@teo>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anton Vorontsov <anton@enomsg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.cz, kmpark@infradead.org, hyunhee.kim@samsung.com

On Thu, 27 Jun 2013 21:34:11 -0700
Anton Vorontsov <anton@enomsg.org> wrote:

> On Thu, Jun 27, 2013 at 06:13:53PM -0700, Andrew Morton wrote:
> > On Thu, 27 Jun 2013 17:58:53 -0700 Anton Vorontsov <anton@enomsg.org> wrote:
> > > Current frequency is 1/(2MB). Suppose we ended up scanning the whole
> > > memory on a 2GB host, this will give us 1024 hits. Doesn't feel too much*
> > > to me... But for what it worth, I am against adding read() to the
> > > interface -- just because we can avoid the unnecessary switch into the
> > > kernel.
> > 
> > What was it they said about premature optimization?
> > 
> > I think I'd rather do nothing than add a mode hack (already!).
> > 
> > The information Luiz wants is already available with the existing
> > interface, so why not just use it until there is a real demonstrated
> > problem?
> > 
> > But all this does point at the fact that the chosen interface was not a
> > good one.  And it's happening so soon :( A far better interface would
> > be to do away with this level filtering stuff in the kernel altogether.
> 
> OK, I am convinced that modes might be not necessary, but I see no big
> problem in current situation, we can add the strict mode and deprecate the
> "filtering" -- basically we'll implement the idea of requiring that
> userspace registers a separate fd for each level.

Agreed this is a good solution.

> As one of the ways to change the interface, we can do the strict mode by
> writing levels in uppercase, and warn_once on lowercase levels, describing
> that the old behaviour will go away. Once (if ever) we remove the old
> behaviour, the apps trying the old-style lowercase levels will fail
> gracefully with EINVAL.

Why don't we just break it? There's no non-development kernel released
with this interface yet.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
