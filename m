Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 80B7E6B04CC
	for <linux-mm@kvack.org>; Sun, 20 Nov 2016 23:57:27 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id n13so31139459ioe.7
        for <linux-mm@kvack.org>; Sun, 20 Nov 2016 20:57:27 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w74si12356449iow.104.2016.11.20.20.57.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Nov 2016 20:57:27 -0800 (PST)
Date: Sun, 20 Nov 2016 23:57:23 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM v13 04/18] mm/ZONE_DEVICE/free-page: callback when page is
 freed
Message-ID: <20161121045722.GB7872@redhat.com>
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
 <1479493107-982-5-git-send-email-jglisse@redhat.com>
 <7ec714d6-6779-5abf-0607-862acddfbd4a@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <7ec714d6-6779-5abf-0607-862acddfbd4a@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Mon, Nov 21, 2016 at 12:49:55PM +1100, Balbir Singh wrote:
> On 19/11/16 05:18, Jerome Glisse wrote:
> > When a ZONE_DEVICE page refcount reach 1 it means it is free and nobody
> > is holding a reference on it (only device to which the memory belong do).
> > Add a callback and call it when that happen so device driver can implement
> > their own free page management.
> > 
> 
> Could you give an example of what their own free page management might look like?

Well hard to do that, the free management is whatever the device driver want to do.
So i don't have any example to give. Each device driver (especialy GPU ones) have
their own memory management with little commonality.

So how the device driver manage that memory is really not important, at least it is
not something for which i want to impose a policy onto driver. I want to leave each
device driver decide on how to achieve that.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
