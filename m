Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 221876B0038
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 10:50:45 -0400 (EDT)
Message-ID: <1376318968.10300.334.camel@misato.fc.hp.com>
Subject: Re: [PATCH v2] mm/hotplug: Verify hotplug memory range
From: Toshi Kani <toshi.kani@hp.com>
Date: Mon, 12 Aug 2013 08:49:28 -0600
In-Reply-To: <20130811233722.GA27223@hacker.(null)>
References: <1376162252-26074-1-git-send-email-toshi.kani@hp.com>
	 <20130811233722.GA27223@hacker.(null)>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, dave@sr71.net, isimatu.yasuaki@jp.fujitsu.com, tangchen@cn.fujitsu.com, vasilis.liaskovitis@profitbricks.com

On Mon, 2013-08-12 at 07:37 +0800, Wanpeng Li wrote:
> On Sat, Aug 10, 2013 at 01:17:32PM -0600, Toshi Kani wrote:
> >add_memory() and remove_memory() can only handle a memory range aligned
> >with section.  There are problems when an unaligned range is added and
> >then deleted as follows:
> >
> > - add_memory() with an unaligned range succeeds, but __add_pages()
> >   called from add_memory() adds a whole section of pages even though
> >   a given memory range is less than the section size.
> > - remove_memory() to the added unaligned range hits BUG_ON() in
> >   __remove_pages().
> >
> >This patch changes add_memory() and remove_memory() to check if a given
> >memory range is aligned with section at the beginning.  As the result,
> >add_memory() fails with -EINVAL when a given range is unaligned, and
> >does not add such memory range.  This prevents remove_memory() to be
> >called with an unaligned range as well.  Note that remove_memory() has
> >to use BUG_ON() since this function cannot fail.
> >
> >Signed-off-by: Toshi Kani <toshi.kani@hp.com>
> >Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> >Reviewed-by: Tang Chen <tangchen@cn.fujitsu.com>
> 
> Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

Thanks Wanpeng!
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
