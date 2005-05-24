Date: Tue, 24 May 2005 13:59:30 -0700 (PDT)
From: Christoph Lameter <christoph@lameter.com>
Subject: Re: [Lhms-devel] Re: [PATCH 2.6.12-rc3 1/8] mm: manual page
 migration-rc2 -- xfs-extended-attributes-rc2.patch
In-Reply-To: <4292B361.80500@engr.sgi.com>
Message-ID: <Pine.LNX.4.62.0505241356320.2846@graphe.net>
References: <20050511043756.10876.72079.60115@jackhammer.engr.sgi.com>
 <20050511043802.10876.60521.51027@jackhammer.engr.sgi.com>
 <20050511071538.GA23090@infradead.org> <4281F650.2020807@engr.sgi.com>
 <20050511125932.GW25612@wotan.suse.de> <42825236.1030503@engr.sgi.com>
 <20050511193207.GE11200@wotan.suse.de> <20050512104543.GA14799@infradead.org>
 <428E6427.7060401@engr.sgi.com> <429217F8.5020202@mwwireless.net>
 <4292B361.80500@engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@engr.sgi.com>
Cc: Steve Longerbeam <stevel@mwwireless.net>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <ak@suse.de>, Ray Bryant <raybry@sgi.com>, Hirokazu Takahashi <taka@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Dave Hansen <haveblue@us.ibm.com>, linux-mm <linux-mm@kvack.org>, Nathan Scott <nathans@sgi.com>, Ray Bryant <raybry@austin.rr.com>, lhms-devel@lists.sourceforge.net, Jes Sorensen <jes@wildopensource.com>
List-ID: <linux-mm.kvack.org>

On Mon, 23 May 2005, Ray Bryant wrote:

> We need to take a different migration action based on which case we
> are in:
> 
> (1)  Migrate all of the pages.
> (2)  Migrate the non-shared pages.
> (3)  Migrate none of the pages.
> 
> So we need some external way for the kernel to be told which kind of
> mapped file this is.  That is why we need some kind of interface for
> the user (or admininistrator) to tell us how to classify each shared
> mapped file.

Sorry I am a bit late to the party and I know you must have said this
before but what is the reason again not to use the page reference count to 
determine if a page is shared? Maybe its possible to live with some 
restrictions that the use of the page reference count brings.

Seems that touching a filesystem and the ELF headers is way off from the 
vm.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
