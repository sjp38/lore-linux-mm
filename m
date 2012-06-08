Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id C7A376B006E
	for <linux-mm@kvack.org>; Thu,  7 Jun 2012 21:04:34 -0400 (EDT)
Date: Thu, 7 Jun 2012 18:05:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: a whole bunch of crashes since todays -mm merge.
Message-Id: <20120607180515.4afffc89.akpm@linux-foundation.org>
In-Reply-To: <CA+55aFzivM8Z1Bjk3Qo2vtnQhCQ7fQ4rf_a+EXY7noXQcxL_CA@mail.gmail.com>
References: <20120608002451.GA821@redhat.com>
	<CA+55aFzivM8Z1Bjk3Qo2vtnQhCQ7fQ4rf_a+EXY7noXQcxL_CA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Konstantin Khlebnikov <khlebnikov@openvz.org>, Oleg Nesterov <oleg@redhat.com>

On Thu, 7 Jun 2012 17:52:52 -0700 Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Thu, Jun 7, 2012 at 5:24 PM, Dave Jones <davej@redhat.com> wrote:
> > I just started seeing crashes while doing simple things, like logging on a console..
> 
> I'm looking at it right now, and the sync_mm_rss() patch is pure
> garbage. In many ways.
> 
> You can't do sync_mm_rss() from mmdrop(), because there's no reason to
> believe that the task that does mmdrop() does it on its own active_mm.
> And even if you *could* do it there, it's still horribly wrong,
> because it does it at the end *after* it already freed the mm!
> 
> Does it go away if you revert that (commit 40af1bbdca47). I wish I
> hadn't merged it, or that I had noticed how horrible it was before I
> pushed out.
> 

It appears this is due to me fat-fingering conflict resolution last
week.  That hunk is supposed to be in mm_release(), not mmput().    

It's probably best to throw the patch away for now - we'll try again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
