Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 8C7116B0044
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 17:50:01 -0400 (EDT)
Date: Mon, 26 Aug 2013 14:49:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] [BUGFIX] drivers/base: fix show_mem_removable to
 handle missing sections
Message-Id: <20130826144959.52fd24cd2833929168ee7e35@linux-foundation.org>
In-Reply-To: <20130823162317.GB10988@sgi.com>
References: <20130823162317.GB10988@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russ Anderson <rja@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Yinghai Lu <yinghai@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

On Fri, 23 Aug 2013 11:23:17 -0500 Russ Anderson <rja@sgi.com> wrote:

> "cat /sys/devices/system/memory/memory*/removable" crashed the system.
> 
> The problem is that show_mem_removable() is passing a
> bad pfn to is_mem_section_removable(), which causes
> if (!node_online(page_to_nid(page))) to blow up.
> Why is it passing in a bad pfn?
> 
> show_mem_removable() will loop sections_per_block times.
> sections_per_block is 16, but mem->section_count is 8,
> indicating holes in this memory block.  Checking that
> the memory section is present before checking to see
> if the memory section is removable fixes the problem.

The patch textually applies to 3.10, 3.9 and perhaps earlier.  Should
it be applied to earlier kernels?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
