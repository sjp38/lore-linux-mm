Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id D6D126B0032
	for <linux-mm@kvack.org>; Fri, 31 May 2013 11:14:58 -0400 (EDT)
Date: Fri, 31 May 2013 11:14:54 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH v4 20/20] ext4: Allow punch hole with bigalloc enabled
Message-ID: <20130531151454.GB19561@thunk.org>
References: <1368549454-8930-1-git-send-email-lczerner@redhat.com>
 <1368549454-8930-21-git-send-email-lczerner@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1368549454-8930-21-git-send-email-lczerner@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lukas Czerner <lczerner@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, akpm@linux-foundation.org, hughd@google.com

On Tue, May 14, 2013 at 06:37:34PM +0200, Lukas Czerner wrote:
> In commits 5f95d21fb6f2aaa52830e5b7fb405f6c71d3ab85 and
> 30bc2ec9598a1b156ad75217f2e7d4560efdeeab we've reworked punch_hole
> implementation and there is noting holding us back from using punch hole
> on file system with bigalloc feature enabled.
> 
> This has been tested with fsx and xfstests.
> 
> Signed-off-by: Lukas Czerner <lczerner@redhat.com>
> Reviewed-by: Jan Kara <jack@suse.cz>

This patch is causing a test failure with bigalloc enabled with the
xfstests shared/298.

Since it's at the end of the invalidate page range tests, I'm going to
drop this patch for now.  Could you take a look at this?

Thanks!!

					- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
