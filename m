Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id B97AD6B004A
	for <linux-mm@kvack.org>; Tue, 17 Apr 2012 17:33:18 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so10237960pbc.14
        for <linux-mm@kvack.org>; Tue, 17 Apr 2012 14:33:18 -0700 (PDT)
Date: Tue, 17 Apr 2012 14:33:13 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: Weirdness in __alloc_bootmem_node_high
Message-ID: <20120417213313.GC19975@google.com>
References: <20120417155502.GE22687@tiehlicka.suse.cz>
 <CAE9FiQXWKzv7Wo4iWGrKapmxQYtAGezghwup1UKoW2ghqUSr+A@mail.gmail.com>
 <20120417173203.GA32482@tiehlicka.suse.cz>
 <CAE9FiQXvZ4eSCwMSG2H7CC6suQe37TmQpmOEKW_082W3zz-6Fw@mail.gmail.com>
 <20120417183042.GA21051@merkur.ravnborg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120417183042.GA21051@merkur.ravnborg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sam Ravnborg <sam@ravnborg.org>
Cc: Yinghai Lu <yinghai@kernel.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hello, Sam.

On Tue, Apr 17, 2012 at 08:30:42PM +0200, Sam Ravnborg wrote:
> It would be nice if someone familiar with the memblock/bootmem
> internals could cleans up the leftovers from the migration
> of x86 to memblock / nobootmem.
> 
> This would be less to be confused about when other migrate to
> use memblock.

I can't remember the details now (my memory sucks big time) but there
were some obstacles and I decided to defer cleaning up.  I'm kinda
overwhelmed in other areas so if anyone is interested in cleaning up,
I'll be happy to help.  If not, I'll try to get to it.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
