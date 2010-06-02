Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 867A36B01AC
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 09:00:56 -0400 (EDT)
Date: Wed, 2 Jun 2010 14:00:14 +0100
From: Jamie Lokier <jamie@shareable.org>
Subject: Re: [PATCH V2 0/7] Cleancache (was Transcendent Memory): overview
Message-ID: <20100602130014.GB7238@shareable.org>
References: <20100528173510.GA12166@ca-server1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100528173510.GA12166@ca-server1.us.oracle.com>
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: chris.mason@oracle.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger@sun.com, tytso@mit.edu, mfasheh@suse.com, joel.becker@oracle.com, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@suse.de, dave.mccracken@oracle.com, riel@redhat.com, avi@redhat.com, konrad.wilk@oracle.com
List-ID: <linux-mm.kvack.org>

Dan Magenheimer wrote:
> Most important, cleancache is "ephemeral".  Pages which are copied into
> cleancache have an indefinite lifetime which is completely unknowable
> by the kernel and so may or may not still be in cleancache at any later time.
> Thus, as its name implies, cleancache is not suitable for dirty pages.  The
> pseudo-RAM has complete discretion over what pages to preserve and what
> pages to discard and when.

Fwiw, the feature sounds useful to userspace too, for those things
with memory hungry caches like web browsers.  Any plans to make it
available to userspace?

Thanks,
-- Jamie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
