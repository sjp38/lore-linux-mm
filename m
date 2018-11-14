Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1A0F76B0003
	for <linux-mm@kvack.org>; Wed, 14 Nov 2018 17:20:27 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id d3so6317315pgv.23
        for <linux-mm@kvack.org>; Wed, 14 Nov 2018 14:20:27 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v9-v6sor28175764pgr.13.2018.11.14.14.20.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 14 Nov 2018 14:20:25 -0800 (PST)
Date: Wed, 14 Nov 2018 14:20:22 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: mmap: remove verify_mm_writelocked()
In-Reply-To: <20181108174856.10811-1-tiny.windzz@gmail.com>
Message-ID: <alpine.DEB.2.21.1811141420110.212061@chino.kir.corp.google.com>
References: <20181108174856.10811-1-tiny.windzz@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yangtao Li <tiny.windzz@gmail.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com, linux@dominikbrodowski.net, dave.hansen@linux.intel.com, dwmw@amazon.co.uk, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 8 Nov 2018, Yangtao Li wrote:

> We should get rid of this function. It no longer serves its purpose.This
> is a historical artifact from 2005 where do_brk was called outside of
> the core mm.We do have a proper abstraction in vm_brk_flags and that one
> does the locking properly.So there is no need to use this function.
> 
> Signed-off-by: Yangtao Li <tiny.windzz@gmail.com>

Acked-by: David Rientjes <rientjes@google.com>
