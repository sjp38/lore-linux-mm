Return-Path: <owner-linux-mm@kvack.org>
Message-ID: <5110C28D.1040001@cn.fujitsu.com>
Date: Tue, 05 Feb 2013 16:27:57 +0800
From: Lin Feng <linfeng@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/2] mm: hotplug: implement non-movable version of get_user_pages()
 to kill long-time pin pages
References: <1359972248-8722-1-git-send-email-linfeng@cn.fujitsu.com> <20130205005859.GE2610@blaptop> <51108DC8.4090704@cn.fujitsu.com> <20130205052517.GH2610@blaptop> <5110A442.5000707@cn.fujitsu.com> <20130205074519.GB11197@blaptop>
In-Reply-To: <20130205074519.GB11197@blaptop>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: akpm@linux-foundation.org, mgorman@suse.de, bcrl@kvack.org, viro@zeniv.linux.org.uk, khlebnikov@openvz.org, walken@google.com, kamezawa.hiroyu@jp.fujitsu.com, riel@redhat.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Hi Minchan,

On 02/05/2013 03:45 PM, Minchan Kim wrote:
>> So it may not a good idea that we all fall into calling the *non_movable* version of
>> > GUP when CONFIG_MIGRATE_ISOLATE is on. What do you think?
> Frankly speaking, I can't understand Mel's comment.
> AFAIUC, he said GUP checks the page before get_page and if the page is movable zone,
> then migrate it out of movable zone and get_page again.
> That's exactly what I want. It doesn't introduce GUP_NM.
Since an long time pin or not is an unpredictable behave except you know what the caller
wants to do. We have to check every time we call GUP, and GUP may need another parameter
 to teach itself to make the right decision? We have already got *8* parameters :(

thanks,
linfeng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
