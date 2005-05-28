Date: Sat, 28 May 2005 09:40:26 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [Lhms-devel] Re: [PATCH 2.6.12-rc3 1/8] mm: manual page migration-rc2 -- xfs-extended-attributes-rc2.patch
Message-ID: <20050528084026.GA18380@infradead.org>
References: <4281F650.2020807@engr.sgi.com> <20050511125932.GW25612@wotan.suse.de> <42825236.1030503@engr.sgi.com> <20050511193207.GE11200@wotan.suse.de> <20050512104543.GA14799@infradead.org> <428E6427.7060401@engr.sgi.com> <429217F8.5020202@mwwireless.net> <4292B361.80500@engr.sgi.com> <Pine.LNX.4.62.0505241356320.2846@graphe.net> <42941E5D.5060606@engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <42941E5D.5060606@engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@engr.sgi.com>
Cc: Christoph Lameter <christoph@lameter.com>, Steve Longerbeam <stevel@mwwireless.net>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <ak@suse.de>, Ray Bryant <raybry@sgi.com>, Hirokazu Takahashi <taka@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Dave Hansen <haveblue@us.ibm.com>, linux-mm <linux-mm@kvack.org>, Nathan Scott <nathans@sgi.com>, Ray Bryant <raybry@austin.rr.com>, lhms-devel@lists.sourceforge.net, Jes Sorensen <jes@wildopensource.com>
List-ID: <linux-mm.kvack.org>

On Wed, May 25, 2005 at 01:42:37AM -0500, Ray Bryant wrote:
> Now a workable solution might be that we decide to not migrate shared
> pages that are executable (or part of a vma marked executable).  That
> would handle the shared library and shared (system) executable case
> quite nicely.  It wouldn't handle the case of a shared user executable
> that is only used by the processes being migrated, since it will be
> shared an executable, but should be migrated, and we will decide by
> the above rule not to migrate it.

I don't think that's a good idea.  It would place arbitrary policy into
the kernel, something we try to avoid.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
