Return-Path: <owner-linux-mm@kvack.org>
Date: Fri, 30 Nov 2012 16:24:21 +0100
From: Domenico Andreoli <cavokz@gmail.com>
Subject: Re: [BUG REPORT] [mm-hotplug, aio] aio ring_pages can't be offlined
Message-ID: <20121130152421.GA19849@glitch>
References: <1354172098-5691-1-git-send-email-linfeng@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1354172098-5691-1-git-send-email-linfeng@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lin Feng <linfeng@cn.fujitsu.com>
Cc: akpm@linux-foundation.org, viro@zeniv.linux.org.uk, bcrl@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, hughd@google.com, cl@linux.com, mgorman@suse.de, minchan@kernel.org, isimatu.yasuaki@jp.fujitsu.com, laijs@cn.fujitsu.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Nov 29, 2012 at 02:54:58PM +0800, Lin Feng wrote:
> Hi all,

Hi Lin,

> We encounter a "Resource temporarily unavailable" fail while trying
> to offline a memory section in a movable zone. We found that there are 
> some pages can't be migrated. The offline operation fails in function 
> migrate_page_move_mapping() returning -EAGAIN till timeout because 
> the if assertion 'page_count(page) != 1' fails.

is this something that worked before? if yes (then it's a regression)
do you know with which kernel?

Thanks,
Domenico

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
