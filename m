Date: Mon, 22 Nov 2004 18:25:15 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: page fault scalability patch V11 [0/7]: overview
Message-ID: <20041123022515.GJ2714@holomorphy.com>
References: <20041119225701.0279f846.akpm@osdl.org> <419EEE7F.3070509@yahoo.com.au> <1834180000.1100969975@[10.10.2.4]> <Pine.LNX.4.58.0411200911540.20993@ppc970.osdl.org> <20041120190818.GX2714@holomorphy.com> <Pine.LNX.4.58.0411201112200.20993@ppc970.osdl.org> <20041120193325.GZ2714@holomorphy.com> <Pine.LNX.4.58.0411220932270.22144@schroedinger.engr.sgi.com> <20041122224333.GI2714@holomorphy.com> <Pine.LNX.4.58.0411221450500.22895@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0411221450500.22895@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Linus Torvalds <torvalds@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@osdl.org>, benh@kernel.crashing.org, hugh@veritas.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 22 Nov 2004, William Lee Irwin III wrote:
>> The specific patches you compared matter a great deal as there are
>> implementation blunders (e.g. poor placement of counters relative to
>> ->mmap_sem) that can ruin the results. URL's to the specific patches
>> would rule out that source of error.

On Mon, Nov 22, 2004 at 02:51:22PM -0800, Christoph Lameter wrote:
> I mentioned V4 of this patch which was posted to lkml. A simple search
> should get you there.

The counter's placement was poor in that version of the patch. The
results are very suspect and likely invalid. It would have been more
helpful if you provided some kind of unique identifier when requests
for complete disambiguation are made. For instance, the version tags of
your patches are not visible in Subject: lines.

There are, of course, other issues, e.g. where the arch sweeps went.
This discussion has degenerated into non-cooperation making it beyond
my power to help, and I'm in the midst of several rather urgent
bughunts, of which there are apparently more to come.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
