Date: Thu, 6 Sep 2007 22:34:12 +0200
From: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Subject: Re: [RFC 00/26] Slab defragmentation V5
Message-ID: <20070906203412.GB27657@lazybastard.org>
References: <20070901014107.719506437@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20070901014107.719506437@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andy Whitcroft <apw@shadowen.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, David Chinner <dgc@sgi.com>
List-ID: <linux-mm.kvack.org>

On Fri, 31 August 2007 18:41:07 -0700, Christoph Lameter wrote:
> 
> The trouble with this patchset is that it is difficult to validate.
> Activities are only performed when special load situations are encountered.
> Are there any tests that could give meaningful information about
> the effectiveness of these measures? I have run various tests here
> creating and deleting files and building kernels under low memory situations
> to trigger these reclaim mechanisms but how does one measure their
> effectiveness?

One could play with updatedb followed by a memhog.  How much time passes
and how many slab objects have to be freed before the memhog has
allocated N% of physical memory?  Both numbers are relevant.  The first
indicates how quickly pages are reclaimed from slab caches, while the
second show how many objects remain cached for future lookups.  Updatedb
aside, caching objects is done for solid performance reasons.

Creating a qemu image with little memory and a huge directory hierarchy
filled with 0-byte files may be a nice test system.  Unless you beat me
to it I'll try to set it up once logfs is in merge-worthy shape.

JA?rn

-- 
A quarrel is quickly settled when deserted by one party; there is
no battle unless there be two.
-- Seneca

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
