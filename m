Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id A79646B0083
	for <linux-mm@kvack.org>; Tue, 17 Apr 2012 14:30:45 -0400 (EDT)
Date: Tue, 17 Apr 2012 20:30:42 +0200
From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: Weirdness in __alloc_bootmem_node_high
Message-ID: <20120417183042.GA21051@merkur.ravnborg.org>
References: <20120417155502.GE22687@tiehlicka.suse.cz> <CAE9FiQXWKzv7Wo4iWGrKapmxQYtAGezghwup1UKoW2ghqUSr+A@mail.gmail.com> <20120417173203.GA32482@tiehlicka.suse.cz> <CAE9FiQXvZ4eSCwMSG2H7CC6suQe37TmQpmOEKW_082W3zz-6Fw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAE9FiQXvZ4eSCwMSG2H7CC6suQe37TmQpmOEKW_082W3zz-6Fw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, Apr 17, 2012 at 11:07:10AM -0700, Yinghai Lu wrote:
> On Tue, Apr 17, 2012 at 10:32 AM, Michal Hocko <mhocko@suse.cz> wrote:
> > On Tue 17-04-12 10:12:30, Yinghai Lu wrote:
> >>
> >> We are not using bootmem with x86 now, so could remove those workaround now.
> >
> > Could you be more specific about what the workaround is used for?
> 
> Don't bootmem allocating too low to use up all low memory. like for
> system with lots of memory for sparse vmemmap.
> 
> when nobootmem.c is used, __alloc_bootmem_node_high is the same as
> __alloc_bootmem_node.

It would be nice if someone familiar with the memblock/bootmem
internals could cleans up the leftovers from the migration
of x86 to memblock / nobootmem.

This would be less to be confused about when other migrate to
use memblock.

	Sam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
