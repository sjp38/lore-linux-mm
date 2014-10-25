Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id 6548D6B0069
	for <linux-mm@kvack.org>; Sat, 25 Oct 2014 08:51:33 -0400 (EDT)
Received: by mail-lb0-f175.google.com with SMTP id u10so3823142lbd.34
        for <linux-mm@kvack.org>; Sat, 25 Oct 2014 05:51:32 -0700 (PDT)
Received: from mail.efficios.com (mail.efficios.com. [78.47.125.74])
        by mx.google.com with ESMTP id jd2si11170352lbc.91.2014.10.25.05.51.31
        for <linux-mm@kvack.org>;
        Sat, 25 Oct 2014 05:51:31 -0700 (PDT)
Date: Sat, 25 Oct 2014 12:51:25 +0000 (UTC)
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Message-ID: <465653369.1985.1414241485934.JavaMail.zimbra@efficios.com>
In-Reply-To: <1254279794.1957.1414240389301.JavaMail.zimbra@efficios.com>
Subject: Progress on system crash traces with LTTng using DAX and pmem
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: lttng-dev <lttng-dev@lists.lttng.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Matthew, Hi Ross,

A quick follow up on my progress on using DAX and pmem with
LTTng. I've been able to successfully gather a user-space
trace into buffers mmap'd into an ext4 filesystem within
a pmem block device mounted with -o dax to bypass the page
cache. After a soft reboot, I'm able to mount the partition
again, and gather the very last data collected in the buffers
by the applications. I created a "lttng-crash" program that
extracts data from those buffers and converts the content
into a readable Common Trace Format trace. So I guess
you have a use-case for your patchsets on commodity hardware
right there. :)

I've been asked by my customers if DAX would work well with
mtd-ram, which they are using. To you foresee any roadblock
with this approach ?

FYI, the main reason why my customer wants to go with a
"trace into memory that survives soft reboot" approach
rather than to use things like kexec/kdump is that they
care about the amount of time it takes to reboot their
machines. They want a solution where they can extract the
detailed crash data after reboot, after the machine is
back online, rather than requiring a few minutes of offline
time to extract the crash details.

So I guess next year I'll probably be looking into
allocating the LTTng kernel tracer buffers into an mmap'd file
within a ext2/4-DAX-over-pmem/mtd-ram filesystem. It's going
to be exciting! :)

Please keep me in CC on your next patch versions. I'm willing
to spend some more time reviewing them if needed. By the way,
do you guys have a target time-frame/kernel version you aim
at for getting this work upstream ?

Thanks,

Mathieu

-- 
Mathieu Desnoyers
EfficiOS Inc.
http://www.efficios.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
