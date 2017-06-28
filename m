Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id D04446B0292
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 10:39:00 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id f49so33758782wrf.5
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 07:39:00 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id 141si5857421wmw.42.2017.06.28.07.38.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Jun 2017 07:38:59 -0700 (PDT)
Date: Wed, 28 Jun 2017 16:38:58 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v2 05/10] tmpfs: define integrity_read method
Message-ID: <20170628143858.GD2359@lst.de>
References: <1498069110-10009-1-git-send-email-zohar@linux.vnet.ibm.com> <1498069110-10009-6-git-send-email-zohar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1498069110-10009-6-git-send-email-zohar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mimi Zohar <zohar@linux.vnet.ibm.com>
Cc: Christoph Hellwig <hch@lst.de>, Al Viro <viro@zeniv.linux.org.uk>, James Morris <jmorris@namei.org>, linux-fsdevel@vger.kernel.org, linux-ima-devel@lists.sourceforge.net, linux-security-module@vger.kernel.org, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

On Wed, Jun 21, 2017 at 02:18:25PM -0400, Mimi Zohar wrote:
> Define an ->integrity_read file operation method to read data for
> integrity hash collection.

should be folded into patch 2.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
