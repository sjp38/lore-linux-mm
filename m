Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 5EF3B6B0033
	for <linux-mm@kvack.org>; Thu,  9 May 2013 16:24:16 -0400 (EDT)
Message-ID: <518C05ED.6080000@bitsync.net>
Date: Thu, 09 May 2013 22:24:13 +0200
From: Zlatko Calusic <zcalusic@bitsync.net>
MIME-Version: 1.0
Subject: Re: The pagecache unloved in zone NORMAL?
References: <51671D4D.9080003@bitsync.net> <5186D433.3050301@bitsync.net>
In-Reply-To: <5186D433.3050301@bitsync.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>

On 05.05.2013 23:50, Zlatko Calusic wrote:
> useful additional insight into this problem, just as I expected. Here's
> the data after 31h of server uptime (also see the attached graph):
>
> Node 0, zone    DMA32
>      nr_inactive_file 443705
>    avg_age_inactive_file: 362800
> Node 0, zone   Normal
>      nr_inactive_file 32832
>    avg_age_inactive_file: 38760
>

4 days later:

Node 0, zone    DMA32
     nr_inactive_file 404276
     nr_vmscan_write 2897
   avg_age_inactive_file: 318208

Node 0, zone   Normal
     nr_inactive_file 4677
     nr_vmscan_write 92536
   avg_age_inactive_file: 3692

Inactive pages in the Normal zone are reclaimed in less than 4 seconds 
(vs 5 minutes in the DMA32 zone), nr_vmscan_write is high and constantly 
rising.

-- 
Zlatko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
