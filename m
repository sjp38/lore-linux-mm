Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 415E66B024D
	for <linux-mm@kvack.org>; Mon, 12 Jul 2010 11:06:55 -0400 (EDT)
Date: Mon, 12 Jul 2010 11:05:22 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH] Cleancache: shim to Xen Transcendent Memory
Message-ID: <20100712150522.GD5358@phenom.dumpdata.com>
References: <20100708164208.GA11763@ca-server1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100708164208.GA11763@ca-server1.us.oracle.com>
Sender: owner-linux-mm@kvack.org
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: chris.mason@oracle.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger@sun.com, tytso@mit.edu, mfasheh@suse.com, joel.becker@oracle.com, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@suse.de, dave.mccracken@oracle.com, riel@redhat.com, avi@redhat.com
List-ID: <linux-mm.kvack.org>

On Thu, Jul 08, 2010 at 09:42:08AM -0700, Dan Magenheimer wrote:
> Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>

One nitpick:
..
> +
> +int tmem_enabled;
> +
> +static int __init enable_tmem(char *s)
> +{
> +	tmem_enabled = 1;
> +	return 1;
> +}
> +
> +__setup("tmem", enable_tmem);

Perhaps 'tmem_setup' is more appropiate as it might be that this
function in the future would be only used to disable tmem, not actually
enable it?

Otherwise, it has been reviewed by me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
