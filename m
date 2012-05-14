Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 9368C6B004D
	for <linux-mm@kvack.org>; Sun, 13 May 2012 20:30:35 -0400 (EDT)
Date: Sun, 13 May 2012 20:30:06 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: [Bug 43227] New: BUG: Bad page state in process wcg_gfam_6.11_i
Message-ID: <20120514003006.GB13658@redhat.com>
References: <bug-43227-27@https.bugzilla.kernel.org/>
 <20120511125921.a888e12c.akpm@linux-foundation.org>
 <alpine.LSU.2.00.1205111419060.1288@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1205111419060.1288@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, sliedes@cc.hut.fi

On Fri, May 11, 2012 at 02:30:42PM -0700, Hugh Dickins wrote:
 
 > > when the page was freed, not when it was reused!  Can anyone think of a
 > > reason why PAGE_FLAGS_CHECK_AT_FREE doesn't include these flags (at
 > > least)?
 > Because those flags may validly be set when a page is freed (I do have an
 > old patch to change anon dirty handling to stop that, but it's not really
 > needed).

It would be nice to be able to distinguish from things like random memory
scribbles setting those flags.

 > The only thought I have on this report: what binutils was used to build
 > this kernel?  We had "Bad page" and isolate_lru_pages BUG reports at the
 > start of the month, and they were traced to buggy binutils 2.22.52.0.2

The fedora reports we have are from binutils prior to that (2.21.53.0.1 is
the newest we have in F16 for eg).

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
