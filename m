Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 92FFD6B0032
	for <linux-mm@kvack.org>; Thu, 16 May 2013 21:46:41 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id D97953EE0C0
	for <linux-mm@kvack.org>; Fri, 17 May 2013 10:46:39 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C918845DE54
	for <linux-mm@kvack.org>; Fri, 17 May 2013 10:46:39 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B1D2145DE4D
	for <linux-mm@kvack.org>; Fri, 17 May 2013 10:46:39 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id A4DA81DB803C
	for <linux-mm@kvack.org>; Fri, 17 May 2013 10:46:39 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 58A921DB8038
	for <linux-mm@kvack.org>; Fri, 17 May 2013 10:46:39 +0900 (JST)
Message-ID: <51958BC0.207@jp.fujitsu.com>
Date: Fri, 17 May 2013 10:45:36 +0900
From: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 0/8] kdump, vmcore: support mmap() on /proc/vmcore
References: <20130515090507.28109.28956.stgit@localhost6.localdomain6> <51957469.2000008@zytor.com>
In-Reply-To: <51957469.2000008@zytor.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: vgoyal@redhat.com, ebiederm@xmission.com, akpm@linux-foundation.org, cpw@sgi.com, kumagai-atsushi@mxc.nes.nec.co.jp, lisa.mitchell@hp.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, zhangyanfei@cn.fujitsu.com, jingbai.ma@hp.com, linux-mm@kvack.org, riel@redhat.com, walken@google.com, hughd@google.com, kosaki.motohiro@jp.fujitsu.com

(2013/05/17 9:06), H. Peter Anvin wrote:
> On 05/15/2013 02:05 AM, HATAYAMA Daisuke wrote:
>> Currently, read to /proc/vmcore is done by read_oldmem() that uses
>> ioremap/iounmap per a single page. For example, if memory is 1GB,
>> ioremap/iounmap is called (1GB / 4KB)-times, that is, 262144
>> times. This causes big performance degradation.
>
> read_oldmem() is fundamentally broken and unsafe.  It needs to be
> unified with the plain /dev/mem code and any missing functionality fixed
> instead of "let's just do a whole new driver".
>
> 	-hpa

Do you mean range_is_allowed should be extended so that it checks 
according to memory map passed from the 1st kernel?

BTW, read request to read_oldmem via read_vmcore and mmap on some part 
of the 1st kernel, seems safe since it's always restrected to within the 
memory map.

Or is there other missing point?

-- 
Thanks.
HATAYAMA, Daisuke

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
