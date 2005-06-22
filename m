Date: Tue, 21 Jun 2005 18:41:21 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.6.12-mm1 & 2K lun testing  (JFS problem ?)
Message-ID: <20050622014121.GB10690@holomorphy.com>
References: <1118856977.4301.406.camel@dyn9047017072.beaverton.ibm.com> <20050616002451.01f7e9ed.akpm@osdl.org> <1118951458.4301.478.camel@dyn9047017072.beaverton.ibm.com> <20050616133730.1924fca3.akpm@osdl.org> <1118965381.4301.488.camel@dyn9047017072.beaverton.ibm.com> <20050616175130.22572451.akpm@osdl.org> <42B2E7D2.9080705@us.ibm.com> <20050617141331.078e5f8f.akpm@osdl.org> <1119400494.4620.33.camel@dyn9047017102.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1119400494.4620.33.camel@dyn9047017102.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, shaggy@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 21, 2005 at 05:34:54PM -0700, Badari Pulavarty wrote:
> Hi Andrew & Shaggy,
> Here is the summary of 2K lun testing on 2.6.12-mm1.
> When I tune dirty ratios and CFQ queue depths, things
> seems to be running fine.
> 	echo 20 > /proc/sys/vm/dirty_ratio
> 	echo 20 > /proc/sys/vm/overcommit_ratio
> 	echo 4 > /sys/block/<device>/queue/nr_requests
> But, I am running into JFS problem. I can't kill my
> "dd" process. They all get stuck in:
> (I am going to try ext3).

If you could get unabridged profiling data for raw vs. fs (so it can
be properly sorted) I would be interested in that. Early indications
were large amounts of time spent in shrink_zone(), obtained by
re-sorting the truncated profile listings. It indicated the time spent
in shrink_zone() was 26.3 times as much time spent in default_idle().
Typically copying to and from userspace are enormous overheads, but
aren't observable in the truncated/mis-sorted profiles, which calls
them into question, barring unreported usage of O_DIRECT. There are
also no totals reported, which are helpful for interpreting realtime
behavior.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
