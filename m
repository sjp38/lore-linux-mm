Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 68F0F6B0253
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 17:40:02 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id x24so6224353pgv.5
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 14:40:02 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id z29si4858998pfj.340.2017.12.07.14.40.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Dec 2017 14:40:01 -0800 (PST)
Date: Thu, 7 Dec 2017 14:39:56 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: Lockdep is less useful than it was
Message-ID: <20171207223956.GD26792@bombadil.infradead.org>
References: <20171206004159.3755-1-willy@infradead.org>
 <20171206004159.3755-73-willy@infradead.org>
 <20171206012901.GZ4094@dastard>
 <20171206020208.GK26021@bombadil.infradead.org>
 <20171206031456.GE4094@dastard>
 <20171206044549.GO26021@bombadil.infradead.org>
 <20171206084404.GF4094@dastard>
 <20171206140648.GB32044@bombadil.infradead.org>
 <20171207160634.il3vt5d6a4v5qesi@thunk.org>
 <20171207223803.GC26792@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171207223803.GC26792@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Dave Chinner <david@fromorbit.com>, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: mingo@kernel.org, byungchul.park@lge.com

On Thu, Dec 07, 2017 at 02:38:03PM -0800, Matthew Wilcox wrote:
> You need to get LOCKDEP_CROSSRELEASE off.  I'd revert patches
> e26f34a407aec9c65bce2bc0c838fabe4f051fc6 and
> b483cf3bc249d7af706390efa63d6671e80d1c09

Oops.  I meant to revert 2dcd5adfb7401b762ddbe4b86dcacc2f3de6b97b.
Or you could cherry-pick b483cf3bc249d7af706390efa63d6671e80d1c09.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
