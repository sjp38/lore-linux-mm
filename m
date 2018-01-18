Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id AD60D6B0033
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 09:24:45 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id d63so6151786wma.4
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 06:24:45 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p7si5492944wrh.130.2018.01.18.06.24.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 18 Jan 2018 06:24:43 -0800 (PST)
Date: Thu, 18 Jan 2018 15:22:34 +0100
From: David Sterba <dsterba@suse.cz>
Subject: Re: [PATCH v6 85/99] btrfs: Remove unused spinlock
Message-ID: <20180118142234.GK13726@twin.jikos.cz>
Reply-To: dsterba@suse.cz
References: <20180117202203.19756-1-willy@infradead.org>
 <20180117202203.19756-86-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180117202203.19756-86-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, Bjorn Andersson <bjorn.andersson@linaro.org>, Stefano Stabellini <sstabellini@kernel.org>, iommu@lists.linux-foundation.org, linux-remoteproc@vger.kernel.org, linux-s390@vger.kernel.org, intel-gfx@lists.freedesktop.org, cgroups@vger.kernel.org, linux-sh@vger.kernel.org, David Howells <dhowells@redhat.com>

On Wed, Jan 17, 2018 at 12:21:49PM -0800, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> The reada_lock in struct btrfs_device was only initialised, and not
> actually used.  That's good because there's another lock also called
> reada_lock in the btrfs_fs_info that was quite heavily used.  Remove
> this one.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>

I'll pick this one now, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
