Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 363976B0032
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 12:08:04 -0400 (EDT)
Date: Fri, 23 Aug 2013 11:08:02 -0500
From: Russ Anderson <rja@sgi.com>
Subject: Re: [PATCH] [BUGFIX] drivers/base: fix show_mem_removable section
	count
Message-ID: <20130823160802.GA10988@sgi.com>
Reply-To: Russ Anderson <rja@sgi.com>
References: <20130823023837.GA12396@sgi.com> <52170DDE.4010103@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52170DDE.4010103@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Yinghai Lu <yinghai@kernel.org>

On Fri, Aug 23, 2013 at 04:23:10PM +0900, Yasuaki Ishimatsu wrote:
>
> I don't think it works well.
> mem->section_count means how many present section is in the memory_block.
> If 0, 1, 3 and 4 sections are present in the memory_block, mem->section_count
> is 4. In this case, is_mem_sectionremovable is called for section 2. But the
> section is not present. So if the memory_block has hole, same problem will occur.
>
> How about keep sections_per_block loop and add following check:
>
> 		if (!present_section_nr(mem->start_section_nr + i))
> 			continue;

Yes, I will make that change and resubmit the patch.
Thanks.

> Thanks,
> Yasuaki Ishimatsu

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
