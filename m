Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 47F736B0032
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 08:30:15 -0400 (EDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 12 Aug 2013 17:54:28 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 762BD394004E
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 17:59:58 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7CCVLx139452692
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 18:01:24 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r7CCU3Uk015358
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 18:00:04 +0530
Date: Mon, 12 Aug 2013 20:30:02 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 0/4] zcache: a compressed file page cache
Message-ID: <20130812123002.GA23773@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1375788977-12105-1-git-send-email-bob.liu@oracle.com>
 <20130806135800.GC1048@kroah.com>
 <52010714.2090707@oracle.com>
 <20130812121908.GA3196@phenom.dumpdata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130812121908.GA3196@phenom.dumpdata.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Bob Liu <bob.liu@oracle.com>, Greg KH <gregkh@linuxfoundation.org>, Bob Liu <lliubbo@gmail.com>, linux-mm@kvack.org, ngupta@vflare.org, akpm@linux-foundation.org, sjenning@linux.vnet.ibm.com, riel@redhat.com, mgorman@suse.de, kyungmin.park@samsung.com, p.sarna@partner.samsung.com, barry.song@csr.com, penberg@kernel.org

On Mon, Aug 12, 2013 at 08:19:08AM -0400, Konrad Rzeszutek Wilk wrote:
>On Tue, Aug 06, 2013 at 10:24:20PM +0800, Bob Liu wrote:
>> Hi Greg,
>> 
>> On 08/06/2013 09:58 PM, Greg KH wrote:
>> > On Tue, Aug 06, 2013 at 07:36:13PM +0800, Bob Liu wrote:
>> >> Dan Magenheimer extended zcache supporting both file pages and anonymous pages.
>> >> It's located in drivers/staging/zcache now. But the current version of zcache is
>> >> too complicated to be merged into upstream.
>> > 
>> > Really?  If this is so, I'll just go delete zcache now, I don't want to
>> > lug around dead code that will never be merged.
>> > 
>> 
>> Zcache in staging have a zbud allocation which is almost the same as
>> mm/zbud.c but with different API and have a frontswap backend like
>> mm/zswap.c.
>> So I'd prefer reuse mm/zbud.c and mm/zswap.c for a generic memory
>> compression solution.
>> Which means in that case, zcache in staging = mm/zswap.c + mm/zcache.c +
>> mm/zbud.c.
>> 
>> But I'm not sure if there are any existing users of zcache in staging,
>> if not I can delete zcache from staging in my next version of this
>> mm/zcache.c series.
>
>I think the Samsung folks are using it (zcache).
>

Hi Konrad,

If there are real users using ramster? And if Xen project using zcache
and ramster in staging tree? 

Regards,
Wanpeng Li 

>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
