Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 8B57C6B0005
	for <linux-mm@kvack.org>; Sun, 20 Jan 2013 20:51:27 -0500 (EST)
Message-ID: <50FC9EDB.7060105@cn.fujitsu.com>
Date: Mon, 21 Jan 2013 09:50:19 +0800
From: Lin Feng <linfeng@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memory-hotplug: mm/Kconfig: move auto selects from MEMORY_HOTPLUG
 to MEMORY_HOTREMOVE as needed
References: <1358495676-4488-1-git-send-email-linfeng@cn.fujitsu.com> <20130118135828.GD10701@dhcp22.suse.cz>
In-Reply-To: <20130118135828.GD10701@dhcp22.suse.cz>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Michal,

On 01/18/2013 09:58 PM, Michal Hocko wrote:
> On Fri 18-01-13 15:54:36, Lin Feng wrote:
>> Besides page_isolation.c selected by MEMORY_ISOLATION under MEMORY_HOTPLUG
>> is also such case, move it too.
> 
> Yes, it seems that only HOTREMOVE needs MEMORY_ISOLATION but that should
> be done in a separate patch as this change is already upstream and
> should be merged separately. It would also be nice to mention which
I didn't notice such rules before, I will take care next time :)

> functions are we talking about. AFAICS:
> alloc_migrate_target, test_pages_isolated, start_isolate_page_range and
> undo_isolate_page_range.
> 
Anyway, thanks all your good suggestions for the fixes in this series.

thanks again,
linfeng 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
