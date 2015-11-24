Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id EC1466B0038
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 00:10:19 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so9617547pab.0
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 21:10:19 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTPS id r68si24423453pfi.233.2015.11.23.21.10.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 23 Nov 2015 21:10:19 -0800 (PST)
Date: Tue, 24 Nov 2015 13:55:36 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: hugepage compaction causes performance drop
Message-ID: <20151124045536.GA3112@js1304-P5Q-DELUXE>
References: <20151119092920.GA11806@aaronlu.sh.intel.com>
 <564DCEA6.3000802@suse.cz>
 <564EDFE5.5010709@intel.com>
 <564EE8FD.7090702@intel.com>
 <564EF0B6.10508@suse.cz>
 <20151123081601.GA29397@js1304-P5Q-DELUXE>
 <5652CF40.6040400@intel.com>
 <CAAmzW4M6oJukBLwucByK89071RukF4UEyt02A7ZjenpPr5rsdQ@mail.gmail.com>
 <5653DC2C.3090706@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5653DC2C.3090706@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Linux Memory Management List <linux-mm@kvack.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, lkp@lists.01.org, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>

On Tue, Nov 24, 2015 at 11:40:28AM +0800, Aaron Lu wrote:
> On 11/23/2015 05:24 PM, Joonsoo Kim wrote:
> > 2015-11-23 17:33 GMT+09:00 Aaron Lu <aaron.lu@intel.com>:
> >> On 11/23/2015 04:16 PM, Joonsoo Kim wrote:
> >>>
> >>> And, please attach always-always's vmstat numbers, too.
> >>
> >> Sure, attached the vmstat tool output, taken every second.
> > 
> > Oops... I'd like to see '1 sec interval cat /proc/vmstat' for always-never.
> 
> Here it is, the proc-vmstat for always-never.

Okay. In this case, compaction never happen.
Could you show 1 sec interval cat /proc/pagetypeinfo for
always-always?

> BTW, I'm still learning how to do proper ftrace for this case and it may
> take a while.

You can do it simply with trace-cmd.

sudo trace-cmd record -e compaction &
run test program
fg
Ctrl + c

sudo trace-cmd report

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
