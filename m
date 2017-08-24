Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id DC08C440846
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 12:25:08 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id p125so1418242oic.11
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 09:25:08 -0700 (PDT)
Received: from mail-oi0-x234.google.com (mail-oi0-x234.google.com. [2607:f8b0:4003:c06::234])
        by mx.google.com with ESMTPS id g137si3978405oib.285.2017.08.24.09.25.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Aug 2017 09:25:07 -0700 (PDT)
Received: by mail-oi0-x234.google.com with SMTP id x124so10005502oia.2
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 09:25:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170824160846.GA27591@lst.de>
References: <150353211413.5039.5228914877418362329.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20170824160846.GA27591@lst.de>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 24 Aug 2017 09:25:07 -0700
Message-ID: <CAPcyv4iFLZCi=xMCQH+HOjnqZEPLOVUuPkcVCTS6V=8QGpP8ag@mail.gmail.com>
Subject: Re: [PATCH v6 0/5] MAP_DIRECT and block-map-atomic files
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Arnd Bergmann <arnd@arndb.de>, "Darrick J. Wong" <darrick.wong@oracle.com>, David Airlie <airlied@linux.ie>, Linux API <linux-api@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Dave Chinner <david@fromorbit.com>, Takashi Iwai <tiwai@suse.com>, Maling list - DRI developers <dri-devel@lists.freedesktop.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-xfs@vger.kernel.org, Julia Lawall <julia.lawall@lip6.fr>, Jeff Moyer <jmoyer@redhat.com>, Linux MM <linux-mm@kvack.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Daniel Vetter <daniel.vetter@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Thu, Aug 24, 2017 at 9:08 AM, Christoph Hellwig <hch@lst.de> wrote:
> This seems to be missing patches 1 and 3.

Sorry, I didn't cc you directly on those. They're on the list:

https://patchwork.kernel.org/patch/9918657/
https://patchwork.kernel.org/patch/9918663/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
