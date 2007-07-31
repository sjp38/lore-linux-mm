Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.18.232])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l6VClGLo344172
	for <linux-mm@kvack.org>; Tue, 31 Jul 2007 22:47:19 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.250.237])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6VChjF2262336
	for <linux-mm@kvack.org>; Tue, 31 Jul 2007 22:43:45 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6VCiVmW008250
	for <linux-mm@kvack.org>; Tue, 31 Jul 2007 22:44:31 +1000
Message-ID: <46AF2EAA.2080703@linux.vnet.ibm.com>
Date: Tue, 31 Jul 2007 18:14:26 +0530
From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [-mm PATCH 4/9] Memory controller memory accounting (v4)
References: <20070727201018.31565.42132.sendpatchset@balbir-laptop> <20070731033832.9E8B41BF6B4@siro.lan>
In-Reply-To: <20070731033832.9E8B41BF6B4@siro.lan>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: balbir@linux.vnet.ibm.com, a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ebiederm@xmission.com, containers@lists.osdl.org, akpm@linux-foundation.org, xemul@openvz.org, menage@google.com, dhaval@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>


YAMAMOTO Takashi wrote:
>> +	lock_meta_page(page);
>> +	/*
>> +	 * Check if somebody else beat us to allocating the meta_page
>> +	 */
>> +	race_mp = page_get_meta_page(page);
>> +	if (race_mp) {
>> +		kfree(mp);
>> +		mp = race_mp;
>> +		atomic_inc(&mp->ref_cnt);
>> +		res_counter_uncharge(&mem->res, 1);
>> +		goto done;
>> +	}
> 
> i think you need css_put here.

Thats correct. We do need css_put in this path.

Thanks,
Vaidy

> YAMAMOTO Takashi
> _______________________________________________
> Containers mailing list
> Containers@lists.linux-foundation.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
