Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5CE9A6B0038
	for <linux-mm@kvack.org>; Mon, 15 Aug 2016 16:21:49 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id e70so179590665ioi.3
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 13:21:49 -0700 (PDT)
Received: from mail-oi0-x235.google.com (mail-oi0-x235.google.com. [2607:f8b0:4003:c06::235])
        by mx.google.com with ESMTPS id k8si1192030oif.292.2016.08.15.13.21.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Aug 2016 13:21:48 -0700 (PDT)
Received: by mail-oi0-x235.google.com with SMTP id 4so73820084oih.2
        for <linux-mm@kvack.org>; Mon, 15 Aug 2016 13:21:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160815190918.20672-1-ross.zwisler@linux.intel.com>
References: <20160815190918.20672-1-ross.zwisler@linux.intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 15 Aug 2016 13:21:47 -0700
Message-ID: <CAPcyv4j_eh8Rcozb40JeiPwvbPoMY2sCt+yTewZ-MZzUkBbj-Q@mail.gmail.com>
Subject: Re: [PATCH 0/7] re-enable DAX PMD support
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.com>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

On Mon, Aug 15, 2016 at 12:09 PM, Ross Zwisler
<ross.zwisler@linux.intel.com> wrote:
> DAX PMDs have been disabled since Jan Kara introduced DAX radix tree based
> locking.  This series allows DAX PMDs to participate in the DAX radix tree
> based locking scheme so that they can be re-enabled.

Looks good to me.

> This series restores DAX PMD functionality back to what it was before it
> was disabled.  There is still a known issue between DAX PMDs and hole
> punch, which I am currently working on and which I plan to address with a
> separate series.

Perhaps we should hold off on applying patch 6 and 7 until after the
hole-punch fix is ready?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
