Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id DAA16526
	for <linux-mm@kvack.org>; Thu, 6 Mar 2003 03:01:31 -0800 (PST)
Date: Thu, 6 Mar 2003 03:01:29 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.64-mm1
Message-Id: <20030306030129.49f5c96f.akpm@digeo.com>
In-Reply-To: <20030305230712.5a0ec2d4.akpm@digeo.com>
References: <20030305230712.5a0ec2d4.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@digeo.com> wrote:
>
> 
> http://www.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.64/2.5.64-mm1/
> 

It doesn't build with gcc-3.2.1.  Please put a

	#include <linux/string.h>

into include/linux/genhd.h


Also, the remap_file_pages changes make 2.5.64-mm1 an x86-only kernel.


And, with gcc-3.2.1:

mnm:/usr/src/25> nm vmlinux|grep __constant_memcpy | wc
    129     387    3741
mnm:/usr/src/25> nm vmlinux|grep __constant_c_and_count_memset | wc
    233     699    9553

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
