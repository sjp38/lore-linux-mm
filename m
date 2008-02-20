Subject: Re: [PATCH 0/2] cgroup map files: Add a key/value map file type to
 cgroups
In-Reply-To: Your message of "Tue, 19 Feb 2008 21:15:44 -0800"
	<20080220051544.018684000@menage.corp.google.com>
References: <20080220051544.018684000@menage.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20080220054809.86BFC1E3C58@siro.lan>
Date: Wed, 20 Feb 2008 14:48:09 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: menage@google.com
Cc: kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, balbir@in.ibm.com, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

> These patches add a new cgroup control file output type - a map from
> strings to u64 values - and make use of it for the memory controller
> "stat" file.
> 
> It is intended for use when the subsystem wants to return a collection
> of values that are related in some way, for which a separate control
> file for each value would make the reporting unwieldy.
> 
> The advantages of this are:
> 
> - more standardized output from control files that report
> similarly-structured data
> 
> - less boilerplate required in cgroup subsystems
> 
> - simplifies transition to a future efficient cgroups binary API
> 
> Signed-off-by: Paul Menage <menage@google.com>

it changes the format from "%s %lld" to "%s: %llu", right?
why?

YAMAMOTO Takashi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
