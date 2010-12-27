Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id F10A06B0087
	for <linux-mm@kvack.org>; Mon, 27 Dec 2010 11:28:46 -0500 (EST)
MIME-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
Date: Mon, 27 Dec 2010 19:27:56 +0300
From: Vasiliy G Tolstov <v.tolstov@selfip.ru>
Subject: Re: [PATCH 2/3] drivers/xen/balloon.c: Various balloon features and
 fixes
Reply-To: v.tolstov@selfip.ru
In-Reply-To: <20101227150847.GA3728@dumpdata.com>
References: <20101220134724.GC6749@router-fw-old.local.net-space.pl>
 <20101227150847.GA3728@dumpdata.com>
Message-ID: <947c7677e042b3fd1ca22d775ca9aeb9@imap.selfip.ru>
Sender: owner-linux-mm@kvack.org
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Daniel Kiper <dkiper@net-space.pl>, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, dan.magenheimer@oracle.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 27 Dec 2010 10:08:47 -0500, Konrad Rzeszutek Wilk
<konrad.wilk@oracle.com> wrote:
> On Mon, Dec 20, 2010 at 02:47:24PM +0100, Daniel Kiper wrote:
>> Features and fixes:
>>   - HVM mode is supported now,
>>   - migration from mod_timer() to schedule_delayed_work(),
>>   - removal of driver_pages (I do not have seen any
>>     references to it),
>>   - protect before CPU exhaust by event/x process during
>>     errors by adding some delays in scheduling next event,
>>   - some other minor fixes.

I have apply this patch to bare 2.6.36.2 kernel from kernel.org. If
memory=maxmemory pv guest run's on migrating fine.
If on already running domU i have xm mem-max xxx 1024 (before that it
has 768) and do xm mem-set 1024 guest now have 1024 memory, but after
that it can't migrate to another host.

Step to try to start guest with memory=512 and maxmemory=1024 it boot
fine, xm mem-set work's fine, but.. it can't migrate. Sorry but nothing
on screen , how can i help to debug this problem?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
