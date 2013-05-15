Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 6765C6B0032
	for <linux-mm@kvack.org>; Wed, 15 May 2013 04:26:04 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 61E4F3EE0BD
	for <linux-mm@kvack.org>; Wed, 15 May 2013 17:26:02 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5019745DEBA
	for <linux-mm@kvack.org>; Wed, 15 May 2013 17:26:02 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3641945DEB6
	for <linux-mm@kvack.org>; Wed, 15 May 2013 17:26:02 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 28FD01DB8038
	for <linux-mm@kvack.org>; Wed, 15 May 2013 17:26:02 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D25A61DB803B
	for <linux-mm@kvack.org>; Wed, 15 May 2013 17:26:01 +0900 (JST)
Message-ID: <51934685.9080909@jp.fujitsu.com>
Date: Wed, 15 May 2013 17:25:41 +0900
From: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 7/8] vmcore: calculate vmcore file size from buffer
 size and total size of vmcore objects
References: <20130514015622.18697.77191.stgit@localhost6.localdomain6> <20130514015746.18697.1089.stgit@localhost6.localdomain6> <20130514164739.GJ13674@redhat.com>
In-Reply-To: <20130514164739.GJ13674@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: ebiederm@xmission.com, akpm@linux-foundation.org, cpw@sgi.com, kumagai-atsushi@mxc.nes.nec.co.jp, lisa.mitchell@hp.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, zhangyanfei@cn.fujitsu.com, jingbai.ma@hp.com, linux-mm@kvack.org

(2013/05/15 1:47), Vivek Goyal wrote:
> On Tue, May 14, 2013 at 10:57:46AM +0900, HATAYAMA Daisuke wrote:
>> The previous patches newly added holes before each chunk of memory and
>> the holes need to be count in vmcore file size. There are two ways to
>> count file size in such a way:
>>
>> 1) supporse p as a poitner to the last program header entry with
>> PT_LOAD type, then roundup(p->p_offset + p->p_memsz, PAGE_SIZE), or

This part was wrong. This should have been:

1) support m as a pointer to the last vmcore object in vmcore_list, then 
file size is (m->offset + m->size), or

I'll correct this way in next patch.

Note that no functional change, only description is wrong here.

-- 
Thanks.
HATAYAMA, Daisuke

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
