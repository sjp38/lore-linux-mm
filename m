Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 13EBF6B0275
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 20:36:31 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id a6so10173062pff.17
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 17:36:31 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id q17si6367805pgc.303.2017.12.08.17.36.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Dec 2017 17:36:29 -0800 (PST)
Date: Fri, 8 Dec 2017 17:36:24 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2] mm: Add unmap_mapping_pages
Message-ID: <20171209013624.GA9717@bombadil.infradead.org>
References: <20171205154453.GD28760@bombadil.infradead.org>
 <201712080802.CQcwOznF%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201712080802.CQcwOznF%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, linux-mm@kvack.org, "zhangyi (F)" <yi.zhang@huawei.com>, linux-fsdevel@vger.kernel.org

On Fri, Dec 08, 2017 at 10:38:55AM +0800, kbuild test robot wrote:
> Hi Matthew,
> 
> I love your patch! Yet something to improve:

You missed v3, kbuild robot?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
