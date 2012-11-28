Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 3E6856B0071
	for <linux-mm@kvack.org>; Wed, 28 Nov 2012 11:17:11 -0500 (EST)
Date: Wed, 28 Nov 2012 11:17:07 -0500
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 15/19] xfs: convert dquot cache lru to list_lru
Message-ID: <20121128161707.GA19634@infradead.org>
References: <1354058086-27937-1-git-send-email-david@fromorbit.com>
 <1354058086-27937-16-git-send-email-david@fromorbit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1354058086-27937-16-git-send-email-david@fromorbit.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: glommer@parallels.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, xfs@oss.sgi.com

> +	if (!xfs_dqflock_nowait(dqp))
> +		xfs_dqunlock(dqp);
> +		goto out_miss_busy;

This seems to miss braces.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
