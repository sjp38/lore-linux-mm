Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id D82A4440846
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 12:08:48 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id a110so1596502wrc.1
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 09:08:48 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id n93si3748855wrb.412.2017.08.24.09.08.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Aug 2017 09:08:47 -0700 (PDT)
Date: Thu, 24 Aug 2017 18:08:46 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v6 0/5] MAP_DIRECT and block-map-atomic files
Message-ID: <20170824160846.GA27591@lst.de>
References: <150353211413.5039.5228914877418362329.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <150353211413.5039.5228914877418362329.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Jan Kara <jack@suse.cz>, Arnd Bergmann <arnd@arndb.de>, "Darrick J. Wong" <darrick.wong@oracle.com>, David Airlie <airlied@linux.ie>, linux-api@vger.kernel.org, linux-nvdimm@lists.01.org, Dave Chinner <david@fromorbit.com>, Takashi Iwai <tiwai@suse.com>, dri-devel@lists.freedesktop.org, linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org, Julia Lawall <julia.lawall@lip6.fr>, Jeff Moyer <jmoyer@redhat.com>, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, luto@kernel.org, linux-fsdevel@vger.kernel.org, Daniel Vetter <daniel.vetter@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>

This seems to be missing patches 1 and 3.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
