Subject: Re: Non-GPL export of invalidate_mmap_range
From: "Stephen C. Tweedie" <sct@redhat.com>
In-Reply-To: <200402191531.56618.phillips@arcor.de>
References: <20040216190927.GA2969@us.ibm.com>
	 <20040217124001.GA1267@us.ibm.com> <20040217161929.7e6b2a61.akpm@osdl.org>
	 <200402191531.56618.phillips@arcor.de>
Content-Type: text/plain
Message-Id: <1077228402.2070.893.camel@sisko.scot.redhat.com>
Mime-Version: 1.0
Date: 19 Feb 2004 22:06:42 +0000
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: Andrew Morton <akpm@osdl.org>, "Paul E. McKenney" <paulmck@us.ibm.com>, Christoph Hellwig <hch@infradead.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 2004-02-19 at 20:56, Daniel Phillips wrote:

> OpenGFS and Sistina GFS use zap_page_range directly, essentially doing the 
> same as invalidate_mmap_range but skipping any vmas belonging to MAP_PRIVATE 
> mmaps.

Well, MAP_PRIVATE maps can contain shared pages too --- any page in a
MAP_PRIVATE map that has been mapped but not yet written to is still
shared, and still needs shot down on truncate().

--Stephen


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
