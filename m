Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f178.google.com (mail-io0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 077516B025E
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 23:03:22 -0500 (EST)
Received: by iofh3 with SMTP id h3so82783208iof.3
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 20:03:21 -0800 (PST)
Received: from cdptpa-oedge-vip.email.rr.com (cdptpa-outbound-snat.email.rr.com. [107.14.166.231])
        by mx.google.com with ESMTP id nr4si17266708igb.68.2015.12.09.20.03.21
        for <linux-mm@kvack.org>;
        Wed, 09 Dec 2015 20:03:21 -0800 (PST)
Date: Wed, 9 Dec 2015 23:03:19 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 1/2] mm, printk: introduce new format string for flags
Message-ID: <20151210040319.GB7814@home.goodmis.org>
References: <20151125143010.GI27283@dhcp22.suse.cz>
 <1448899821-9671-1-git-send-email-vbabka@suse.cz>
 <4EAD2C33-D0E4-4DEB-92E5-9C0457E8635C@gmail.com>
 <565F5CD9.9080301@suse.cz>
 <1F60C207-1CC2-4B28-89AC-58C72D95A39D@gmail.com>
 <87a8psq7r6.fsf@rasmusvillemoes.dk>
 <89A4C9BC-47F6-4768-8AA8-C1C4EFEFC52D@gmail.com>
 <5661A011.2010400@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <5661A011.2010400@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: yalin wang <yalin.wang2010@gmail.com>, Rasmus Villemoes <linux@rasmusvillemoes.dk>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>

On Fri, Dec 04, 2015 at 03:15:45PM +0100, Vlastimil Babka wrote:
> On 12/03/2015 07:38 PM, yalin wang wrote:
> >thata??s all, see cpumask_pr_args(masks) macro,
> >it also use macro and  %*pb  to print cpu mask .
> >i think this method is not very complex to use .
> 
> Well, one also has to write the appropriate translation tables.
> 
> >search source code ,
> >there is lots of printk to print flag into hex number :
> >$ grep -n  -r 'printk.*flag.*%xa??  .
> >it will be great if this flag string print is generic.
> 
> I think it can always be done later, this is an internal API. For now we
> just have 3 quite generic flags, so let's not over-engineer things right
> now.
> 

As long as it is never used in the TP_printk() part of a tracepoint. As soon
as it is, trace-cmd and perf will update parse-events to handle that
parameter, and as soon as that is done, it becomes a userspace ABI.

Just be warned.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
