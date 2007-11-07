Date: Wed, 7 Nov 2007 11:35:55 +0100
From: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Subject: Re: [patch 14/23] inodes: Support generic defragmentation
Message-ID: <20071107103554.GF7374@lazybastard.org>
References: <20071107011130.382244340@sgi.com> <20071107011229.893091119@sgi.com> <20071107101748.GC7374@lazybastard.org> <je8x5aibry.fsf@sykes.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <je8x5aibry.fsf@sykes.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andreas Schwab <schwab@suse.de>
Cc: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>, Christoph Lameter <clameter@sgi.com>, akpm@linux-foundatin.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

On Wed, 7 November 2007 11:35:13 +0100, Andreas Schwab wrote:
> >
> > The fact that all pointers get changed makes me a bit uneasy:
> > 	struct foo_inode v[20];
> > 	...
> > 	fs_get_inodes(..., v, ...);
> > 	...
> > 	v[0].foo_field = bar;
> > 	
> > No warning, but spectacular fireworks.
> 
> You'l get a warning that struct foo_inode * is incompatible with void **.
- 	struct foo_inode v[20];
+ 	struct foo_inode *v[20];

Looks like my example needs a patch as well.  Anyway, the function is
used in a way that makes this a non-issue.

JA?rn

-- 
You cannot suppose that Moliere ever troubled himself to be original in the
matter of ideas. You cannot suppose that the stories he tells in his plays
have never been told before. They were culled, as you very well know.
-- Andre-Louis Moreau in Scarabouche

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
