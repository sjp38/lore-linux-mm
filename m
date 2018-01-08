Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id A6D3F6B0296
	for <linux-mm@kvack.org>; Mon,  8 Jan 2018 06:26:48 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id g13so6892503wrh.19
        for <linux-mm@kvack.org>; Mon, 08 Jan 2018 03:26:48 -0800 (PST)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id 11si7694512wmv.197.2018.01.08.03.26.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jan 2018 03:26:47 -0800 (PST)
Date: Mon, 8 Jan 2018 12:26:46 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: Re: revamp vmem_altmap / dev_pagemap handling V3
Message-ID: <20180108112646.GA7204@lst.de>
References: <20171229075406.1936-1-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171229075406.1936-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, x86@kernel.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, linuxppc-dev@lists.ozlabs.org

Any chance to get this fully reviewed and picked up before the
end of the merge window?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
