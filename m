Date: Wed, 11 May 2005 08:15:38 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2.6.12-rc3 1/8] mm: manual page migration-rc2 -- xfs-extended-attributes-rc2.patch
Message-ID: <20050511071538.GA23090@infradead.org>
References: <20050511043756.10876.72079.60115@jackhammer.engr.sgi.com> <20050511043802.10876.60521.51027@jackhammer.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050511043802.10876.60521.51027@jackhammer.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Andi Kleen <ak@suse.de>, Dave Hansen <haveblue@us.ibm.com>, Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>, Nathan Scott <nathans@sgi.com>, Ray Bryant <raybry@austin.rr.com>, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Tue, May 10, 2005 at 09:38:02PM -0700, Ray Bryant wrote:
> This patch is from Nathan Scott of SGI and adds the extended
> attribute system.migration for xfs.  At the moment, there is
> no protection checking being done here (according to Nathan),
> so this would have to be added if we finally agree to go this
> way. 

As Nathan and I told you this is not acceptable at all.  Imigration policies
don't belong into filesystem metadata.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
