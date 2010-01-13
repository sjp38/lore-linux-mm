Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1BA7F6B0071
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 10:43:04 -0500 (EST)
Message-ID: <4B4DE9D6.7070500@suse.com>
Date: Wed, 13 Jan 2010 10:42:14 -0500
From: Jeff Mahoney <jeffm@suse.com>
MIME-Version: 1.0
Subject: Re: [patch 2/6] hugetlb: Fix section mismatches
References: <20100113004855.550486769@suse.com>	 <20100113004938.715904356@suse.com> <1263397212.11942.97.camel@useless.americas.hpqcorp.net>
In-Reply-To: <1263397212.11942.97.camel@useless.americas.hpqcorp.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 01/13/2010 10:40 AM, Lee Schermerhorn wrote:
> On Tue, 2010-01-12 at 19:48 -0500, Jeff Mahoney wrote:
>> plain text document attachment (patches.rpmify)
>> hugetlb_register_node calls hugetlb_sysfs_add_hstate, which is marked with
>>  __init. Since hugetlb_register_node is only called by
>>  hugetlb_register_all_nodes, which in turn is only called by hugetlb_init,
>>  it's safe to mark both of them as __init.
> 
> Actually, hugetlb_register_node() also called, via a function pointer
> that hugetlb registers with the sysfs node driver, when a node is hot
> plugged.  So, I think the correct approach is to remove the '__init'
> from hugetlb_sysfs_add_hstate() as this is also used at runtime.  I
> missed this in the original submittal.

Yep. You're right. Sorry for the noise.

- -Jeff

> Regards,
> Lee Schermerhorn
> 
>>
>> Signed-off-by: Jeff Mahoney <jeffm@suse.com>
>> ---
>>  mm/hugetlb.c |    4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> --- a/mm/hugetlb.c
>> +++ b/mm/hugetlb.c
>> @@ -1630,7 +1630,7 @@ void hugetlb_unregister_node(struct node
>>   * hugetlb module exit:  unregister hstate attributes from node sysdevs
>>   * that have them.
>>   */
>> -static void hugetlb_unregister_all_nodes(void)
>> +static void __init hugetlb_unregister_all_nodes(void)
>>  {
>>  	int nid;
>>  
>> @@ -1650,7 +1650,7 @@ static void hugetlb_unregister_all_nodes
>>   * Register hstate attributes for a single node sysdev.
>>   * No-op if attributes already registered.
>>   */
>> -void hugetlb_register_node(struct node *node)
>> +void __init hugetlb_register_node(struct node *node)
>>  {
>>  	struct hstate *h;
>>  	struct node_hstate *nhs = &node_hstates[node->sysdev.id];
>>
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 


- -- 
Jeff Mahoney
SUSE Labs
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.12 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org/

iEYEARECAAYFAktN6dYACgkQLPWxlyuTD7JzEgCfXZKyPnW9VKO7OTatSm5k5WSI
l6sAoIVB0cTvz1AwN2mG7ANGPt6VVuTi
=TYGp
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
