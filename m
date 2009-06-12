Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 51BD56B004D
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 00:40:04 -0400 (EDT)
Received: by yw-out-1718.google.com with SMTP id 5so951421ywm.26
        for <linux-mm@kvack.org>; Thu, 11 Jun 2009 21:41:19 -0700 (PDT)
MIME-Version: 1.0
Date: Fri, 12 Jun 2009 16:41:19 +1200
Message-ID: <202cde0e0906112141n634c1bd6n15ec1ac42faa36d3@mail.gmail.com>
Subject: Huge pages for device drivers
From: Alexey Korolev <akorolex@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi,

I'm investigating the possibility to involve huge pages mappings in
order to increase data analysing performance in case of device
drivers.
The model we have is more or less common: We have driver which
allocates memory and configures DMA. This memory is then shared to
user mode applications to allow user-mode daemons to analyse and
process the data.

In this case Huge TLB could be quite useful because DMA buffers are
large ~64MB - 1024MB and desired performance of data analysing in user
mode is huge ~10Gb/s.

If I properly understood the code the only available approach is :
Allocate huge page memory in user mode application. Then supply it to
driver. Then do magic to obtain physical address and try to configure
DMAs. But this approach leads to big bunch of problems because: 1.
Virtual address can be remapped to another physical address. 2. It is
necessary to manage GFP flags manually (GFP_DMA32 must be set).

So the question I have:
1. Is it definitely the only way to provide huge page mappings in this
case.  May be I miss something.
2. Is there any plans to provide interfaces for device drivers to map
huge pages? What are possible issues to have it?


Thanks,
Alexey

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
