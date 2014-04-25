From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: Dirty/Access bits vs. page content
Date: Fri, 25 Apr 2014 12:41:40 +1000
Message-ID: <1398393700.8437.22.camel@pasglop>
References: <53558507.9050703@zytor.com>
	 <CA+55aFxGm6J6N=4L7exLUFMr1_siNGHpK=wApd9GPCH1=63PPA@mail.gmail.com>
	 <53559F48.8040808@intel.com>
	 <CA+55aFwDtjA4Vp0yt0K5x6b6sAMtcn=61SEnOOs_En+3UXNpuA@mail.gmail.com>
	 <CA+55aFzFxBDJ2rWo9DggdNsq-qBCr11OVXnm64jx04KMSVCBAw@mail.gmail.com>
	 <20140422075459.GD11182@twins.programming.kicks-ass.net>
	 <CA+55aFzM+NpE-EzJdDeYX=cqWRzkGv9o-vybDR=oFtDLMRK-mA@mail.gmail.com>
	 <alpine.LSU.2.11.1404221847120.1759@eggly.anvils>
	 <20140423184145.GH17824@quack.suse.cz>
	 <CA+55aFwm9BT4ecXF7dD+OM0-+1Wz5vd4ts44hOkS8JdQ74SLZQ@mail.gmail.com>
	 <20140424065133.GX26782@laptop.programming.kicks-ass.net>
	 <alpine.LSU.2.11.1404241110160.2443@eggly.anvils>
	 <CA+55aFwVgCshsVHNqr2EA1aFY18A2L17gNj0wtgHB39qLErTrg@mail.gmail.com>
	 <alpine.LSU.2.11.1404241252520.3455@eggly.anvils>
	 <CA+55aFyUyD_BASjhig9OPerYcMrUgYJUfRLA9JyB_x7anV1d7Q@mail.gmail.com>
	 <1398389846.8437.6.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <1398389846.8437.6.camel@pasglop>
Sender: linux-arch-owner@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Dave Hansen <dave.hansen@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Tony Luck <tony.luck@intel.com>
List-Id: linux-mm.kvack.org

On Fri, 2014-04-25 at 11:37 +1000, Benjamin Herrenschmidt wrote:
> On Thu, 2014-04-24 at 16:46 -0700, Linus Torvalds wrote:
> > - we do the TLB shootdown holding the page table lock (but that's not
> > new - ptep_get_and_flush does the same
> > 
> 
> The flip side is that we do a lot more IPIs for large invalidates,
> since we drop the PTL on every page table page.

Oh I missed that your patch was smart enough to only do that in the
presence of non-anonymous dirty pages. That should take care of the
common case of short lived programs, those should still fit in a
single big batch.

Cheers,
Ben.
