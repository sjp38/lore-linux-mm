Return-Path: <owner-linux-mm@kvack.org>
Date: Wed, 17 Jul 2013 09:44:28 -0400
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [PATCH V2 2/2] fs/aio: Add support to aio ring pages migration
Message-ID: <20130717134428.GB19643@kvack.org>
References: <51E518C0.2020908@cn.fujitsu.com> <20130716133450.GD5403@kvack.org> <51E66256.9020203@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51E66256.9020203@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gu Zheng <guz.fnst@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Al Viro <viro@zeniv.linux.org.uk>, tangchen <tangchen@cn.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, linux-aio@kvack.org

On Wed, Jul 17, 2013 at 05:22:30PM +0800, Gu Zheng wrote:
> As the aio job will pin the ring pages, that will lead to mem migrated
> failed. In order to fix this problem we use an anon inode to manage the aio ring
> pages, and  setup the migratepage callback in the anon inode's address space, so
> that when mem migrating the aio ring pages will be moved to other mem node safely.
> 
> v1->v2:
> 	Fix build failed issue if CONFIG_MIGRATION disabled.
> 	Fix some minor issues under Benjamin's comments.

I don't know what you did with this patch, but it doesn't apply to any of 
the trees I can find, and interdiff isn't able to compare it against your 
original patch.  Since the first version of the patch was already applied 
it is generally more appropriate to provide an incremental fix.  I've 
added the following to my tree (git://git.kvack.org/~bcrl/aio-next.git/) 
to fix the build issue.  I've tested this with CONFIG_MIGRATION enabled 
and disabled on x86.

		-ben
-- 
"Thought is the essence of where you are now."
