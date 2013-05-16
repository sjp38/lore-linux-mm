Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 8BD8A6B0033
	for <linux-mm@kvack.org>; Thu, 16 May 2013 19:47:20 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 32F873EE0C1
	for <linux-mm@kvack.org>; Fri, 17 May 2013 08:47:19 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 056F845DE4E
	for <linux-mm@kvack.org>; Fri, 17 May 2013 08:47:19 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id DA4E345DE4D
	for <linux-mm@kvack.org>; Fri, 17 May 2013 08:47:18 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C675E1DB8038
	for <linux-mm@kvack.org>; Fri, 17 May 2013 08:47:18 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 77FCF1DB803A
	for <linux-mm@kvack.org>; Fri, 17 May 2013 08:47:18 +0900 (JST)
Message-ID: <51956FF6.3070205@jp.fujitsu.com>
Date: Fri, 17 May 2013 08:47:02 +0900
From: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 6/8] vmcore: allocate ELF note segment in the 2nd kernel
 vmalloc memory
References: <20130515090507.28109.28956.stgit@localhost6.localdomain6> <20130515090614.28109.26492.stgit@localhost6.localdomain6> <20130516203236.GG5904@redhat.com>
In-Reply-To: <20130516203236.GG5904@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: riel@redhat.com, hughd@google.com, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, lisa.mitchell@hp.com, linux-mm@kvack.org, kumagai-atsushi@mxc.nes.nec.co.jp, ebiederm@xmission.com, kosaki.motohiro@jp.fujitsu.com, zhangyanfei@cn.fujitsu.com, akpm@linux-foundation.org, walken@google.com, cpw@sgi.com, jingbai.ma@hp.com

(2013/05/17 5:32), Vivek Goyal wrote:
> On Wed, May 15, 2013 at 06:06:14PM +0900, HATAYAMA Daisuke wrote:
>
> [..]
>
>> +static int __init get_note_number_and_size_elf32(const Elf32_Ehdr *ehdr_ptr,
>> +						 int *nr_ptnote, u64 *phdr_sz)
>> +{
>> +	return process_note_headers_elf32(ehdr_ptr, nr_ptnote, phdr_sz, NULL);
>> +}
>> +
>> +static int __init copy_notes_elf32(const Elf32_Ehdr *ehdr_ptr, char *notes_buf)
>> +{
>> +	return process_note_headers_elf32(ehdr_ptr, NULL, NULL, notes_buf);
>> +}
>> +
>
> Please don't do this. We need to create two separate functions doing
> two different operations and not just create wrapper around a function
> which does two things.
>
> I know both functions will have similar for loops for going through
> the elf notes but it is better then doing function overloading based
> on parameters passed.
>

I see. This part must be fixed in the next version.

-- 
Thanks.
HATAYAMA, Daisuke

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
