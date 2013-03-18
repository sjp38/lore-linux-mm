Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 74C726B0002
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 02:49:27 -0400 (EDT)
Received: by mail-qe0-f54.google.com with SMTP id i11so3127630qej.13
        for <linux-mm@kvack.org>; Sun, 17 Mar 2013 23:49:26 -0700 (PDT)
Message-ID: <5146B8F0.4090106@gmail.com>
Date: Mon, 18 Mar 2013 14:49:20 +0800
From: Simon Jeons <simon.jeons@gmail.com>
MIME-Version: 1.0
Subject: Re: [patch 1/4 v3]swap: change block allocation algorithm for SSD
References: <20130221021710.GA32580@kernel.org> <20130318050918.GB7016@kernel.org> <5146A31A.5090705@gmail.com> <20130318064057.GA7903@kernel.org>
In-Reply-To: <20130318064057.GA7903@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, hughd@google.com, riel@redhat.com, minchan@kernel.org, kmpark@infradead.org, akpm@linux-foundation.org

On 03/18/2013 02:40 PM, Shaohua Li wrote:
> On Mon, Mar 18, 2013 at 01:16:10PM +0800, Simon Jeons wrote:
>> On 03/18/2013 01:09 PM, Shaohua Li wrote:
>>> Ping! are there any comments for this series?
>> Could you show me your benchmark and testcase?
> I use usemem from ext3-tools. It's a simple multi-thread/process mmap() test.

Thanks, I know this tool. "scan_swap_map() sometimes uses up to 20~30% 
CPU time(when cluster is hard to find, the CPU time can be up to 80%)", 
how you monitor cpu utilization? how can predicate cpu utilization which 
specific function use?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
