Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id EAF006B0074
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 04:45:21 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 994FD3EE1DE
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 17:45:20 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8893045DE53
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 17:45:20 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E81845DE4E
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 17:45:20 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E9841DB8041
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 17:45:20 +0900 (JST)
Received: from g01jpfmpwyt01.exch.g01.fujitsu.local (g01jpfmpwyt01.exch.g01.fujitsu.local [10.128.193.38])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0CBA41DB803A
	for <linux-mm@kvack.org>; Thu, 22 Aug 2013 17:45:20 +0900 (JST)
Message-ID: <5215CF7F.5060109@jp.fujitsu.com>
Date: Thu, 22 Aug 2013 17:44:47 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/7] drivers: base: move mutex lock out of add_memory_section()
References: <1377018783-26756-1-git-send-email-sjenning@linux.vnet.ibm.com> <20130820172445.GE4151@medulla.variantweb.net>
In-Reply-To: <20130820172445.GE4151@medulla.variantweb.net>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dave Hansen <dave@sr71.net>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Yinghai Lu <yinghai@kernel.org>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

(2013/08/21 2:24), Seth Jennings wrote:
> Gah! Forgot the cover letter.
>
> This patchset just seeks to clean up and refactor some things in
> memory.c for better understanding and possibly better performance due do
> a decrease in mutex acquisitions and refcount churn at boot time.  No
> functional change is intended by this set!

All patches were
Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Tested-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Thanks,
Yasuaki Ishimatsu

>
> Seth
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
