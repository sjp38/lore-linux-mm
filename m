Date: Wed, 11 May 2005 20:50:03 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [Lhms-devel] Re: [PATCH 2.6.12-rc3 1/8] mm: manual page migration-rc2 -- xfs-extended-attributes-rc2.patch
Message-ID: <20050511195003.GA2468@infradead.org>
References: <20050511043756.10876.72079.60115@jackhammer.engr.sgi.com> <20050511043802.10876.60521.51027@jackhammer.engr.sgi.com> <20050511071538.GA23090@infradead.org> <4281F650.2020807@engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4281F650.2020807@engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@engr.sgi.com>
Cc: Christoph Hellwig <hch@infradead.org>, Ray Bryant <raybry@sgi.com>, Hirokazu Takahashi <taka@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Andi Kleen <ak@suse.de>, Dave Hansen <haveblue@us.ibm.com>, linux-mm <linux-mm@kvack.org>, Nathan Scott <nathans@sgi.com>, Ray Bryant <raybry@austin.rr.com>, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Wed, May 11, 2005 at 07:10:56AM -0500, Ray Bryant wrote:
> Is the issue here the use of extended attributes, period, or the use of the
> system name space?

The former.

> I would observe that after lengthy discussion on this topic in February
> with Andi, use of extended attributes was agreed upon as the preferred
> solution.  Your alternative (As I recall: modifying the dynamic loader
> to mark mapped files in memory as shared libraries, and requiring a new
> mmap() flag to mark files as non-migratable) strikes me as more
> complicated and even harder to get accepted by the community, since it
> touches not only the kernel, but glibc as well.

But it's the right thing to do.  Non-migratability is not an attribute
of a file but a memory region.  Being able to set it for individual
mappings and possible even modifying it with a new MADVISE subcall
makes sense.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
