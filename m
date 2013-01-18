Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 3904D6B0005
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 20:15:26 -0500 (EST)
Date: Fri, 18 Jan 2013 09:12:59 +0800
From: Liu Bo <bo.li.liu@oracle.com>
Subject: Re: [PATCH V2] mm/slab: add a leak decoder callback
Message-ID: <20130118011258.GE6768@liubo>
Reply-To: bo.li.liu@oracle.com
References: <1358305393-3507-1-git-send-email-bo.li.liu@oracle.com>
 <50F63BEE.8040506@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50F63BEE.8040506@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Miao Xie <miaox@cn.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, zab@zabbo.net, cl@linux.com, penberg@kernel.org

On Wed, Jan 16, 2013 at 01:34:38PM +0800, Miao Xie wrote:
> On wed, 16 Jan 2013 11:03:13 +0800, Liu Bo wrote:
> > This adds a leak decoder callback so that slab destruction
> > can use to generate debugging output for the allocated objects.
> > 
> > Callers like btrfs are using their own leak tracking which will
> > manage allocated objects in a list(or something else), this does
> > indeed the same thing as what slab does.  So adding a callback
> > for leak tracking can avoid this as well as runtime overhead.
> 
> If the slab is merged with the other one, this patch can work well?

Yes and no, so I'll disable merging slab in the next version :)

thanks,
liubo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
