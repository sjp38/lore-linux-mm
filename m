Date: Tue, 15 Oct 2002 11:00:13 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Compiler Error with ENOTSUP
Message-ID: <20021015180013.GA24068@holomorphy.com>
References: <OF66118521.9D9B2989-ON85256C53.0062571F@pok.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <OF66118521.9D9B2989-ON85256C53.0062571F@pok.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Wong <wpeter@us.ibm.com>
Cc: akpm@zip.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Oct 15, 2002 at 01:01:11PM -0500, Peter Wong wrote:
> I encountered a compiler error when I was building 2.5.42 with
> Andrew's mm3 patch.
> In include/linux/ext2_xattr.h and include/linux/ext3_xattr.h,
> ENOTSUP is returned in many places. It should be ENOTSUPP as
> defined in include/linux/errno.h.

Apply

http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.42/2.5.42-mm3/no-xattrs.patch
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
