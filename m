Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 80CDB6B0044
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 13:19:29 -0400 (EDT)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Mon, 23 Apr 2012 11:19:28 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 697863E4004E
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 11:19:25 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3NHJNcj207652
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 11:19:23 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3NHJMr7015295
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 11:19:22 -0600
Message-ID: <4F958F13.1000005@linux.vnet.ibm.com>
Date: Mon, 23 Apr 2012 10:19:15 -0700
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: Over-eager swapping
References: <20120423092730.GB20543@alpha.arachsys.com>
In-Reply-To: <20120423092730.GB20543@alpha.arachsys.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Davies <richard@arachsys.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Christoph Lameter <cl@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Chris Webb <chris@arachsys.com>, Badari <pbadari@us.ibm.com>

On 04/23/2012 02:27 AM, Richard Davies wrote:
> # cat /proc/meminfo
> MemTotal:       65915384 kB
> MemFree:          271104 kB
> Buffers:        36274368 kB

Your "Buffers" are the only thing that really stands out here.  We used
to see this kind of thing on ext3 a lot, but it's gotten much better
lately.  From slabinfo, you can see all the buffer_heads:

buffer_head       8175114 8360937    104   39    1 : tunables    0    0
   0 : slabdata 214383 214383      0

I _think_ this was a filesystems issue where the FS for some reason kept
the buffers locked down.  The swapping just comes later as so much of
RAM is eaten up by buffers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
