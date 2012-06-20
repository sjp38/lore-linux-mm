Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 11AC96B0072
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 22:56:12 -0400 (EDT)
Received: from /spool/local
	by e28smtp01.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Wed, 20 Jun 2012 08:26:08 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5K2tglv42074180
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 08:25:43 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5K8OxpK004643
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 18:24:59 +1000
Message-ID: <4FE13BAD.4030406@linux.vnet.ibm.com>
Date: Wed, 20 Jun 2012 10:55:41 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 03/10] zcache: fix a compile warning
References: <4FE0392E.3090300@linux.vnet.ibm.com> <4FE03961.5050001@linux.vnet.ibm.com> <4FE08D1A.5060400@linux.vnet.ibm.com>
In-Reply-To: <4FE08D1A.5060400@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On 06/19/2012 10:30 PM, Seth Jennings wrote:

> On 06/19/2012 03:33 AM, Xiao Guangrong wrote:
> 
>> fix:
>>
>> drivers/staging/zcache/zcache-main.c: In function a??zcache_comp_opa??:
>> drivers/staging/zcache/zcache-main.c:112:2: warning: a??reta?? may be used uninitial
>>
>> Signed-off-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
>> ---
>>  drivers/staging/zcache/zcache-main.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/drivers/staging/zcache/zcache-main.c b/drivers/staging/zcache/zcache-main.c
>> index 32fe0ba..74a3ac8 100644
>> --- a/drivers/staging/zcache/zcache-main.c
>> +++ b/drivers/staging/zcache/zcache-main.c
>> @@ -93,7 +93,7 @@ static inline int zcache_comp_op(enum comp_op op,
>>  				u8 *dst, unsigned int *dlen)
>>  {
>>  	struct crypto_comp *tfm;
>> -	int ret;
>> +	int ret = -1;
>>
>>  	BUG_ON(!zcache_comp_pcpu_tfms);
>>  	tfm = *per_cpu_ptr(zcache_comp_pcpu_tfms, get_cpu());
> 
> 
> What about adding a default case in the switch like this?
> 
> default:
> 	ret = -EINVAL;
> 
> That way we don't assign ret twice.


Okay, will do it in the next version. Thanks for your review, Seth!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
