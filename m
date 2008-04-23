Date: Wed, 23 Apr 2008 17:34:04 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 00/18] multi size, and giant hugetlb page support, 1GB hugetlb for x86
Message-ID: <20080423153404.GB16769@wotan.suse.de>
References: <20080423015302.745723000@nick.local0.net> <480EEDD9.2010601@firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <480EEDD9.2010601@firstfloor.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, kniht@linux.vnet.ibm.com, nacc@us.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Wed, Apr 23, 2008 at 10:05:45AM +0200, Andi Kleen wrote:
> 
> > Testing-wise, I've changed the registration mechanism so that if you specify
> > hugepagesz=1G on the command line, then you do not get the 2M pages by default
> > (you have to also specify hugepagesz=2M). Also, when only one hstate is
> > registered, all the proc outputs appear unchanged, so this makes it very easy
> > to test with.
> 
> Are you sure that's a good idea? Just replacing the 2M count in meminfo
> with 1G pages is not fully compatible proc ABI wise I think.

Not sure that it is a good idea, but it did allow the test suite to pass
more tests ;)

What the best option is for backwards compatibility, I don't know. I
think this approach would give things a better chance of actually
working with 1G hugepags and old userspace, but it probably also
increases the chances of funny bugs.


> I think rather that applications who only know about 2M pages should
> see "0" in this case and not be confused by larger pages. And only
> applications who are multi page size aware should see the new page
> sizes.
> 
> If you prefer it you could move all the new page sizes to sysfs
> and only ever display the "legacy page size" in meminfo,
> but frankly I personally prefer the quite simple and comparatively
> efficient /proc/meminfo with multiple numbers interface.

Well I've chance it so it just has single numbers if a single hstate
is registered: that way we're completely backwards compatible in the
case of only using 2M pages.

But I think your multiple hstates in /proc/meminfo isn't too bad
given the bad situation. Maybe just adding more meminfo lines would
be better though?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
