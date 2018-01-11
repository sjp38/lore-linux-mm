Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id E43FA6B026E
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 11:27:56 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id k74so1479257oih.4
        for <linux-mm@kvack.org>; Thu, 11 Jan 2018 08:27:56 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 64si5735092otj.5.2018.01.11.08.27.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jan 2018 08:27:55 -0800 (PST)
Date: Thu, 11 Jan 2018 11:27:45 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: revamp vmem_altmap / dev_pagemap handling V3
Message-ID: <20180111162744.GA3279@redhat.com>
References: <20171229075406.1936-1-hch@lst.de>
 <20180108112646.GA7204@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180108112646.GA7204@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@lists.01.org, x86@kernel.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

On Mon, Jan 08, 2018 at 12:26:46PM +0100, Christoph Hellwig wrote:
> Any chance to get this fully reviewed and picked up before the
> end of the merge window?

Sorry for taking so long to get to that, i looked at all the patches
and did not see anything obviously wrong and i like the cleanup so

Reviewed-by: Jerome Glisse <jglisse@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
