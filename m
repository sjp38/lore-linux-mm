Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 46CC06B0035
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 00:39:04 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id w10so23660166pde.23
        for <linux-mm@kvack.org>; Tue, 26 Aug 2014 21:39:03 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id et5si7092557pbb.177.2014.08.26.21.39.02
        for <linux-mm@kvack.org>;
        Tue, 26 Aug 2014 21:39:03 -0700 (PDT)
Date: Wed, 27 Aug 2014 00:38:19 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH 5/9 v2] SQUASHME: prd: Last fixes for partitions
Message-ID: <20140827043819.GD3285@linux.intel.com>
References: <53EB5536.8020702@gmail.com>
 <53EB5709.4090401@plexistor.com>
 <53ECB480.4060104@plexistor.com>
 <1408997403.17731.7.camel@rzwisler-mobl1.amr.corp.intel.com>
 <53FC42C5.6040300@plexistor.com>
 <53FCC593.6020201@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53FCC593.6020201@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <openosd@gmail.com>
Cc: Boaz Harrosh <boaz@plexistor.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Sagi Manole <sagi@plexistor.com>, Yigal Korman <yigal@plexistor.com>

On Tue, Aug 26, 2014 at 08:36:19PM +0300, Boaz Harrosh wrote:
> It is getting late around here and I will not be pushing new trees
> tonight, first thing tomorrow morning. (Your last push caused me lots
> of extra work, you must not do like you did when working on a rebasing
> out-off-tree project involving more then one person, but more on the proper
> procedure tomorrow with the push of the trees)

If you're going to push a new tree, please do so on top of the DAX
v10 patches I just sent out.  If you have any changes you want to make
to the bdev_direct_access() patch, then please make them separately,
instead of editing my patch like you did last time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
