Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4512D6B000C
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 04:40:52 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id k44so1606189wrc.3
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 01:40:52 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id k130si554599wmg.169.2018.03.14.01.40.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Mar 2018 01:40:50 -0700 (PDT)
Date: Wed, 14 Mar 2018 09:40:50 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] x86, memremap: fix altmap accounting at free
Message-ID: <20180314084049.GA28480@lst.de>
References: <152100312423.27180.6073263768072550564.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <152100312423.27180.6073263768072550564.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, Jane Chu <jane.chu@oracle.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Looks good, thanks for catchign this!

Reviewed-by: Christoph Hellwig <hch@lst.de>
