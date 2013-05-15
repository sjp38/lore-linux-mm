Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 8D5D46B0002
	for <linux-mm@kvack.org>; Wed, 15 May 2013 03:30:08 -0400 (EDT)
Date: Wed, 15 May 2013 17:30:04 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v4 05/20] xfs: use ->invalidatepage() length argument
Message-ID: <20130515073004.GQ29466@dastard>
References: <1368549454-8930-1-git-send-email-lczerner@redhat.com>
 <1368549454-8930-6-git-send-email-lczerner@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1368549454-8930-6-git-send-email-lczerner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lukas Czerner <lczerner@redhat.com>
Cc: linux-mm@kvack.org, hughd@google.com, linux-kernel@vger.kernel.org, xfs@oss.sgi.com, linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org, linux-ext4@vger.kernel.org

On Tue, May 14, 2013 at 06:37:19PM +0200, Lukas Czerner wrote:
> ->invalidatepage() aop now accepts range to invalidate so we can make
> use of it in xfs_vm_invalidatepage()
> 
> Signed-off-by: Lukas Czerner <lczerner@redhat.com>
> Reviewed-by: Ben Myers <bpm@sgi.com>
> Cc: xfs@oss.sgi.com

Acked-by: Dave Chinner <dchinner@redhat.com>

-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
