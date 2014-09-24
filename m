Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id F25866B0035
	for <linux-mm@kvack.org>; Wed, 24 Sep 2014 02:24:16 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id rd3so830499pab.0
        for <linux-mm@kvack.org>; Tue, 23 Sep 2014 23:24:16 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id fb7si24767942pab.30.2014.09.23.23.24.15
        for <linux-mm@kvack.org>;
        Tue, 23 Sep 2014 23:24:15 -0700 (PDT)
Date: Wed, 24 Sep 2014 02:24:10 -0400 (EDT)
Message-Id: <20140924.022410.1707532643268164791.davem@davemloft.net>
Subject: Re: mmotm 2014-09-22-16-57 uploaded
From: David Miller <davem@davemloft.net>
In-Reply-To: <20140924043423.GA28993@roeck-us.net>
References: <5421E7E1.80203@infradead.org>
	<20140923215356.GA15481@roeck-us.net>
	<20140924043423.GA28993@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux@roeck-us.net
Cc: rdunlap@infradead.org, akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz

From: Guenter Roeck <linux@roeck-us.net>
Date: Tue, 23 Sep 2014 21:34:23 -0700

> On Tue, Sep 23, 2014 at 02:53:56PM -0700, Guenter Roeck wrote:
>> 
>> > Neither of these patches enables CONFIG_NET.  They just add dependencies.
>> > 
>> This means CONFIG_NET is now disabled in at least 31 configurations where
>> it used to be enabled before (per my count), and there may be additional
>> impact due to the additional changes of "select X" to "depends on X".
>> 
>> 3.18 is going to be interesting.
>> 
> Actually, turns out the changes are already in 3.17.
> 
> In case anyone is interested, here is a list of now broken configurations
> (where 'broken' is defined as "CONFIG NET used to be defined, but
> is not defined anymore"). No guarantee for completeness or correctness.

I'll sort this out completely tomorrow.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
