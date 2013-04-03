From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 7/8] staging: zcache: introduce zero-filled page stat
 count
Date: Wed, 3 Apr 2013 08:05:35 +0800
Message-ID: <49498.7222170041$1364947577@news.gmane.org>
References: <1364870780-16296-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1364870780-16296-8-git-send-email-liwanp@linux.vnet.ibm.com>
 <CAPbh3rvheDqL6U4P6L++We-Ra=Cw_fNrdPGfhV3tzVA_eW5CxQ@mail.gmail.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UNBDR-0003nx-OZ
	for glkm-linux-mm-2@m.gmane.org; Wed, 03 Apr 2013 02:06:14 +0200
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id F32526B0068
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 20:05:46 -0400 (EDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 3 Apr 2013 05:30:56 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 1935B1258055
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 05:36:57 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3305XBD43516030
	for <linux-mm@kvack.org>; Wed, 3 Apr 2013 05:35:34 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3305aRL009791
	for <linux-mm@kvack.org>; Wed, 3 Apr 2013 00:05:36 GMT
Content-Disposition: inline
In-Reply-To: <CAPbh3rvheDqL6U4P6L++We-Ra=Cw_fNrdPGfhV3tzVA_eW5CxQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad@darnok.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Fengguang Wu <fengguang.wu@intel.com>

On Tue, Apr 02, 2013 at 11:18:39AM -0400, Konrad Rzeszutek Wilk wrote:
>> --- a/drivers/staging/zcache/zcache-main.c
>> +++ b/drivers/staging/zcache/zcache-main.c
>> @@ -176,6 +176,8 @@ ssize_t zcache_pers_ate_eph;
>>  ssize_t zcache_pers_ate_eph_failed;
>>  ssize_t zcache_evicted_eph_zpages;
>>  ssize_t zcache_evicted_eph_pageframes;
>> +ssize_t zcache_zero_filled_pages;
>> +ssize_t zcache_zero_filled_pages_max;
>
>Is it possible to shove these in the debug.c file? And in debug.h just
>have an extern?

Looks good to me. ;-)

Regards,
Wanpeng Li 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
