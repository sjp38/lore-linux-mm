Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0EECF6B711D
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 17:49:47 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id q64so15145364pfa.18
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 14:49:47 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g31si18901542pld.358.2018.12.04.14.49.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 14:49:46 -0800 (PST)
Date: Tue, 4 Dec 2018 14:49:42 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/4] mm: infrastructure for page fault page caching
Message-Id: <20181204144942.63c98a3147071f054d77427d@linux-foundation.org>
In-Reply-To: <20181130195812.19536-2-josef@toxicpanda.com>
References: <20181130195812.19536-1-josef@toxicpanda.com>
	<20181130195812.19536-2-josef@toxicpanda.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>
Cc: kernel-team@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, tj@kernel.org, david@fromorbit.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, jack@suse.cz

On Fri, 30 Nov 2018 14:58:09 -0500 Josef Bacik <josef@toxicpanda.com> wrote:

> We want to be able to cache the result of a previous loop of a page
> fault in the case that we use VM_FAULT_RETRY,

Please explain here why we want to do that.

> so introduce
> handle_mm_fault_cacheable that will take a struct vm_fault directly, add
> a ->cached_page field to vm_fault, and add helpers to init/cleanup the
> struct vm_fault.
> 
> I've converted x86, other arch's can follow suit if they so wish, it's
> relatively straightforward.
> 
