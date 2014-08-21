Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 4D7036B0035
	for <linux-mm@kvack.org>; Thu, 21 Aug 2014 06:05:52 -0400 (EDT)
Received: by mail-wi0-f182.google.com with SMTP id d1so8170685wiv.9
        for <linux-mm@kvack.org>; Thu, 21 Aug 2014 03:05:51 -0700 (PDT)
Received: from mail-we0-x230.google.com (mail-we0-x230.google.com [2a00:1450:400c:c03::230])
        by mx.google.com with ESMTPS id kd8si40713856wjc.174.2014.08.21.03.05.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 21 Aug 2014 03:05:50 -0700 (PDT)
Received: by mail-we0-f176.google.com with SMTP id q58so9098271wes.21
        for <linux-mm@kvack.org>; Thu, 21 Aug 2014 03:05:50 -0700 (PDT)
Message-ID: <53F5C47B.5090800@gmail.com>
Date: Thu, 21 Aug 2014 13:05:47 +0300
From: Boaz Harrosh <openosd@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC 5/9] SQUASHME: prd: Last fixes for partitions
References: <53EB5536.8020702@gmail.com> <53EB5709.4090401@plexistor.com> <1408575780.26863.21.camel@rzwisler-mobl1.amr.corp.intel.com>
In-Reply-To: <1408575780.26863.21.camel@rzwisler-mobl1.amr.corp.intel.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>, Boaz Harrosh <boaz@plexistor.com>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>, Sagi Manole <sagi@plexistor.com>, Yigal Korman <yigal@plexistor.com>

On 08/21/2014 02:03 AM, Ross Zwisler wrote:
> On Wed, 2014-08-13 at 15:16 +0300, Boaz Harrosh wrote:
<>
> 
> I really like where you're going with getting rid of prd_probe.  Clearly I
> just copied this from brd, but I'd love to be rid of it entirely.  Is there a
> valid way for our probe function to get called?  If not, can we just have a
> little stub with a BUG() in it to make sure we hear about it if it does ever
> get called, and delete a bunch of code?
> 
> I think this would let us get rid of pmem_probe(), pmem_init_one(), and the
> pmem_devices_mutex.
> 

You lost me, pmem_init_one() is gone already, and yes the mutex can go away
as well right now after this patch. But please lets keep it I want to add
a sysfs interface to add more devices dynamically similar to osdblk.

The only thing I want to clean is the the pmem_free + pmem_del_one it can
be reduced to just one function.

> If there *is* a valid way for this code to get called, let's figure it out so
> we can at least test this function.  This will be especially necessary as we
> add support for more pmem disks.
> 

Let me investigate this one, I think we can get rid of it for sure, by
passing NULL to register. Surly there is no use case for it now.

>>  
>> @@ -424,5 +423,7 @@ static void __exit prd_exit(void)
>>  
>>  MODULE_AUTHOR("Ross Zwisler <ross.zwisler@linux.intel.com>");
>>  MODULE_LICENSE("GPL");
>> +MODULE_ALIAS("pmem");
> 
> Let's just go with the full rename s/prd/pmem/.  That turned out to be really
> clean & made everything consistent - thanks for the good suggestion.
> 

hooray, yes thanks, this makes me very happy.

> - Ross
> 

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
