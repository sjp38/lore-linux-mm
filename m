Message-ID: <466C3A60.6080403@redhat.com>
Date: Sun, 10 Jun 2007 13:52:32 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 15 of 16] limit reclaim if enough pages have been freed
References: <31ef5d0bf924fb47da14.1181332993@v2.random> <466C32F2.9000306@redhat.com> <20070610173221.GB7443@v2.random>
In-Reply-To: <20070610173221.GB7443@v2.random>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-mm@kvack.org, Larry Woodman <lwoodman@redhat.com>
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:
> On Sun, Jun 10, 2007 at 01:20:50PM -0400, Rik van Riel wrote:
>> code simultaneously, all starting out at priority 12 and
>> not freeing anything until they all get to much lower
>> priorities.
> 
> BTW, this reminds me that I've been wondering if 2**12 is a too small
> fraction of the lru to start the scan with.

If the system has 1 TB of RAM, it's probably too big
of a fraction :)

We need something smarter.

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
