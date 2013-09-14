Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 3D07D6B0031
	for <linux-mm@kvack.org>; Fri, 13 Sep 2013 22:51:39 -0400 (EDT)
Message-ID: <5233CF32.3080409@jp.fujitsu.com>
Date: Fri, 13 Sep 2013 22:51:30 -0400
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm/shmem.c: check the return value of mpol_to_str()
References: <5215639D.1080202@asianux.com> <5227CF48.5080700@asianux.com> <alpine.DEB.2.02.1309091326210.16291@chino.kir.corp.google.com> <522E6C14.7060006@asianux.com> <alpine.DEB.2.02.1309092334570.20625@chino.kir.corp.google.com> <522EC3D1.4010806@asianux.com> <alpine.DEB.2.02.1309111725290.22242@chino.kir.corp.google.com> <523124B7.8070408@gmail.com> <alpine.DEB.2.02.1309131410290.31480@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1309131410290.31480@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rientjes@google.com
Cc: kosaki.motohiro@gmail.com, gang.chen@asianux.com, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, hughd@google.com, xemul@parallels.com, liwanp@linux.vnet.ibm.com, gorcunov@gmail.com, linux-mm@kvack.org, akpm@linux-foundation.org

On 9/13/2013 5:12 PM, David Rientjes wrote:
> On Wed, 11 Sep 2013, KOSAKI Motohiro wrote:
> 
>> At least, currently mpol_to_str() already have following assertion. I mean,
>> the code assume every developer know maximum length of mempolicy. I have no
>> seen any reason to bring addional complication to shmem area.
>>
>>
>> 	/*
>> 	 * Sanity check:  room for longest mode, flag and some nodes
>> 	 */
>> 	VM_BUG_ON(maxlen < strlen("interleave") + strlen("relative") + 16);
>>
> 
> No need to make it a runtime error, the value passed as maxlen is a 
> constant, as is the use of sizeof(buffer), so the value is known at 
> compile-time.  You can make this a BUILD_BUG_ON() if you are creative.

Making compile time error brings us another complication. I'd like to
keep just one line assertion.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
