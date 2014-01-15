Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f174.google.com (mail-yk0-f174.google.com [209.85.160.174])
	by kanga.kvack.org (Postfix) with ESMTP id 1CB336B0037
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 20:05:47 -0500 (EST)
Received: by mail-yk0-f174.google.com with SMTP id 10so171547ykt.5
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 17:05:46 -0800 (PST)
Received: from mail-gg0-x229.google.com (mail-gg0-x229.google.com [2607:f8b0:4002:c02::229])
        by mx.google.com with ESMTPS id t26si1047582yhg.192.2014.01.14.17.05.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 14 Jan 2014 17:05:46 -0800 (PST)
Received: by mail-gg0-f169.google.com with SMTP id j5so327773ggn.0
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 17:05:45 -0800 (PST)
Date: Tue, 14 Jan 2014 17:05:42 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC] hotplug, memory: move register_memory_resource out of the
 lock_memory_hotplug
In-Reply-To: <20140114151340.004d25c00056d88f33cadda0@linux-foundation.org>
Message-ID: <alpine.DEB.2.02.1401141702450.3375@chino.kir.corp.google.com>
References: <1389723874-32372-1-git-send-email-nzimmer@sgi.com> <20140114151340.004d25c00056d88f33cadda0@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nathan Zimmer <nzimmer@sgi.com>, Tang Chen <tangchen@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Hedi <hedi@sgi.com>, Mike Travis <travis@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 14 Jan 2014, Andrew Morton wrote:

> From: Andrew Morton <akpm@linux-foundation.org>
> Subject: mm/memory_hotplug.c: register_memory_resource() fixes
> 
> - register_memory_resource() should not go BUG on ENOMEM.  That's
>   appropriate at system boot time, but not at memory-hotplug time.  Fix.
> 
> - register_memory_resource()'s caller is incorrectly replacing
>   request_resource()'s -EBUSY with -EEXIST.  Fix this by propagating
>   errors appropriately.
> 

Unfortunately, -EEXIST is a special case return value for both 
acpi_memory_enable_device() and hv_mem_hot_add(), so they would need to be 
modified to agree concurrently with this change.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
