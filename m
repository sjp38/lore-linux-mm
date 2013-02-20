From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] mm: hotplug: implement non-movable version of
 get_user_pages() called get_user_pages_non_movable()
Date: Wed, 20 Feb 2013 10:44:35 +0800
Message-ID: <28260.3998123252$1361328322@news.gmane.org>
References: <1359972248-8722-1-git-send-email-linfeng@cn.fujitsu.com>
 <1359972248-8722-2-git-send-email-linfeng@cn.fujitsu.com>
 <20130204160624.5c20a8a0.akpm@linux-foundation.org>
 <20130205115722.GF21389@suse.de>
 <20130205133244.GH21389@suse.de>
 <51238033.6010005@cn.fujitsu.com>
 <5124363C.9060604@cn.fujitsu.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-aio@kvack.org>
Content-Disposition: inline
In-Reply-To: <5124363C.9060604@cn.fujitsu.com>
Sender: owner-linux-aio@kvack.org
To: Lin Feng <linfeng@cn.fujitsu.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, bcrl@kvack.org, viro@zeniv.linux.org.uk, khlebnikov@openvz.org, walken@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan@kernel.org, riel@redhat.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, mhocko@suse.cz, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org

On Wed, Feb 20, 2013 at 10:34:36AM +0800, Lin Feng wrote:
>
>
>On 02/19/2013 09:37 PM, Lin Feng wrote:
>>> > 
>>> > The other is that this almost certainly broken for transhuge page
>>> > handling. gup returns the head and tail pages and ordinarily this is ok
>> I can't find codes doing such things :(, could you please point me out?
>> 
>Sorry, I misunderstood what "tail pages" means, stupid question, just ignore it.
>flee...

According to the compound page, the first page of compound page is
called head page, other sub pages are called tail pages.

Regards,
Wanpeng Li 

>
>thanks,
>linfeng
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-aio' in
the body to majordomo@kvack.org.  For more info on Linux AIO,
see: http://www.kvack.org/aio/
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
