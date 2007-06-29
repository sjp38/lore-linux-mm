Date: Fri, 29 Jun 2007 12:08:33 +1000
From: David Chinner <dgc@sgi.com>
Subject: Re: [RFC] fsblock
Message-ID: <20070629020833.GJ31489@sgi.com>
References: <20070624014528.GA17609@wotan.suse.de> <20070626030640.GM989688@sgi.com> <46808E1F.1000509@yahoo.com.au> <20070626092309.GF31489@sgi.com> <20070626123449.GM14224@think.oraclecorp.com> <20070627053245.GA6033@wotan.suse.de> <20070627115056.GW14224@think.oraclecorp.com> <20070627223548.GS989688@sgi.com> <20070628024443.GB6038@wotan.suse.de> <20070628122031.GF5313@think.oraclecorp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070628122031.GF5313@think.oraclecorp.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Mason <chris.mason@oracle.com>
Cc: Nick Piggin <npiggin@suse.de>, David Chinner <dgc@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 28, 2007 at 08:20:31AM -0400, Chris Mason wrote:
> On Thu, Jun 28, 2007 at 04:44:43AM +0200, Nick Piggin wrote:
> > That's true but I don't think an extent data structure means we can
> > become too far divorced from the pagecache or the native block size
> > -- what will end up happening is that often we'll need "stuff" to map
> > between all those as well, even if it is only at IO-time.
> 
> I think the fundamental difference is that fsblock still does:
> mapping_info = page->something, where something is attached on a per
> page basis.  What we really want is mapping_info = lookup_mapping(page),

lookup_block_mapping(page).... ;)

But yes, that is the essence of what I was saying. Thanks for
describing it so concisely, Chris.

Cheers,

Dave.
-- 
Dave Chinner
Principal Engineer
SGI Australian Software Group

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
