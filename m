Return-Path: <owner-linux-mm@kvack.org>
Message-ID: <50B82B0D.8010206@cn.fujitsu.com>
Date: Fri, 30 Nov 2012 11:42:05 +0800
From: Lin Feng <linfeng@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [BUG REPORT] [mm-hotplug, aio] aio ring_pages can't be offlined
References: <1354172098-5691-1-git-send-email-linfeng@cn.fujitsu.com> <20121129153930.477e9709.akpm@linux-foundation.org>
In-Reply-To: <20121129153930.477e9709.akpm@linux-foundation.org>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: viro@zeniv.linux.org.uk, bcrl@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, hughd@google.com, cl@linux.com, mgorman@suse.de, minchan@kernel.org, isimatu.yasuaki@jp.fujitsu.com, laijs@cn.fujitsu.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

hi Andrew,

On 11/30/2012 07:39 AM, Andrew Morton wrote:
> Tricky.
> 
> I expect the same problem would occur with pages which are under
> O_DIRECT I/O.  Obviously O_DIRECT pages won't be pinned for such long
> periods, but the durations could still be lengthy (seconds).
the offline retry timeout duration is 2 minutes, so to O_DIRECT pages 
seem maybe not a problem for the moment.
> 
> Worse is a futex page, which could easily remain pinned indefinitely.
> 
> The best I can think of is to make changes in or around
> get_user_pages(), to steal the pages from userspace and replace them
> with non-movable ones before pinning them.  The performance cost of
> something like this would surely be unacceptable for direct-io, but
> maybe OK for the aio ring and futexes.
thanks for your advice.
I want to limit the impact as little as possible, as mentioned above,
direct-io seems not a problem, we needn't touch them. Maybe we can 
just change the use of get_user_pages()(in or around) such as aio 
ring pages. I will try to find a way to do this.

Thanks,
linfeng

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
