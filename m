Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1934B6B0292
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 07:59:01 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id g7so87521567pgp.1
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 04:59:01 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id b12si30467plk.568.2017.06.29.04.58.59
        for <linux-mm@kvack.org>;
        Thu, 29 Jun 2017 04:59:00 -0700 (PDT)
Subject: Re: [PATCH v2] mm: Drop useless local parameters of
 __register_one_node()
References: <1498013846-20149-1-git-send-email-douly.fnst@cn.fujitsu.com>
 <20170629111217.GA5032@dhcp22.suse.cz>
From: Dou Liyang <douly.fnst@cn.fujitsu.com>
Message-ID: <c831fee0-4226-f519-6ba6-092f84928af3@cn.fujitsu.com>
Date: Thu, 29 Jun 2017 19:58:52 +0800
MIME-Version: 1.0
In-Reply-To: <20170629111217.GA5032@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, David Rientjes <rientjes@google.com>, isimatu.yasuaki@jp.fujitsu.com

Hi Michal,

At 06/29/2017 07:12 PM, Michal Hocko wrote:
> On Wed 21-06-17 10:57:26, Dou Liyang wrote:
>> ... initializes local parameters "p_node" & "parent" for
>> register_node().
>>
>> But, register_node() does not use them.
>>
>> Remove the related code of "parent" node, cleanup __register_one_node()
>> and register_node().
>>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: David Rientjes <rientjes@google.com>
>> Cc: Michal Hocko <mhocko@kernel.org>
>> Cc: isimatu.yasuaki@jp.fujitsu.com
>> Signed-off-by: Dou Liyang <douly.fnst@cn.fujitsu.com>
>> Acked-by: David Rientjes <rientjes@google.com>
>
> I am sorry, this slipped through cracks.
> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks for your Acked-by, but this patch has been added to the -mm tree. 
  Its filename is
    mm-drop-useless-local-parameters-of-__register_one_node.patch

This patch should soon appear at
 
http://ozlabs.org/~akpm/mmots/broken-out/mm-drop-useless-local-parameters-of-__register_one_node.patch
and later at
 
http://ozlabs.org/~akpm/mmotm/broken-out/mm-drop-useless-local-parameters-of-__register_one_node.patch

I don't know what should I do next ? :)

Thanks,
	dou.
>
>> ---
>> V1 --> V2:
>> Rebase it on
>> git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git akpm
>>
>>  drivers/base/node.c | 9 ++-------
>>  1 file changed, 2 insertions(+), 7 deletions(-)
>>
>> diff --git a/drivers/base/node.c b/drivers/base/node.c
>> index 73d39bc..d8dc830 100644
>> --- a/drivers/base/node.c
>> +++ b/drivers/base/node.c
>> @@ -288,7 +288,7 @@ static void node_device_release(struct device *dev)
>>   *
>>   * Initialize and register the node device.
>>   */
>> -static int register_node(struct node *node, int num, struct node *parent)
>> +static int register_node(struct node *node, int num)
>>  {
>>  	int error;
>>
>> @@ -567,19 +567,14 @@ static void init_node_hugetlb_work(int nid) { }
>>
>>  int __register_one_node(int nid)
>>  {
>> -	int p_node = parent_node(nid);
>> -	struct node *parent = NULL;
>>  	int error;
>>  	int cpu;
>>
>> -	if (p_node != nid)
>> -		parent = node_devices[p_node];
>> -
>>  	node_devices[nid] = kzalloc(sizeof(struct node), GFP_KERNEL);
>>  	if (!node_devices[nid])
>>  		return -ENOMEM;
>>
>> -	error = register_node(node_devices[nid], nid, parent);
>> +	error = register_node(node_devices[nid], nid);
>>
>>  	/* link cpu under this node */
>>  	for_each_present_cpu(cpu) {
>> --
>> 2.5.5
>>
>>
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
