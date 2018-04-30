Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id F2B646B0005
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 19:15:17 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id b18-v6so6817374pgv.14
        for <linux-mm@kvack.org>; Mon, 30 Apr 2018 16:15:17 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a12-v6si7004071pgd.102.2018.04.30.16.15.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Apr 2018 16:15:16 -0700 (PDT)
Date: Mon, 30 Apr 2018 16:15:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/2] mm: tweaks for improving use of vmap_area
Message-Id: <20180430161515.118e6538e4d4f1cc4ae425cc@linux-foundation.org>
In-Reply-To: <20180426234243.22267-1-igor.stoppa@huawei.com>
References: <20180426234243.22267-1-igor.stoppa@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@gmail.com>
Cc: willy@infradead.org, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, igor.stoppa@huawei.com

On Fri, 27 Apr 2018 03:42:41 +0400 Igor Stoppa <igor.stoppa@gmail.com> wrote:

> These two patches were written in preparation for the creation of
> protectable memory, however their use is not limited to pmalloc and can
> improve the use of virtally contigous memory.
> 
> The first provides a faster path from struct page to the vm_struct that
> tracks it.
> 
> The second patch renames a single linked list field inside of vmap_area.
> The list is currently used only for disposing of the data structure, once
> it is not in use anymore.
> Which means that it cold be used for other purposes while it'not queued
> for destruction.

The patches look benign to me (feel free to add my ack), but I'm not
seeing a reason to apply them at this time?
