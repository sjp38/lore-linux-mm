Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 43CC96B0038
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 17:06:59 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id r128so912129oig.3
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 14:06:59 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id g126sor1673893oia.103.2017.11.02.14.06.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 Nov 2017 14:06:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171102201356.GD5732@lst.de>
References: <150949209290.24061.6283157778959640151.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150949214929.24061.10464887309708944817.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20171102201356.GD5732@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 2 Nov 2017 14:06:57 -0700
Message-ID: <CAPcyv4g0-kXCXzGo6=3fwaRJTM_4N8BFp+-W71t4Vd_to7LDBA@mail.gmail.com>
Subject: Re: [PATCH 10/15] IB/core: disable memory registration of
 fileystem-dax vmas
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Sean Hefty <sean.hefty@intel.com>, linux-xfs@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-rdma <linux-rdma@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Jeff Moyer <jmoyer@redhat.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>, Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, Linux MM <linux-mm@kvack.org>, Doug Ledford <dledford@redhat.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>

On Thu, Nov 2, 2017 at 1:13 PM, Christoph Hellwig <hch@lst.de> wrote:
> Any chance we could add a new get_user_pages_longerm or similar
> helper instead of opencoding this in the various callers?

Sounds like a great idea to me, I'll take a look...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
