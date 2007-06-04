Date: Mon, 4 Jun 2007 08:17:11 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: tmpfs and numa mempolicy
Message-ID: <20070604131711.GC31624@lnx-holt.americas.sgi.com>
References: <20070603203003.64fd91a8.randy.dunlap@oracle.com> <Pine.LNX.4.64.0706041307560.12071@blonde.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706041307560.12071@blonde.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Randy Dunlap <randy.dunlap@oracle.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Robin Holt <holt@sgi.com>, Christoph Lameter <clameter@sgi.com>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 04, 2007 at 01:43:33PM +0100, Hugh Dickins wrote:
> Would you be happy with this change, Robin?  I'm not very NUMArate:
> do nodes in fact ever get onlined after early system startup?
> If not, then this change would hardly be any real limitation.

Not currently on our architecture.  There are numerous other places
where the node going offline has made a permanent change to the
mempolicy, so this behavior would be equivalent.

Thanks,
Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
