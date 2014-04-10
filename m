Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 2E83C6B0038
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 10:24:21 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id p10so3922030pdj.31
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 07:24:15 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id ua2si2304284pab.241.2014.04.10.07.24.14
        for <linux-mm@kvack.org>;
        Thu, 10 Apr 2014 07:24:15 -0700 (PDT)
Date: Thu, 10 Apr 2014 10:22:54 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v7 12/22] ext2: Remove ext2_xip_verify_sb()
Message-ID: <20140410142254.GI5727@linux.intel.com>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
 <5f91cb658e1ee1b593be9fd719e8f204b0069031.1395591795.git.matthew.r.wilcox@intel.com>
 <20140409095254.GE32103@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140409095254.GE32103@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Apr 09, 2014 at 11:52:54AM +0200, Jan Kara wrote:
> > -	if ((sbi->s_mount_opt ^ old_mount_opt) & EXT2_MOUNT_XIP) {
> > +	if ((sbi->s_mount_opt ^ old_opts.s_mount_opt) & EXT2_MOUNT_XIP) {
> >  		ext2_msg(sb, KERN_WARNING, "warning: refusing change of "
> >  			 "xip flag with busy inodes while remounting");
> > -		sbi->s_mount_opt &= ~EXT2_MOUNT_XIP;
> > -		sbi->s_mount_opt |= old_mount_opt & EXT2_MOUNT_XIP;
> > +		sbi->s_mount_opt ^= EXT2_MOUNT_XIP;
>   Although this is correct, it was easier to see that the previous code is
> correct so I'd prefer if you kept it that way.

Depends how you think about it.  I think of foo ^= bar as 'toggle the
bar bit in foo'.  So I read the code as 'If the mount bit is incorrect,
print an error and toggle the bit'.  I think you're reading the old code
as 'If the new mount bit differs from the old mount bit, make sure the
new mount bit is the same as the old mount bit'.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
