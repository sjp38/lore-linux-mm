Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 2EFF26B0037
	for <linux-mm@kvack.org>; Tue, 25 Jun 2013 03:50:19 -0400 (EDT)
Message-ID: <51C94B67.5070705@oracle.com>
Date: Tue, 25 Jun 2013 15:48:55 +0800
From: Jeff Liu <jeff.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] vfs: export lseek_execute() to modules
References: <51C91645.8050502@oracle.com> <20130625071139.GZ4165@ZenIV.linux.org.uk>
In-Reply-To: <20130625071139.GZ4165@ZenIV.linux.org.uk>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, andi@firstfloor.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Chris.mason@fusionio.com, jbacik@fusionio.com, Ben Myers <bpm@sgi.com>, tytso@mit.edu, hughd@google.com, Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>, sage@inktank.com

On 06/25/2013 03:11 PM, Al Viro wrote:

> On Tue, Jun 25, 2013 at 12:02:13PM +0800, Jeff Liu wrote:
>> From: Jie Liu <jeff.liu@oracle.com>
>>
>> For those file systems(btrfs/ext4/ocfs2/tmpfs) that support
>> SEEK_DATA/SEEK_HOLE functions, we end up handling the similar
>> matter in lseek_execute() to update the current file offset
>> to the desired offset if it is valid, ceph also does the
>> simliar things at ceph_llseek().
>>
>> To reduce the duplications, this patch make lseek_execute()
>> public accessible so that we can call it directly from the
>> underlying file systems.
> 
> Umm...  I like it, but it needs changes:
> 	* inode argument of lseek_execute() is pointless (and killed
> off in vfs.git, actually)
> 	* I'm really not happy about the name of that function.  For
> a static it's kinda-sort tolerable, but for something global, let
> alone exported...
> 
> I've put a modified variant into #for-next; could you check if you are
> still OK with it?

Yep, I'm ok with vfs_setpos().

Thanks,
-Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
