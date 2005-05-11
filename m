Date: Wed, 11 May 2005 21:32:07 +0200
From: Andi Kleen <ak@suse.de>
Subject: Re: [Lhms-devel] Re: [PATCH 2.6.12-rc3 1/8] mm: manual page migration-rc2 -- xfs-extended-attributes-rc2.patch
Message-ID: <20050511193207.GE11200@wotan.suse.de>
References: <20050511043756.10876.72079.60115@jackhammer.engr.sgi.com> <20050511043802.10876.60521.51027@jackhammer.engr.sgi.com> <20050511071538.GA23090@infradead.org> <4281F650.2020807@engr.sgi.com> <20050511125932.GW25612@wotan.suse.de> <42825236.1030503@engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <42825236.1030503@engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@engr.sgi.com>
Cc: Andi Kleen <ak@suse.de>, Christoph Hellwig <hch@infradead.org>, Ray Bryant <raybry@sgi.com>, Hirokazu Takahashi <taka@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Dave Hansen <haveblue@us.ibm.com>, linux-mm <linux-mm@kvack.org>, Nathan Scott <nathans@sgi.com>, Ray Bryant <raybry@austin.rr.com>, lhms-devel@lists.sourceforge.net, Jes Sorensen <jes@wildopensource.com>
List-ID: <linux-mm.kvack.org>

> If we are going to use a "system" attribute, as near as I can tell, this
> requires a change in the file system specific code.  If we use a "user"
> attribute, then no fs change is required.  However, in the latter case
> there is also no way to reserve a name that users can't overwrite or usurp.

A minor change for that is probably ok, as long as the actual logic
who uses this is generic. 

hch: if you still are against this please reread the original thread
with me and Ray and see why we decided that ld.so changes are not
a good idea.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
