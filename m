Date: Wed, 17 Jan 2007 10:44:19 +1100
From: David Chinner <dgc@sgi.com>
Subject: Re: [RFC 0/8] Cpuset aware writeback
Message-ID: <20070116234419.GS44411608@melbourne.sgi.com>
References: <20070116054743.15358.77287.sendpatchset@schroedinger.engr.sgi.com> <20070116135325.3441f62b.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070116135325.3441f62b.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Christoph Lameter <clameter@sgi.com>, menage@google.com, linux-kernel@vger.kernel.org, nickpiggin@yahoo.com.au, linux-mm@kvack.org, ak@suse.de, pj@sgi.com, dgc@sgi.com
List-ID: <linux-mm.kvack.org>

On Tue, Jan 16, 2007 at 01:53:25PM -0800, Andrew Morton wrote:
> > On Mon, 15 Jan 2007 21:47:43 -0800 (PST) Christoph Lameter
> > <clameter@sgi.com> wrote:
> >
> > Currently cpusets are not able to do proper writeback since dirty ratio
> > calculations and writeback are all done for the system as a whole.
> 
> We _do_ do proper writeback.  But it's less efficient than it might be, and
> there's an NFS problem.
> 
> > This may result in a large percentage of a cpuset to become dirty without
> > writeout being triggered. Under NFS this can lead to OOM conditions.
> 
> OK, a big question: is this patchset a performance improvement or a
> correctness fix?  Given the above, and the lack of benchmark results I'm
> assuming it's for correctness.

Given that we've already got a 25-30% buffered write performance
degradation between 2.6.18 and 2.6.20-rc4 for simple sequential
write I/O to multiple filesystems concurrently, I'd really like
to see some serious I/O performance regression testing on this
change before it goes anywhere.

Cheers,

Dave.
-- 
Dave Chinner
Principal Engineer
SGI Australian Software Group

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
