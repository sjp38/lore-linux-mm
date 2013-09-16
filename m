Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id A94BE6B0099
	for <linux-mm@kvack.org>; Sun, 15 Sep 2013 23:28:51 -0400 (EDT)
Message-ID: <52367AB0.9000805@asianux.com>
Date: Mon, 16 Sep 2013 11:27:44 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm/shmem.c: check the return value of mpol_to_str()
References: <5215639D.1080202@asianux.com> <5227CF48.5080700@asianux.com> <alpine.DEB.2.02.1309091326210.16291@chino.kir.corp.google.com> <522E6C14.7060006@asianux.com> <alpine.DEB.2.02.1309092334570.20625@chino.kir.corp.google.com> <522EC3D1.4010806@asianux.com> <alpine.DEB.2.02.1309111725290.22242@chino.kir.corp.google.com> <523124B7.8070408@gmail.com> <alpine.DEB.2.02.1309131410290.31480@chino.kir.corp.google.com> <5233CF32.3080409@jp.fujitsu.com>
In-Reply-To: <5233CF32.3080409@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: rientjes@google.com, kosaki.motohiro@gmail.com, riel@redhat.com, hughd@google.com, xemul@parallels.com, liwanp@linux.vnet.ibm.com, gorcunov@gmail.com, linux-mm@kvack.org, akpm@linux-foundation.org

On 09/14/2013 10:51 AM, KOSAKI Motohiro wrote:
> On 9/13/2013 5:12 PM, David Rientjes wrote:
>> On Wed, 11 Sep 2013, KOSAKI Motohiro wrote:
>>
>>> At least, currently mpol_to_str() already have following assertion. I mean,
>>> the code assume every developer know maximum length of mempolicy. I have no
>>> seen any reason to bring addional complication to shmem area.
>>>
>>>
>>> 	/*
>>> 	 * Sanity check:  room for longest mode, flag and some nodes
>>> 	 */
>>> 	VM_BUG_ON(maxlen < strlen("interleave") + strlen("relative") + 16);
>>>
>>
>> No need to make it a runtime error, the value passed as maxlen is a 
>> constant, as is the use of sizeof(buffer), so the value is known at 
>> compile-time.  You can make this a BUILD_BUG_ON() if you are creative.
> 
> Making compile time error brings us another complication. I'd like to
> keep just one line assertion.
> 

Hmm... I am not quite sure: a C compiler is clever enough to know about
that.

At least, for ANSI C definition, the C compiler has no duty to know
about that.

And it is not for an optimization, either, so I guess the C compiler has
no enought interests to support this features (know about that).


Thanks.
-- 
Chen Gang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
