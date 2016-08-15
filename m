Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 165CE6B025F
	for <linux-mm@kvack.org>; Mon, 15 Aug 2016 18:31:30 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ez1so123582997pab.1
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 15:31:30 -0700 (PDT)
Received: from outbound1a.ore.mailhop.org (outbound1a.ore.mailhop.org. [54.213.22.21])
        by mx.google.com with ESMTPS id q75si28640313pfi.216.2016.08.15.15.31.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Aug 2016 15:31:28 -0700 (PDT)
Date: Mon, 15 Aug 2016 22:31:24 +0000
From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: [mmotm:master 70/106] arch/x86/kernel/process.c:511:9: error:
 implicit declaration of function 'randomize_page'
Message-ID: <20160815223124.GN3353@io.lakedaemon.net>
References: <201608120949.AtRXkB4G%fengguang.wu@intel.com>
 <65DEA104-339F-4EB0-9E98-8959D28BA245@lakedaemon.net>
 <20160815144607.1a6c05709668b3ecd61e55da@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160815144607.1a6c05709668b3ecd61e55da@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>

On Mon, Aug 15, 2016 at 02:46:07PM -0700, Andrew Morton wrote:
> On Thu, 11 Aug 2016 21:31:15 -0400 Jason Cooper <jason@lakedaemon.net> wrote:
> > I think you have v1 and v2 of the randomize page patches in your stack. Could you drop v1 please?

I was wrong here.  The patches are mis-labelled.  The patches labelled
'v2' are deltas regressing to an older version of the series.

> I have the v1 series and a series of deltas which turn that into v2.
> 
> I also see a v3 on the lists so I'm all confused.  Please triple-check
> linux-next versus your latest version.

This is currently in akpm/next:

  9f60fb9385f5 random: remove unused randomize_range()
  81221b53ea05 unicore32-use-simpler-api-for-random-address-requests-v2
  6205f3d87280 unicore32: use simpler API for random address requests
  af8c36a0a66a tile-use-simpler-api-for-random-address-requests-v2
  18c80b9aa3a3 tile: use simpler API for random address requests
  742fffc5251b arm64-use-simpler-api-for-random-address-requests-v2
  f30c92be8d31 arm64: use simpler API for random address requests
  cbcb520687fd arm-use-simpler-api-for-random-address-requests-v2
  f39cdf6eca33 ARM: use simpler API for random address requests
  2f20ec82da2e x86-use-simpler-api-for-random-address-requests-v2
  c8923c663214 x86: use simpler API for random address requests
  027cac3e28bd random-simplify-api-for-random-address-requests-v2
  b990c09770d3 random: simplify API for random address requests

if you remove the patches that match /random-address-requests-v2$/, then
things should be good.  I've confirmed that

  b990c09770d3 random: simplify API for random address requests

is the proper version and that every other patch on top of that
correctly adds randomize_page().  It's the ones labelled 'v2' that are
reverting changes to an older version of the series (randomize_addr).

> I can't reproduced this build error.

It's a build failure that only occurs when a bisect would land in the
middle of the old series.  Removing the patches labelled v2 should fix
it.

Sorry for the confusion.

thx,

Jason.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
