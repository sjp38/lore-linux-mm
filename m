Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 32FBD6B0270
	for <linux-mm@kvack.org>; Sat, 28 Jan 2017 23:00:37 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id d123so156150365pfd.0
        for <linux-mm@kvack.org>; Sat, 28 Jan 2017 20:00:37 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTPS id p17si5525186pgi.67.2017.01.28.20.00.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 28 Jan 2017 20:00:36 -0800 (PST)
Subject: Re: [RFC PATCH 0/4] Fast noirq bulk page allocator v2r7
References: <20170109163518.6001-1-mgorman@techsingularity.net>
From: Andy Lutomirski <luto@kernel.org>
Message-ID: <76b3372e-591c-186d-d8ce-f950eea997cf@kernel.org>
Date: Sat, 28 Jan 2017 20:00:33 -0800
MIME-Version: 1.0
In-Reply-To: <20170109163518.6001-1-mgorman@techsingularity.net>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hillf Danton <hillf.zj@alibaba-inc.com>

On 01/09/2017 08:35 AM, Mel Gorman wrote:
> The
> fourth patch introduces a bulk page allocator with no in-kernel users as
> an example for Jesper and others who want to build a page allocator for
> DMA-coherent pages.

If you want an in-kernel user as a test, to validate the API's sanity, 
and to improve performance, how about __vmalloc_area_node()?  :)

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
