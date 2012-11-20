Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 9621F6B0073
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 13:25:21 -0500 (EST)
Date: Tue, 20 Nov 2012 19:25:00 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: Problem in Page Cache Replacement
Message-ID: <20121120182500.GH1408@quack.suse.cz>
References: <1353433362.85184.YahooMailNeo@web141101.mail.bf1.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1353433362.85184.YahooMailNeo@web141101.mail.bf1.yahoo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: metin d <metdos@yahoo.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue 20-11-12 09:42:42, metin d wrote:
> I have two PostgreSQL databases named data-1 and data-2 that sit on the
> same machine. Both databases keep 40 GB of data, and the total memory
> available on the machine is 68GB.
> 
> I started data-1 and data-2, and ran several queries to go over all their
> data. Then, I shut down data-1 and kept issuing queries against data-2.
> For some reason, the OS still holds on to large parts of data-1's pages
> in its page cache, and reserves about 35 GB of RAM to data-2's files. As
> a result, my queries on data-2 keep hitting disk.
> 
> I'm checking page cache usage with fincore. When I run a table scan query
> against data-2, I see that data-2's pages get evicted and put back into
> the cache in a round-robin manner. Nothing happens to data-1's pages,
> although they haven't been touched for days.
> 
> Does anybody know why data-1's pages aren't evicted from the page cache?
> I'm open to all kind of suggestions you think it might relate to problem.
  Curious. Added linux-mm list to CC to catch more attention. If you run
echo 1 >/proc/sys/vm/drop_caches
  does it evict data-1 pages from memory?

> This is an EC2 m2.4xlarge instance on Amazon with 68 GB of RAM and no
> swap space. The kernel version is:
> 
> $ uname -r
> 3.2.28-45.62.amzn1.x86_64
> Edit:
> 
> and it seems that I use one NUMA instance, if  you think that it can a problem.
> 
> $ numactl --hardware
> available: 1 nodes (0)
> node 0 cpus: 0 1 2 3 4 5 6 7
> node 0 size: 70007 MB
> node 0 free: 360 MB
> node distances:
> node   0
>   0:  10

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
