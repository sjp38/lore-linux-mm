Return-Path: <owner-linux-mm@kvack.org>
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH V2 1/2] mm: hotplug: implement non-movable version of get_user_pages() called get_user_pages_non_movable()
References: <1360056113-14294-1-git-send-email-linfeng@cn.fujitsu.com>
	<1360056113-14294-2-git-send-email-linfeng@cn.fujitsu.com>
	<20130205120137.GG21389@suse.de> <20130206004234.GD11197@blaptop>
	<20130206095617.GN21389@suse.de> <5190AE4F.4000103@cn.fujitsu.com>
	<20130513091902.GP11497@suse.de> <20130513143757.GP31899@kvack.org>
Date: Mon, 13 May 2013 10:54:03 -0400
In-Reply-To: <20130513143757.GP31899@kvack.org> (Benjamin LaHaise's message of
	"Mon, 13 May 2013 10:37:57 -0400")
Message-ID: <x49obcfnd6c.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Cc: Mel Gorman <mgorman@suse.de>, Tang Chen <tangchen@cn.fujitsu.com>, Minchan Kim <minchan@kernel.org>, Lin Feng <linfeng@cn.fujitsu.com>, akpm@linux-foundation.org, viro@zeniv.linux.org.uk, khlebnikov@openvz.org, walken@google.com, kamezawa.hiroyu@jp.fujitsu.com, riel@redhat.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, zab@redhat.com, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>

Benjamin LaHaise <bcrl@kvack.org> writes:

> On Mon, May 13, 2013 at 10:19:02AM +0100, Mel Gorman wrote:
>> On Mon, May 13, 2013 at 05:11:43PM +0800, Tang Chen wrote:
> ...
>> > If so, I'm wondering where should we put this callback pointers ?
>> > In struct page ?
>> > 
>> 
>> No, I would expect the callbacks to be part the address space operations
>> which can be found via page->mapping.
>
> If someone adds those callbacks and provides a means for testing them, 
> it would be pretty trivial to change the aio code to migrate its pinned 
> pages on demand.

How do you propose to move the ring pages?

Cheers,
Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
