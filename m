Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f181.google.com (mail-yk0-f181.google.com [209.85.160.181])
	by kanga.kvack.org (Postfix) with ESMTP id 009266B0038
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 17:15:34 -0500 (EST)
Received: by ykdv3 with SMTP id v3so202221887ykd.0
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 14:15:33 -0800 (PST)
Received: from mail-yk0-x22d.google.com (mail-yk0-x22d.google.com. [2607:f8b0:4002:c07::22d])
        by mx.google.com with ESMTPS id v63si30126199ywf.128.2015.11.30.14.15.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Nov 2015 14:15:33 -0800 (PST)
Received: by ykfs79 with SMTP id s79so203804922ykf.1
        for <linux-mm@kvack.org>; Mon, 30 Nov 2015 14:15:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <562AA15E.3010403@deltatee.com>
References: <20151010005522.17221.87557.stgit@dwillia2-desk3.jf.intel.com>
	<562AA15E.3010403@deltatee.com>
Date: Mon, 30 Nov 2015 14:15:33 -0800
Message-ID: <CAPcyv4gQ-8-tL-rhAPzPxKzBLmWKnFcqSFVy4KVOM56_9gn6RA@mail.gmail.com>
Subject: Re: [PATCH v2 00/20] get_user_pages() for dax mappings
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>

On Fri, Oct 23, 2015 at 2:06 PM, Logan Gunthorpe <logang@deltatee.com> wrote:
> Hi Dan,
>
> We've tested this patch series (as pulled from your git repo) with our P2P
> work and everything is working great. The issues we found in v1 have been
> fixed and we have not found any new ones.
>
> Tested-By: Logan Gunthorpe <logang@deltatee.com>
>
>

Hi Logan,

I appreciate the test report.  I appreciate it so much I wonder if
you'd be willing to re-test the current state of:

git://git.kernel.org/pub/scm/linux/kernel/git/djbw/nvdimm libnvdimm-pending

...with the revised approach that I'm proposing for-4.5 inclusion.

The main changes are fixes for supporting huge-page mappings.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
