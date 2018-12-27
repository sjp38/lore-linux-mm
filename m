Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id C65FA8E0001
	for <linux-mm@kvack.org>; Thu, 27 Dec 2018 15:07:27 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id 41so25242154qto.17
        for <linux-mm@kvack.org>; Thu, 27 Dec 2018 12:07:27 -0800 (PST)
Received: from a9-99.smtp-out.amazonses.com (a9-99.smtp-out.amazonses.com. [54.240.9.99])
        by mx.google.com with ESMTPS id a24si1236089qth.308.2018.12.27.12.07.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 27 Dec 2018 12:07:27 -0800 (PST)
Date: Thu, 27 Dec 2018 20:07:26 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH v2 08/21] mm: introduce and export pgdat peer_node
In-Reply-To: <20181226133351.521151384@intel.com>
Message-ID: <01000167f14761d6-b1564081-0d5f-4752-86be-2e99c8375866-000000@email.amazonses.com>
References: <20181226131446.330864849@intel.com> <20181226133351.521151384@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Fan Du <fan.du@intel.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Yao Yuan <yuan.yao@intel.com>, Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

On Wed, 26 Dec 2018, Fengguang Wu wrote:

> Each CPU socket can have 1 DRAM and 1 PMEM node, we call them "peer nodes".
> Migration between DRAM and PMEM will by default happen between peer nodes.

Which one does numa_node_id() point to? I guess that is the DRAM node and
then we fall back to the PMEM node?
