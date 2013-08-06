Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 363F06B0031
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 10:24:48 -0400 (EDT)
Message-ID: <52010714.2090707@oracle.com>
Date: Tue, 06 Aug 2013 22:24:20 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/4] zcache: a compressed file page cache
References: <1375788977-12105-1-git-send-email-bob.liu@oracle.com> <20130806135800.GC1048@kroah.com>
In-Reply-To: <20130806135800.GC1048@kroah.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: Bob Liu <lliubbo@gmail.com>, linux-mm@kvack.org, ngupta@vflare.org, akpm@linux-foundation.org, konrad.wilk@oracle.com, sjenning@linux.vnet.ibm.com, riel@redhat.com, mgorman@suse.de, kyungmin.park@samsung.com, p.sarna@partner.samsung.com, barry.song@csr.com, penberg@kernel.org

Hi Greg,

On 08/06/2013 09:58 PM, Greg KH wrote:
> On Tue, Aug 06, 2013 at 07:36:13PM +0800, Bob Liu wrote:
>> Dan Magenheimer extended zcache supporting both file pages and anonymous pages.
>> It's located in drivers/staging/zcache now. But the current version of zcache is
>> too complicated to be merged into upstream.
> 
> Really?  If this is so, I'll just go delete zcache now, I don't want to
> lug around dead code that will never be merged.
> 

Zcache in staging have a zbud allocation which is almost the same as
mm/zbud.c but with different API and have a frontswap backend like
mm/zswap.c.
So I'd prefer reuse mm/zbud.c and mm/zswap.c for a generic memory
compression solution.
Which means in that case, zcache in staging = mm/zswap.c + mm/zcache.c +
mm/zbud.c.

But I'm not sure if there are any existing users of zcache in staging,
if not I can delete zcache from staging in my next version of this
mm/zcache.c series.

> greg k-h
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

-- 
Regards,
-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
