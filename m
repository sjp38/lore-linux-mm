Content-Type: text/plain;
  charset="iso-8859-1"
From: Andreas Gruenbacher <agruen@suse.de>
Subject: Re: [Ext2-devel] [PATCH] Compile without xattrs
Date: Tue, 15 Oct 2002 12:11:19 +0200
References: <3DABA351.7E9C1CFB@digeo.com> <20021015005733.3bbde222.arashi@arashi.yi.org>
In-Reply-To: <20021015005733.3bbde222.arashi@arashi.yi.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8BIT
Message-Id: <200210151211.19353.agruen@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, ext2-devel@lists.sourceforge.net, tytso@mit.edu, Matt Reppert <arashi@arashi.yi.org>
List-ID: <linux-mm.kvack.org>

On Tuesday 15 October 2002 07:57, Matt Reppert wrote:
> On Mon, 14 Oct 2002 22:10:41 -0700
>
> Andrew Morton <akpm@digeo.com> wrote:
> > - merge up the ext2/3 extended attribute code, convert that to use
> >   the slab shrinking API in Linus's current tree.
>
> Trivial patch for the "too chicken to enable xattrs for now" case, but I
> need this to compile:

Please add this to include/linux/errno.h instead:

#define ENOTSUP EOPNOTSUPP      /* Operation not supported */

ENOTSUPP is distinct from (EOPNOTSUPP = ENOTSUP)

(Yes, it's a mess.)

--Andreas.

> --- linux-2.5-orig/include/linux/ext2_xattr.h	2002-10-15 00:47:03 -0500
> +++ linux-2.5/include/linux/ext2_xattr.h	2002-10-15 00:45:48 -0500
> @@ -92,20 +92,20 @@
>  ext2_xattr_get(struct inode *inode, int name_index,
>  	       const char *name, void *buffer, size_t size)
>  {
> -	return -ENOTSUP;
> +	return -ENOTSUPP;
>  }
>
>  static inline int
>  ext2_xattr_list(struct inode *inode, char *buffer, size_t size)
>  {
> -	return -ENOTSUP;
> +	return -ENOTSUPP;
>  }
>
>  static inline int
>  ext2_xattr_set(struct inode *inode, int name_index, const char *name,
>  	       const void *value, size_t size, int flags)
>  {
> -	return -ENOTSUP;
> +	return -ENOTSUPP;
>  }
>
>  static inline void
> --- linux-2.5-orig/include/linux/ext3_xattr.h	2002-10-15 00:49:59.000000000
> -0500 +++ linux-2.5/include/linux/ext3_xattr.h	2002-10-15
> 00:50:12.000000000 -0500 @@ -92,20 +92,20 @@
>  ext3_xattr_get(struct inode *inode, int name_index, const char *name,
>  	       void *buffer, size_t size, int flags)
>  {
> -	return -ENOTSUP;
> +	return -ENOTSUPP;
>  }
>
>  static inline int
>  ext3_xattr_list(struct inode *inode, void *buffer, size_t size, int flags)
>  {
> -	return -ENOTSUP;
> +	return -ENOTSUPP;
>  }
>
>  static inline int
>  ext3_xattr_set(handle_t *handle, struct inode *inode, int name_index,
>  	       const char *name, const void *value, size_t size, int flags)
>  {
> -	return -ENOTSUP;
> +	return -ENOTSUPP;
>  }
>
>  static inline void
>
>
> Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
