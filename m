Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 186CE6B0005
	for <linux-mm@kvack.org>; Mon, 18 Mar 2013 02:41:07 -0400 (EDT)
Received: by mail-qa0-f48.google.com with SMTP id j8so1450581qah.14
        for <linux-mm@kvack.org>; Sun, 17 Mar 2013 23:41:06 -0700 (PDT)
Date: Mon, 18 Mar 2013 14:40:57 +0800
From: Shaohua Li <shli@kernel.org>
Subject: Re: [patch 1/4 v3]swap: change block allocation algorithm for SSD
Message-ID: <20130318064057.GA7903@kernel.org>
References: <20130221021710.GA32580@kernel.org>
 <20130318050918.GB7016@kernel.org>
 <5146A31A.5090705@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5146A31A.5090705@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: linux-mm@kvack.org, hughd@google.com, riel@redhat.com, minchan@kernel.org, kmpark@infradead.org, akpm@linux-foundation.org

On Mon, Mar 18, 2013 at 01:16:10PM +0800, Simon Jeons wrote:
> On 03/18/2013 01:09 PM, Shaohua Li wrote:
> >Ping! are there any comments for this series?
> 
> Could you show me your benchmark and testcase?

I use usemem from ext3-tools. It's a simple multi-thread/process mmap() test.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
