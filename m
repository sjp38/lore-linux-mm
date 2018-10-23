Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0401C6B0003
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 21:56:46 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id t74-v6so7273617wmt.0
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 18:56:45 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id s189-v6si33117wme.162.2018.10.22.18.56.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 22 Oct 2018 18:56:44 -0700 (PDT)
Subject: Re: [PATCH 2/9] dax: kernel memory driver for mm ownership of DAX
References: <20181022201317.8558C1D8@viggo.jf.intel.com>
 <20181022201320.45C9785C@viggo.jf.intel.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <ddd650d6-6a0f-6c57-f55f-af31264c4f44@infradead.org>
Date: Mon, 22 Oct 2018 18:56:29 -0700
MIME-Version: 1.0
In-Reply-To: <20181022201320.45C9785C@viggo.jf.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org
Cc: dan.j.williams@intel.com, dave.jiang@intel.com, zwisler@kernel.org, vishal.l.verma@intel.com, thomas.lendacky@amd.com, akpm@linux-foundation.org, mhocko@suse.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, ying.huang@intel.com, fengguang.wu@intel.com

On 10/22/18 1:13 PM, Dave Hansen wrote:
> Add the actual driver to which will own the DAX range.  This
> allows very nice party with the other possible "owners" of

Good to see a nice party sometimes.  :)

> a DAX region: device DAX and filesystem DAX.  It also greatly
> simplifies the process of handing off control of the memory
> between the different owners since it's just a matter of
> unbinding and rebinding the device to different drivers.


-- 
~Randy
