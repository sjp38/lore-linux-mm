Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id E94696B0255
	for <linux-mm@kvack.org>; Mon, 26 Oct 2015 12:55:00 -0400 (EDT)
Received: by iofz202 with SMTP id z202so192348480iof.2
        for <linux-mm@kvack.org>; Mon, 26 Oct 2015 09:55:00 -0700 (PDT)
Received: from g1t6220.austin.hp.com (g1t6220.austin.hp.com. [15.73.96.84])
        by mx.google.com with ESMTPS id k62si25656332ioi.170.2015.10.26.09.55.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Oct 2015 09:55:00 -0700 (PDT)
Message-ID: <1445878268.20657.91.camel@hpe.com>
Subject: Re: [PATCH v2 UPDATE 3/3] ACPI/APEI/EINJ: Allow memory error
 injection to NVDIMM
From: Toshi Kani <toshi.kani@hpe.com>
Date: Mon, 26 Oct 2015 10:51:08 -0600
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F32B5F6D2@ORSMSX114.amr.corp.intel.com>
References: <1445871783-18365-1-git-send-email-toshi.kani@hpe.com>
	 <3908561D78D1C84285E8C5FCA982C28F32B5F5AF@ORSMSX114.amr.corp.intel.com>
	 <1445877115.20657.88.camel@hpe.com>
	 <3908561D78D1C84285E8C5FCA982C28F32B5F6D2@ORSMSX114.amr.corp.intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>, "bp@alien8.de" <bp@alien8.de>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Williams, Dan J" <dan.j.williams@intel.com>, "rjw@rjwysocki.net" <rjw@rjwysocki.net>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, 2015-10-26 at 16:46 +0000, Luck, Tony wrote:
> > +           ((param2 & PAGE_MASK) != PAGE_MASK))
> >                return -EINVAL;
> > 
> > The 3rd condition check makes sure that the param2 mask is the page size or less.  So, 
> > I think we are OK on this.
> 
> Oops. The original was even on the screen as part of the diff (which I signed off on
> just two years ago).
> 
> I'd be happier if you made it the 1st condition though, so we skip calling 
> region_intersects_*() with a nonsense "size" argument.

Agreed.  I will send an updated patch 3/3 later today, "[PATCH v2 UPDATE-2 3/3]".

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
