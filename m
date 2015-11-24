Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 20BC46B0255
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 02:28:02 -0500 (EST)
Received: by pacej9 with SMTP id ej9so13380825pac.2
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 23:28:01 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id da6si24816066pad.156.2015.11.23.23.28.00
        for <linux-mm@kvack.org>;
        Mon, 23 Nov 2015 23:28:00 -0800 (PST)
Subject: Re: hugepage compaction causes performance drop
References: <20151119092920.GA11806@aaronlu.sh.intel.com>
 <564DCEA6.3000802@suse.cz> <564EDFE5.5010709@intel.com>
 <564EE8FD.7090702@intel.com> <564EF0B6.10508@suse.cz>
 <20151123081601.GA29397@js1304-P5Q-DELUXE> <5652CF40.6040400@intel.com>
 <CAAmzW4M6oJukBLwucByK89071RukF4UEyt02A7ZjenpPr5rsdQ@mail.gmail.com>
 <5653DC2C.3090706@intel.com> <20151124045536.GA3112@js1304-P5Q-DELUXE>
From: Aaron Lu <aaron.lu@intel.com>
Message-ID: <5654116F.1030301@intel.com>
Date: Tue, 24 Nov 2015 15:27:43 +0800
MIME-Version: 1.0
In-Reply-To: <20151124045536.GA3112@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Linux Memory Management List <linux-mm@kvack.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, lkp@lists.01.org, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>

On 11/24/2015 12:55 PM, Joonsoo Kim wrote:
> On Tue, Nov 24, 2015 at 11:40:28AM +0800, Aaron Lu wrote:
>> BTW, I'm still learning how to do proper ftrace for this case and it may
>> take a while.
> 
> You can do it simply with trace-cmd.
> 
> sudo trace-cmd record -e compaction &
> run test program
> fg
> Ctrl + c
> 
> sudo trace-cmd report

Thanks for the tip, I just recorded it like this:
trace-cmd record -e compaction ./usemem xxx

Due to the big size of trace.out(6MB after compress), I've uploaed it:
https://drive.google.com/open?id=0B49uX3igf4K4UkJBOGt3cHhOU00

The pagetypeinfo, perf and proc-vmstat is also there.

Regards,
Aaron

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
