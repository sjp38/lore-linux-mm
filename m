Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id XAA02080
	for <linux-mm@kvack.org>; Mon, 14 Oct 2002 23:05:44 -0700 (PDT)
Message-ID: <3DABB036.801DA1DA@digeo.com>
Date: Mon, 14 Oct 2002 23:05:42 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Compile without xattrs
References: <3DABA351.7E9C1CFB@digeo.com> <20021015005733.3bbde222.arashi@arashi.yi.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Reppert <arashi@arashi.yi.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, ext2-devel@lists.sourceforge.net, tytso@mit.edu
List-ID: <linux-mm.kvack.org>

Matt Reppert wrote:
> 
> On Mon, 14 Oct 2002 22:10:41 -0700
> Andrew Morton <akpm@digeo.com> wrote:
> 
> > - merge up the ext2/3 extended attribute code, convert that to use
> >   the slab shrinking API in Linus's current tree.
> 
> Trivial patch for the "too chicken to enable xattrs for now" case, but I
> need this to compile:
> 

Thanks.  I uploaded a copy to
http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.42/2.5.42-mm3/no-xattrs.patch
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
