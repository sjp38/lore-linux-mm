Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 7CA8B6B006E
	for <linux-mm@kvack.org>; Thu,  7 Jun 2012 20:53:14 -0400 (EDT)
Received: by bkcjm19 with SMTP id jm19so1643842bkc.14
        for <linux-mm@kvack.org>; Thu, 07 Jun 2012 17:53:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120608002451.GA821@redhat.com>
References: <20120608002451.GA821@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 7 Jun 2012 17:52:52 -0700
Message-ID: <CA+55aFzivM8Z1Bjk3Qo2vtnQhCQ7fQ4rf_a+EXY7noXQcxL_CA@mail.gmail.com>
Subject: Re: a whole bunch of crashes since todays -mm merge.
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Thu, Jun 7, 2012 at 5:24 PM, Dave Jones <davej@redhat.com> wrote:
> I just started seeing crashes while doing simple things, like logging on a console..

I'm looking at it right now, and the sync_mm_rss() patch is pure
garbage. In many ways.

You can't do sync_mm_rss() from mmdrop(), because there's no reason to
believe that the task that does mmdrop() does it on its own active_mm.
And even if you *could* do it there, it's still horribly wrong,
because it does it at the end *after* it already freed the mm!

Does it go away if you revert that (commit 40af1bbdca47). I wish I
hadn't merged it, or that I had noticed how horrible it was before I
pushed out.

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
