Return-Path: <owner-linux-mm@kvack.org>
Message-ID: <51D63B9C.4060204@cn.fujitsu.com>
Date: Fri, 05 Jul 2013 11:21:00 +0800
From: Gu Zheng <guz.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [WiP]: aio support for migrating pages (Re: [PATCH V2 1/2] mm:
 hotplug: implement non-movable version of get_user_pages() called get_user_pages_non_movable())
References: <20130517002349.GI1008@kvack.org> <5195A3F4.70803@cn.fujitsu.com> <20130517143718.GK1008@kvack.org> <519AD6F8.2070504@cn.fujitsu.com> <20130521022733.GT1008@kvack.org> <51B6F107.80501@cn.fujitsu.com> <20130611144525.GB14404@kvack.org> <51D12E7B.6080301@cn.fujitsu.com> <20130702180008.GQ16399@kvack.org> <51D51B66.3000301@cn.fujitsu.com> <20130704114153.GD11006@kvack.org>
In-Reply-To: <20130704114153.GD11006@kvack.org>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, akpm@linux-foundation.org, viro@zeniv.linux.org.uk, khlebnikov@openvz.org, walken@google.com, kamezawa.hiroyu@jp.fujitsu.com, riel@redhat.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, zab@redhat.com, jmoyer@redhat.com, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>

On 07/04/2013 07:41 PM, Benjamin LaHaise wrote:

> On Thu, Jul 04, 2013 at 02:51:18PM +0800, Gu Zheng wrote:
>> Hi Ben,
>>       When I test your patch on kernel 3.10, the kernel panic when aio job
>> complete or exit, exactly in aio_free_ring(), the following is a part of dmesg.
> 
> What is your test case?

Just the one you mentioned in the previous mail:
 http://www.kvack.org/~bcrl/aio/aio-numa-test.c

Thanks,
Gu

> 
> 		-ben
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
