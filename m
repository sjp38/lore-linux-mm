Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id EDC626B00E7
	for <linux-mm@kvack.org>; Sun, 26 May 2013 20:14:04 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id F41883EE0B6
	for <linux-mm@kvack.org>; Mon, 27 May 2013 09:14:02 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E08B03A62C4
	for <linux-mm@kvack.org>; Mon, 27 May 2013 09:14:02 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C5BD61EF08D
	for <linux-mm@kvack.org>; Mon, 27 May 2013 09:14:02 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B1A70E08005
	for <linux-mm@kvack.org>; Mon, 27 May 2013 09:14:02 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 61C361DB8050
	for <linux-mm@kvack.org>; Mon, 27 May 2013 09:14:02 +0900 (JST)
Message-ID: <51A2A524.4080303@jp.fujitsu.com>
Date: Mon, 27 May 2013 09:13:24 +0900
From: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v8 3/9] vmcore: treat memory chunks referenced by PT_LOAD
 program header entries in page-size boundary in vmcore_list
References: <20130523052421.13864.83978.stgit@localhost6.localdomain6> <20130523052513.13864.85440.stgit@localhost6.localdomain6> <20130523144928.0328bb3ad7ccc1ff2da9558d@linux-foundation.org> <20130524131217.GA18218@redhat.com>
In-Reply-To: <20130524131217.GA18218@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vivek Goyal <vgoyal@redhat.com>, ebiederm@xmission.com, cpw@sgi.com, kumagai-atsushi@mxc.nes.nec.co.jp, lisa.mitchell@hp.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, zhangyanfei@cn.fujitsu.com, jingbai.ma@hp.com, linux-mm@kvack.org, riel@redhat.com, walken@google.com, hughd@google.com, kosaki.motohiro@jp.fujitsu.com

(2013/05/24 22:12), Vivek Goyal wrote:
> On Thu, May 23, 2013 at 02:49:28PM -0700, Andrew Morton wrote:
>> On Thu, 23 May 2013 14:25:13 +0900 HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com> wrote:
>>
>>> Treat memory chunks referenced by PT_LOAD program header entries in
>>> page-size boundary in vmcore_list. Formally, for each range [start,
>>> end], we set up the corresponding vmcore object in vmcore_list to
>>> [rounddown(start, PAGE_SIZE), roundup(end, PAGE_SIZE)].
>>>
>>> This change affects layout of /proc/vmcore.
>>
>> Well, changing a userspace interface is generally unacceptable because
>> it can break existing userspace code.
>>
>> If you think the risk is acceptable then please do explain why.  In
>> great detail!
>
> I think it should not be a problem as /proc/vmcore is useful only when
> one parses the elf headers and then accesses the contents of file based
> on the header information. This patch just introduces additional areas
> in /proc/vmcore file and ELF headers still point to right contents. So
> any tool parsing ELF headers and then accessing file contents based on
> that info should still be fine.
>
> AFAIK, no user space tool should be broken there.
>
> Thanks
> Vivek
>

Yes, the changes are new introduction of holes between components of ELF
and tools doesn't reach the holes as long as by looking up program header
table and other tables. cp command touches the holes but trivially works
well.

-- 
Thanks.
HATAYAMA, Daisuke

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
