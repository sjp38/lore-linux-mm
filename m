Message-ID: <3D86CF0E.3090003@sap.com>
Date: Tue, 17 Sep 2002 08:43:26 +0200
From: Christoph Rohland <cr@sap.com>
MIME-Version: 1.0
Subject: Re: dbench on tmpfs OOM's
References: <20020917044317.GZ2179@holomorphy.com> <3D86B683.8101C1D1@digeo.com> <20020917051501.GM3530@holomorphy.com> <3D86BE4F.75C9B6CC@digeo.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org, hugh@veritas.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,

Andrew Morton wrote:
> William Lee Irwin III wrote:
>>I went through the nodes by hand. It's just a run of the mill
>>ZONE_NORMAL OOM coming out of the GFP_USER allocation. None of
>>the highmem zones were anywhere near ->pages_low.
>>
>>
> 
> erk.  Why is shmem using GFP_USER?
> 
> mnm:/usr/src/25> grep page_address mm/shmem.c

For inode and page vector allocation.

Greetings
			Christoph



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
