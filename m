From: "Krishnakumar. R" <krishnakumar@naturesoft.net>
Reply-To: krishnakumar@naturesoft.net
Subject: Re: 2.6.3-rc3-mm1
Date: Mon, 16 Feb 2004 17:09:58 +0530
References: <20040216015823.2dafabb4.akpm@osdl.org>
In-Reply-To: <20040216015823.2dafabb4.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200402161709.58555.krishnakumar@naturesoft.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

The patch given below removes the following errors
while compiling:

-------------------------------------------------------------------------------
fs/ext3/super.c: In function `ext3_quota_on':
fs/ext3/super.c:2229: warning: ISO C90 forbids mixed declarations and code
fs/ext3/super.c:2234: error: initializer element is not constant
fs/ext3/super.c:2234: error: (near initialization for `ext3_fs_type.get_sb')
fs/ext3/super.c:2268: error: initializer element is not constant
fs/ext3/super.c:2268: warning: ISO C90 forbids mixed declarations and code
fs/ext3/super.c:2269: error: initializer element is not constant
fs/ext3/super.c:2269: error: syntax error at end of input
make[2]: *** [fs/ext3/super.o] Error 1
make[1]: *** [fs/ext3] Error 2
make: *** [fs] Error 2
--------------------------------------------------------------------------------

The patch is just compilation tested. 
Hence not sure whether its the right fix.
I derived at the patch by looking at the indentation
of the code.

Regards,
KK.

Diffstat output:
super.c |    2 +-
1 files changed, 1 insertion(+), 1 deletion(-)

The patch:

--- linux-2.6.3-rc3-mm1/fs/ext3/super.orig.c    2004-02-16 16:41:52.089749760 
+0530
+++ linux-2.6.3-rc3-mm1/fs/ext3/super.c 2004-02-16 16:53:12.432321968 +0530
@@ -2209,7 +2209,7 @@
                return err;
        if (nd.mnt->mnt_sb != sb)       /* Quotafile not on the same fs? */
                return -EXDEV;
-       if (nd.dentry->d_parent->d_inode != sb->s_root->d_inode) {
+       if (nd.dentry->d_parent->d_inode != sb->s_root->d_inode)
                /* Quotafile not of fs root? */
                printk(KERN_WARNING "EXT3-fs: Quota file not on filesystem "
                                "root. Journalled quota will not work\n");


-- 
HomePage: http://puggy.symonds.net/~krishnakumar


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
