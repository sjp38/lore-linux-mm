Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id BDE2C6B0032
	for <linux-mm@kvack.org>; Mon,  1 Jul 2013 19:44:07 -0400 (EDT)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 2 Jul 2013 05:07:50 +0530
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id E7807E0053
	for <linux-mm@kvack.org>; Tue,  2 Jul 2013 05:13:36 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r61NiJKq26869876
	for <linux-mm@kvack.org>; Tue, 2 Jul 2013 05:14:22 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r61NhsZD019131
	for <linux-mm@kvack.org>; Mon, 1 Jul 2013 23:43:55 GMT
Date: Tue, 2 Jul 2013 07:43:54 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/3] mm/slab: Fix /proc/slabinfo unwriteable for slab
Message-ID: <20130701234354.GA14358@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1372069394-26167-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1372069394-26167-3-git-send-email-liwanp@linux.vnet.ibm.com>
 <0000013f9aed0ce5-ff542635-3074-4f9b-842e-d04492ed3e90-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0000013f9aed0ce5-ff542635-3074-4f9b-842e-d04492ed3e90-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 01, 2013 at 03:49:54PM +0000, Christoph Lameter wrote:
>On Mon, 24 Jun 2013, Wanpeng Li wrote:
>
>>  1 file changed, 10 insertions(+)
>>
>> diff --git a/mm/slab_common.c b/mm/slab_common.c
>> index d161b81..7fdde79 100644
>> --- a/mm/slab_common.c
>> +++ b/mm/slab_common.c
>> @@ -631,10 +631,20 @@ static const struct file_operations proc_slabinfo_operations = {
>>  	.release	= seq_release,
>>  };
>>
>> +#ifdef CONFIG_SLAB
>> +static int __init slab_proc_init(void)
>> +{
>> +	proc_create("slabinfo", S_IWUSR | S_IRUSR, NULL, &proc_slabinfo_operations);
>> +	return 0;
>> +}
>> +#endif
>> +#ifdef CONFIG_SLUB
>>  static int __init slab_proc_init(void)
>>  {
>>  	proc_create("slabinfo", S_IRUSR, NULL, &proc_slabinfo_operations);
>>  	return 0;
>>  }
>
>It may be easier to define a macro SLABINFO_RIGHTS and use #ifdefs to
>assign the correct one. That way we have only one slab_proc_init().
>

Greate point! I	will do it in next version. ;-)

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
