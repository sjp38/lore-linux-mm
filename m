Date: Tue, 23 Dec 2003 21:08:06 +0000
From: viro@parcelfarce.linux.theplanet.co.uk
Subject: Re: 2.6.0-mm1
Message-ID: <20031223210806.GE4176@parcelfarce.linux.theplanet.co.uk>
References: <20031222211131.70a963fb.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20031222211131.70a963fb.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Dec 22, 2003 at 09:11:31PM -0800, Andrew Morton wrote:
> +inode-i_sb-checks.patch
> 
>  Add checks for null inode->i_sb in core VFS (we're still arguing about this)

They should be replaced with BUG_ON() or removed.
 
> +name_to_dev_t-fix.patch
> 
>  Don't replace slashes in names to `.'.  Replace them with `!' instead.  No
>  clue why, nobody tells me anything.

Take a look at /sys/block/ and you'll see - when we register disks, we mangle
the disk names that contain slashes (e.g. cciss/c0d0) replacing them with '!'
in corresponding sysfs names.  So name_to_dev_t() should mangle the name in
the same way before looking for it in /sys/block.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
