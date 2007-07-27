Subject: Re: [patch][rfc] 2.6.23-rc1 mm: NUMA replicated pagecache
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070727084252.GA9347@wotan.suse.de>
References: <20070727084252.GA9347@wotan.suse.de>
Content-Type: text/plain
Date: Fri, 27 Jul 2007 10:30:47 -0400
Message-Id: <1185546647.5069.17.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Joachim Deguara <joachim.deguara@amd.com>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2007-07-27 at 10:42 +0200, Nick Piggin wrote:
> Hi,
> 
> Just got a bit of time to take another look at the replicated pagecache
> patch. The nopage vs invalidate race and clear_page_dirty_for_io fixes
> gives me more confidence in the locking now; the new ->fault API makes
> MAP_SHARED write faults much more efficient; and a few bugs were found
> and fixed.
> 
> More stats were added: *repl* in /proc/vmstat. Survives some kbuilding
> tests...
> 
> --
> 
> Page-based NUMA pagecache replication.
<snip really big patch!>

Hi, Nick.

Glad to see you're back on this.  It's been on my list, but delayed by
other patch streams...

As I mentioned to you in prior mail, I want to try to integrate this
atop my "auto/lazy migration" patches, such that when a task moves to a
new node, we remove just that task's pte ref's to page cache pages
[along with all refs to anon pages, as I do now] so that the task will
take a fault on next touch and either use an existing local copy or
replicate the page at that time.  Unfortunately, that's in the queue
behind the memoryless node patches and my stalled shared policy patches,
among other things :-(.

Also, what kernel is this patch against?  Diffs just say "linux-2.6".
Somewhat ambiguous...

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
