Date: Thu, 27 Jan 2005 15:52:34 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [patch] ext2: Apply Jack's ext3 speedups
Message-ID: <20050127205233.GB9225@thunk.org>
References: <200501270722.XAA10830@allur.sanmateo.akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200501270722.XAA10830@allur.sanmateo.akamai.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: pmeda@akamai.com
Cc: akpm@osdl.org, jack@suse.cz, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 26, 2005 at 11:22:39PM -0800, pmeda@akamai.com wrote:
> 
> Apply ext3 speedups added by Jan Kara to ext2.
> Reference: http://linus.bkbits.net:8080/linux-2.5/gnupatch@41f127f2jwYahmKm0eWTJNpYcSyhPw
> 

This patch isn't right, as it causes ext2_sparse_group(1) to return 0
instead of 1.  Block groups number 0 and 1 must always contain a
superblock.

>  static int ext2_group_sparse(int group)
>  {
> +	if (group <= 0)
> +		return 1;

Change this to be:

+	if (group <= 1)
+		return 1;

and it should fix the patch (as well as be similar to the ext3
mainline).  With this change,

Acked-by: "Theodore Ts'o" <tytso@mit.edu>

						- Ted
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
