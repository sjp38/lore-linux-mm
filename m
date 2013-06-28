Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 8EEF16B0032
	for <linux-mm@kvack.org>; Thu, 27 Jun 2013 20:32:48 -0400 (EDT)
Date: Thu, 27 Jun 2013 17:32:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mmotm 2013-06-27-16-36 uploaded
Message-Id: <20130627173225.3915d976.akpm@linux-foundation.org>
In-Reply-To: <20130628095712.120bec7036284584fd467ee2@canb.auug.org.au>
References: <20130627233733.BAEB131C3BE@corp2gmr1-1.hot.corp.google.com>
	<20130628095712.120bec7036284584fd467ee2@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

On Fri, 28 Jun 2013 09:57:12 +1000 Stephen Rothwell <sfr@canb.auug.org.au> wrote:

> Hi Andrew,
> 
> On Thu, 27 Jun 2013 16:37:33 -0700 akpm@linux-foundation.org wrote:
> >
> > The mm-of-the-moment snapshot 2013-06-27-16-36 has been uploaded to
> > 
> >    http://www.ozlabs.org/~akpm/mmotm/
> > 
> >   include-linux-smph-on_each_cpu-switch-back-to-a-macro.patch
> >   arch-c6x-mm-include-asm-uaccessh-to-pass-compiling.patch
> >   drivers-dma-pl330c-fix-locking-in-pl330_free_chan_resources.patch
> 
> Did you mean to drop these three patches from linux-next?

Nope, they should be inside the NEXT_PATCHES_START/NEXT_PATCHES_END
section, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
