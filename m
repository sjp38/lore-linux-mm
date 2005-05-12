Date: Thu, 12 May 2005 10:55:35 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [Lhms-devel] Re: [PATCH 2.6.12-rc3 1/8] mm: manual page migration-rc2 -- xfs-extended-attributes-rc2.patch
Message-ID: <20050512095535.GA14409@infradead.org>
References: <20050511043756.10876.72079.60115@jackhammer.engr.sgi.com> <20050511043802.10876.60521.51027@jackhammer.engr.sgi.com> <20050511071538.GA23090@infradead.org> <4281F650.2020807@engr.sgi.com> <20050511195003.GA2468@infradead.org> <4282798F.8060005@engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4282798F.8060005@engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@engr.sgi.com>
Cc: Ray Bryant <raybry@sgi.com>, Hirokazu Takahashi <taka@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Andi Kleen <ak@suse.de>, Dave Hansen <haveblue@us.ibm.com>, linux-mm <linux-mm@kvack.org>, Nathan Scott <nathans@sgi.com>, Ray Bryant <raybry@austin.rr.com>, lhms-devel@lists.sourceforge.net, Jes Sorensen <jes@sgi.com>
List-ID: <linux-mm.kvack.org>

On Wed, May 11, 2005 at 04:30:55PM -0500, Ray Bryant wrote:
> I guess we have a different world view on this.  It seems to me that
> migratability is a long term property of the file itself (and how it
> is commonly used) rather than a short term property (i. e. how the
> file is used this particular time it got mapped in).

When you talk about files you're already in the special casing business.
Only few vmas are file-backed and it makes lots of sense to mark an
anonymous vma non-migratable.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
