Return-Path: <owner-linux-mm@kvack.org>
Message-ID: <50BC08D0.5070006@cn.fujitsu.com>
Date: Mon, 03 Dec 2012 10:05:04 +0800
From: Lin Feng <linfeng@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [BUG REPORT] [mm-hotplug, aio] aio ring_pages can't be offlined
References: <1354172098-5691-1-git-send-email-linfeng@cn.fujitsu.com> <20121130152421.GA19849@glitch>
In-Reply-To: <20121130152421.GA19849@glitch>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cavokz@gmail.com
Cc: akpm@linux-foundation.org, viro@zeniv.linux.org.uk, bcrl@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, hughd@google.com, cl@linux.com, mgorman@suse.de, minchan@kernel.org, isimatu.yasuaki@jp.fujitsu.com, laijs@cn.fujitsu.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

hi Domenico,

Sorry for my late reply and thanks for your attention, see below :)

On 11/30/2012 11:24 PM, Domenico Andreoli wrote:
> On Thu, Nov 29, 2012 at 02:54:58PM +0800, Lin Feng wrote:
>> Hi all,
> 
> Hi Lin,
> 
>> We encounter a "Resource temporarily unavailable" fail while trying
>> to offline a memory section in a movable zone. We found that there are 
>> some pages can't be migrated. The offline operation fails in function 
>> migrate_page_move_mapping() returning -EAGAIN till timeout because 
>> the if assertion 'page_count(page) != 1' fails.
> 
> is this something that worked before? if yes (then it's a regression)
> do you know with which kernel?

I think it's a problem exist long ago since we got the offline feature,
while I'm not sure from which version :)

It can only be reproduce by a zone-movable configured system holding 
pages allocated by get_user_pages() for a long time. 

Maybe we could also reproduce it by write a app just calls io_setup()
syscall and never release until it dies.  Then locate the memory section 
from which pages are allocated and try to offline it.
 
In fact if one doesn't want to use offline/hotplug memory feature, 
to whom it's not a bug :)

Thanks,
linfeng
> 
> Thanks,
> Domenico
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
