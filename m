Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1A8646B01B2
	for <linux-mm@kvack.org>; Tue, 22 Jun 2010 02:40:33 -0400 (EDT)
Date: Tue, 22 Jun 2010 02:40:19 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH V3 0/8] Cleancache: overview
Message-ID: <20100622064019.GA22099@infradead.org>
References: <20100621231809.GA11111@ca-server1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100621231809.GA11111@ca-server1.us.oracle.com>
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: chris.mason@oracle.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger@sun.com, tytso@mit.edu, mfasheh@suse.com, joel.becker@oracle.com, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@suse.de, dave.mccracken@oracle.com, riel@redhat.com, avi@redhat.com, konrad.wilk@oracle.com
List-ID: <linux-mm.kvack.org>

What all this fails to explain is that this actually is useful for?

Your series adds lots of crappy code, entiely stupid interactions with a
handfull filesystems, but no actual users.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
