From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [Approach #2] [RFC][PATCH] Remove cgroup member from struct page
Date: Thu, 11 Sep 2008 07:02:44 +1000
References: <48C66AF8.5070505@linux.vnet.ibm.com> <200809110644.39334.nickpiggin@yahoo.com.au> <20080910200304.fd078007.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080910200304.fd078007.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200809110702.45003.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>, hugh@veritas.com, menage@google.com, xemul@openvz.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday 10 September 2008 21:03, KAMEZAWA Hiroyuki wrote:
> On Thu, 11 Sep 2008 06:44:37 +1000
>
> Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> > On Wednesday 10 September 2008 11:49, KAMEZAWA Hiroyuki wrote:
> > > On Tue, 9 Sep 2008 18:20:48 -0700
> > >
> > > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2008-09-09
> > > > 21:30:12]: OK, here is approach #2, it works for me and gives me
> > > > really good performance (surpassing even the current memory
> > > > controller). I am seeing almost a 7% increase
> > >
> > > This number is from pre-allcation, maybe.
> > > We really do alloc-at-boot all page_cgroup ? This seems a big change.
> >
> > It seems really nice to me -- we get the best of both worlds, less
> > overhead for those who don't enable the memory controller, and even
> > better performance for those who do.
>
> No trobles for me for allocating-all-at-boot policy.
> My small concern is
>   - wasting page_cgroup for hugepage area.
>   - memory hotplug

In those cases you still waste the struct page area too. I realise that
isn't a good way to justify even more wastage. But I guess it is
relatively low. At least, I would think the users would be more happy to
get a 7% performance increase for small pages! :)


> > Are you expecting many users to want to turn this on and off at runtime?
> > I wouldn't expect so, but I don't know enough about them.
>
> There is no runtime switch. only at boot.

Fine

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
