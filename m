Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 659716B004F
	for <linux-mm@kvack.org>; Sat, 17 Dec 2011 08:47:19 -0500 (EST)
Received: by iacb35 with SMTP id b35so5322077iac.14
        for <linux-mm@kvack.org>; Sat, 17 Dec 2011 05:47:18 -0800 (PST)
Message-ID: <4EEC9D54.502@gmail.com>
Date: Sat, 17 Dec 2011 21:47:00 +0800
From: Wang Sheng-Hui <shhuiw@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/mempolicy.c: use enum value MPOL_REBIND_ONCE instead
 of 0 in mpol_rebind_policy
References: <4EE8A461.2080406@gmail.com> <alpine.DEB.2.00.1112141840550.27595@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1112141840550.27595@chino.kir.corp.google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2011a1'12ae??15ae?JPY 10:42, David Rientjes wrote:
> On Wed, 14 Dec 2011, Wang Sheng-Hui wrote:
> 
>> We have enum definition in mempolicy.h: MPOL_REBIND_ONCE.
>> It should replace the magic number 0 for step comparison in
>> function mpol_rebind_policy.
>>
>> Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>
> 
> Acked-by: David Rientjes <rientjes@google.com>
> 
> Tip: when proposing patches, it's helpful to run scripts/get_maintainer.pl 
> on your patch file from git to determine who should be cc'd on the email.

Thanks for your tip.
I have tried the script with option -f, and only get the mm, kernel mailing
lists, no specific maintainer provided. So here I just posted the patch to 
these 2 lists.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
