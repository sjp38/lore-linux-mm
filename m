Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l7FA8gOL302562
	for <linux-mm@kvack.org>; Wed, 15 Aug 2007 20:08:43 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.250.244])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l7FA6B9g159008
	for <linux-mm@kvack.org>; Wed, 15 Aug 2007 20:06:17 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7FA2csT032545
	for <linux-mm@kvack.org>; Wed, 15 Aug 2007 20:02:38 +1000
Message-ID: <46C2CF36.7020308@linux.vnet.ibm.com>
Date: Wed, 15 Aug 2007 15:32:30 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm PATCH 4/9] Memory controller memory accounting (v4)
References: <46AF2EAA.2080703@linux.vnet.ibm.com> <20070815084454.09B061BF982@siro.lan>
In-Reply-To: <20070815084454.09B061BF982@siro.lan>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: svaidy@linux.vnet.ibm.com, a.p.zijlstra@chello.nl, dhaval@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ebiederm@xmission.com, containers@lists.osdl.org, akpm@linux-foundation.org, xemul@openvz.org, menage@google.com
List-ID: <linux-mm.kvack.org>

YAMAMOTO Takashi wrote:
>> YAMAMOTO Takashi wrote:
>>>> +	lock_meta_page(page);
>>>> +	/*
>>>> +	 * Check if somebody else beat us to allocating the meta_page
>>>> +	 */
>>>> +	race_mp = page_get_meta_page(page);
>>>> +	if (race_mp) {
>>>> +		kfree(mp);
>>>> +		mp = race_mp;
>>>> +		atomic_inc(&mp->ref_cnt);
>>>> +		res_counter_uncharge(&mem->res, 1);
>>>> +		goto done;
>>>> +	}
>>> i think you need css_put here.
>> Thats correct. We do need css_put in this path.
>>
>> Thanks,
>> Vaidy
> 
> v5 still seems to have the problem.
> 
> YAMAMOTO Takashi
> 

Hi, 

I've got the fix in v6 now, thanks for spotting it.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
