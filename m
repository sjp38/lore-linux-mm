Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 959B16B006E
	for <linux-mm@kvack.org>; Thu,  7 Jun 2012 21:00:13 -0400 (EDT)
Date: Thu, 7 Jun 2012 21:00:08 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: a whole bunch of crashes since todays -mm merge.
Message-ID: <20120608010008.GA7191@redhat.com>
References: <20120608002451.GA821@redhat.com>
 <CA+55aFzivM8Z1Bjk3Qo2vtnQhCQ7fQ4rf_a+EXY7noXQcxL_CA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzivM8Z1Bjk3Qo2vtnQhCQ7fQ4rf_a+EXY7noXQcxL_CA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Thu, Jun 07, 2012 at 05:52:52PM -0700, Linus Torvalds wrote:
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

Hmm, I did a rebuild with a r8169 debug patch Francois sent me backed out,
and now it looks like it's fine again.

Or I might just be getting lucky..

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
