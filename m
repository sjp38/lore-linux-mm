Subject: Compiler Error with ENOTSUP
Message-ID: <OF66118521.9D9B2989-ON85256C53.0062571F@pok.ibm.com>
From: "Peter Wong" <wpeter@us.ibm.com>
Date: Tue, 15 Oct 2002 13:01:11 -0500
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@zip.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I encountered a compiler error when I was building 2.5.42 with
Andrew's mm3 patch.

In include/linux/ext2_xattr.h and include/linux/ext3_xattr.h,
ENOTSUP is returned in many places. It should be ENOTSUPP as
      ^                                                ^^
defined in include/linux/errno.h.

Regards,
Peter

Peter Wai Yee Wong
IBM LTC Performance Team
email: wpeter@us.ibm.com


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
