Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id B87FB6B0313
	for <linux-mm@kvack.org>; Fri, 26 Oct 2018 09:58:11 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id d8-v6so621854pgq.3
        for <linux-mm@kvack.org>; Fri, 26 Oct 2018 06:58:11 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id m9-v6si11437540pge.326.2018.10.26.06.58.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Oct 2018 06:58:10 -0700 (PDT)
Subject: Re: [PATCH 0/9] Allow persistent memory to be used like normal RAM
References: <20181022201317.8558C1D8@viggo.jf.intel.com>
 <CAPcyv4hxs-GnmwQU1wPZyg5aydCY5K09-YpSrrLpvU1v_8dbBw@mail.gmail.com>
 <CAPcyv4hFoPkda0YfNKo=nFxttyBG3OjD7vKWyNzLY+8T5gLc=g@mail.gmail.com>
 <352acc87-a6da-65e4-bbe6-0dbffdc72acc@gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <b6239107-3c49-8041-babd-844eef84c361@intel.com>
Date: Fri, 26 Oct 2018 06:58:08 -0700
MIME-Version: 1.0
In-Reply-To: <352acc87-a6da-65e4-bbe6-0dbffdc72acc@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@gmail.com>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Dave Jiang <dave.jiang@intel.com>, zwisler@kernel.org, Vishal L Verma <vishal.l.verma@intel.com>, Tom Lendacky <thomas.lendacky@amd.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, "Huang, Ying" <ying.huang@intel.com>, Fengguang Wu <fengguang.wu@intel.com>, Xishi Qiu <qiuxishi@linux.alibaba.com>, zy107165@alibaba-inc.com

On 10/26/18 1:03 AM, Xishi Qiu wrote:
> How about let the BIOS report a new type for kmem in e820 table?
> e.g.
> #define E820_PMEM	7
> #define E820_KMEM	8

It would be best if the BIOS just did this all for us.  But, what you're
describing would take years to get from concept to showing up in
someone's hands.  I'd rather not wait.

Plus, doing it the way I suggested gives the OS the most control.  The
BIOS isn't in the critical path to do the right thing.
