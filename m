From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH PART2 v4 6/6] staging: ramster: add how-to for ramster
Date: Mon, 15 Apr 2013 08:00:01 +0800
Message-ID: <5923.68519069186$1365984015@news.gmane.org>
References: <1365858092-21920-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1365858092-21920-7-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130413132854.GA28650@kroah.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1URWqC-0006Rg-Ey
	for glkm-linux-mm-2@m.gmane.org; Mon, 15 Apr 2013 02:00:12 +0200
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id A9A396B0002
	for <linux-mm@kvack.org>; Sun, 14 Apr 2013 20:00:09 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 15 Apr 2013 05:26:47 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id F3872125804F
	for <linux-mm@kvack.org>; Mon, 15 Apr 2013 05:31:31 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3ENxxuP6816008
	for <linux-mm@kvack.org>; Mon, 15 Apr 2013 05:29:59 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3F002m9009288
	for <linux-mm@kvack.org>; Mon, 15 Apr 2013 10:00:02 +1000
Content-Disposition: inline
In-Reply-To: <20130413132854.GA28650@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <bob.liu@oracle.com>

On Sat, Apr 13, 2013 at 06:28:54AM -0700, Greg Kroah-Hartman wrote:
>On Sat, Apr 13, 2013 at 09:01:32PM +0800, Wanpeng Li wrote:
>> Add how-to for ramster.
>> 
>> Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>
>> Singed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
>> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>> ---
>>  drivers/staging/zcache/ramster/HOWTO.txt |  257 ++++++++++++++++++++++++++++++
>>  1 file changed, 257 insertions(+)
>>  create mode 100644 drivers/staging/zcache/ramster/HOWTO.txt
>> 
>> diff --git a/drivers/staging/zcache/ramster/HOWTO.txt b/drivers/staging/zcache/ramster/HOWTO.txt
>> new file mode 100644
>> index 0000000..a4ee979
>> --- /dev/null
>> +++ b/drivers/staging/zcache/ramster/HOWTO.txt
>> @@ -0,0 +1,257 @@
>> +Version: 130309
>> + Dan Magenheimer <dan.magenheimer@oracle.com>
>
>If Dan wrote this, why are you listing yourself as the author of this
>patch?

I update something since they are out-of-date. I will add From: Dan when
I repost.

>
>> +CHANGELOG:
>> +v5-120214->120817: updated for merge into new zcache codebase
>> +v4-120126->v5-120214: updated for V5
>> +111227->v4-120126: added info on selfshrinking and rebooting
>> +111227->v4-120126: added more info for tracking RAMster stats
>> +111227->v4-120126: CONFIG_PREEMPT_NONE no longer necessary
>> +111227->v4-120126: cleancache now works completely so no need to disable it
>
>That is not needed in an in-kernel file, please remove it.

Thanks for merging the patchset, I will repost it seperately. ;-)

Regards,
Wanpeng Li 

>
>greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
