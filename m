Return-Path: <owner-linux-mm@kvack.org>
Message-ID: <51D3841D.9040906@cn.fujitsu.com>
Date: Wed, 03 Jul 2013 09:53:33 +0800
From: Gu Zheng <guz.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [WiP]: aio support for migrating pages (Re: [PATCH V2 1/2] mm:
 hotplug: implement non-movable version of get_user_pages() called get_user_pages_non_movable())
References: <20130515132453.GB11497@suse.de> <5194748A.5070700@cn.fujitsu.com> <20130517002349.GI1008@kvack.org> <5195A3F4.70803@cn.fujitsu.com> <20130517143718.GK1008@kvack.org> <519AD6F8.2070504@cn.fujitsu.com> <20130521022733.GT1008@kvack.org> <51B6F107.80501@cn.fujitsu.com> <20130611144525.GB14404@kvack.org> <51D12E7B.6080301@cn.fujitsu.com> <20130702180008.GQ16399@kvack.org>
In-Reply-To: <20130702180008.GQ16399@kvack.org>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, akpm@linux-foundation.org, viro@zeniv.linux.org.uk, khlebnikov@openvz.org, walken@google.com, kamezawa.hiroyu@jp.fujitsu.com, riel@redhat.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, zab@redhat.com, jmoyer@redhat.com, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>

On 07/03/2013 02:00 AM, Benjamin LaHaise wrote:

> On Mon, Jul 01, 2013 at 03:23:39PM +0800, Gu Zheng wrote:
>> Hi Ben,
>> Are you still working on this patch?
>> As you know, using the current anon inode will lead to more than one instance of
>> aio can not work. Have you found a way to fix this issue? Or can we use some
>> other ones to replace the anon inode?
> 
> This patch hasn't been a high priority for me.  I would really appreciate 
> it if someone could confirm that this patch does indeed fix the hotplug 
> page migration issue by testing it in a system that hits the bug.  Removing 
> the anon_inode bits isn't too much work, but I'd just like to have some 
> confirmation that this fix is considered to be "good enough" for the 
> problem at hand before spending any further time on it.  There was talk of 
> using another approach, but it's not clear if there was any progress.

Yeah, we have not seen anyone try to fix this issue using the other approach we
talked. I'm not sure whether your patch can indeed fix the problem, but I'll
carry out a complete test to confirm it, and I'll be very glad to continue this
job based on your patch if you do not have enough time working on it.:)

Thanks,
Gu

> 
> 		-ben


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
