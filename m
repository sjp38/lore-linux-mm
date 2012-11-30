Return-Path: <owner-linux-mm@kvack.org>
Date: Thu, 29 Nov 2012 16:04:43 -0800
From: Zach Brown <zab@zabbo.net>
Subject: Re: [BUG REPORT] [mm-hotplug, aio] aio ring_pages can't be offlined
Message-ID: <20121130000443.GK18574@lenny.home.zabbo.net>
References: <1354172098-5691-1-git-send-email-linfeng@cn.fujitsu.com>
 <20121129153930.477e9709.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121129153930.477e9709.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Lin Feng <linfeng@cn.fujitsu.com>, viro@zeniv.linux.org.uk, bcrl@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, hughd@google.com, cl@linux.com, mgorman@suse.de, minchan@kernel.org, isimatu.yasuaki@jp.fujitsu.com, laijs@cn.fujitsu.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> The best I can think of is to make changes in or around
> get_user_pages(), to steal the pages from userspace and replace them
> with non-movable ones before pinning them.  The performance cost of
> something like this would surely be unacceptable for direct-io, but
> maybe OK for the aio ring and futexes.

In the aio case it seems like it could be taught to populate the mapping
with non-movable pages to begin with.  It's calling get_user_pages() a
few lines after instantiating the mapping itself with do_mmap_pgoff().

- z

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
