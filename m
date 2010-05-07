Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A61026200B2
	for <linux-mm@kvack.org>; Fri,  7 May 2010 05:55:41 -0400 (EDT)
Date: Fri, 7 May 2010 10:55:37 +0100
From: Jamie Lokier <jamie@shareable.org>
Subject: Re: [PATCH 3/3] Btrfs: add basic DIO read support
Message-ID: <20100507095537.GD19699@shareable.org>
References: <20100506190101.GD13974@dhcp231-156.rdu.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100506190101.GD13974@dhcp231-156.rdu.redhat.com>
Sender: owner-linux-mm@kvack.org
To: Josef Bacik <josef@redhat.com>
Cc: linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Josef Bacik wrote:
> 3) Lock the entire range during DIO.  I originally had it so we would lock the
> extents as get_block was called, and then unlock them as the endio function was
> called, which worked great, but if we ever had an error in the submit_io hook,
> we could have locked an extent that would never be submitted for IO, so we
> wouldn't be able to unlock it, so this solution fixed that problem and made it a
> bit cleaner.

Does this prevent concurrent DIOs to overlapping or nearby ranges?

Thanks,
-- Jamie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
