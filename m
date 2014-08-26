Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id 3B9BE6B0036
	for <linux-mm@kvack.org>; Tue, 26 Aug 2014 13:36:25 -0400 (EDT)
Received: by mail-we0-f181.google.com with SMTP id k48so15126289wev.12
        for <linux-mm@kvack.org>; Tue, 26 Aug 2014 10:36:24 -0700 (PDT)
Received: from mail-wg0-x22f.google.com (mail-wg0-x22f.google.com [2a00:1450:400c:c00::22f])
        by mx.google.com with ESMTPS id c19si5427681wiv.75.2014.08.26.10.36.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 26 Aug 2014 10:36:23 -0700 (PDT)
Received: by mail-wg0-f47.google.com with SMTP id b13so14704087wgh.18
        for <linux-mm@kvack.org>; Tue, 26 Aug 2014 10:36:23 -0700 (PDT)
Message-ID: <53FCC593.6020201@gmail.com>
Date: Tue, 26 Aug 2014 20:36:19 +0300
From: Boaz Harrosh <openosd@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/9 v2] SQUASHME: prd: Last fixes for partitions
References: <53EB5536.8020702@gmail.com> <53EB5709.4090401@plexistor.com>	 <53ECB480.4060104@plexistor.com> <1408997403.17731.7.camel@rzwisler-mobl1.amr.corp.intel.com> <53FC42C5.6040300@plexistor.com>
In-Reply-To: <53FC42C5.6040300@plexistor.com>
Content-Type: multipart/mixed;
 boundary="------------050203010809090701030701"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Matthew Wilcox <willy@linux.intel.com>, Sagi Manole <sagi@plexistor.com>, Yigal Korman <yigal@plexistor.com>

This is a multi-part message in MIME format.
--------------050203010809090701030701
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

On 08/26/2014 11:18 AM, Boaz Harrosh wrote:
> On 08/25/2014 11:10 PM, Ross Zwisler wrote:
> <>
>> I think we can still have a working probe by instead comparing the passed in
>> dev_t against the dev_t we get back from disk_to_dev(prd->prd_disk), but I'd
>> really like a use case so I can test this.  Until then I think I'm just going
>> to stub out prd/pmem_probe() with a BUG() so we can see if anyone hits it.
>>
>> It seems like this is preferable to just registering NULL for probe, as that
>> would cause an oops in kobj_lookup(() when probe() is blindly called without
>> checking for NULL.
>>
> 
> I have a version I think you will love it removes the probe and bunch of
> other stuff.
> 
> I tested it heavily it just works
> 
> Comming soon, I'm preparing trees right now
> Thanks
> Boaz

Ross hi

It is getting late around here and I will not be pushing new trees
tonight, first thing tomorrow morning. (Your last push caused me lots
of extra work, you must not do like you did when working on a rebasing
out-off-tree project involving more then one person, but more on the proper
procedure tomorrow with the push of the trees)

So I hope you are not doing any big changes, do not apply any of my patches
just yet, wait for the new trees tomorrow please I have everything all ready
on top of the rename to pmem

Meanwhile without any explanations, these will come tomorrow, I'm attaching
the most interesting bit which you have not seen before.

If you want you can inspect a preview of what's to come here:
	http://git.open-osd.org/gitweb.cgi?p=pmem.git;a=summary

I have created a new pmem.git tree just for us.

Thanks
Boaz


--------------050203010809090701030701
Content-Type: text/x-patch;
 name="0012-SQUASHME-pmem-KISS-remove-the-all-pmem_major-registr.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0012-SQUASHME-pmem-KISS-remove-the-all-pmem_major-registr.pa";
 filename*1="tch"


--------------050203010809090701030701--
