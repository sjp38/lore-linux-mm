Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 337068E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 20:07:19 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id t192so4241710ywe.4
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 17:07:19 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id x36si54157ywj.135.2019.01.16.17.07.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 17:07:17 -0800 (PST)
Subject: Re: [PATCH] mm: hwpoison: use do_send_sig_info() instead of
 force_sig() (Re: PMEM error-handling forces SIGKILL causes kernel panic)
References: <e3c4c0e0-1434-4353-b893-2973c04e7ff7@oracle.com>
 <CAPcyv4j67n6H7hD6haXJqysbaauci4usuuj5c+JQ7VQBGngO1Q@mail.gmail.com>
 <20190111081401.GA5080@hori1.linux.bs1.fc.nec.co.jp>
 <20190116093046.GA29835@hori1.linux.bs1.fc.nec.co.jp>
 <97e179e1-8a3a-5acb-78c1-a4b06b33db4c@oracle.com>
 <20190116233207.GA5868@hori1.linux.bs1.fc.nec.co.jp>
From: Jane Chu <jane.chu@oracle.com>
Message-ID: <6fa27824-d86d-f642-db7c-a13faaac527d@oracle.com>
Date: Wed, 16 Jan 2019 17:07:09 -0800
MIME-Version: 1.0
In-Reply-To: <20190116233207.GA5868@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=iso-2022-jp; format=flowed; delsp=yes
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>



On 1/16/2019 3:32 PM, Naoya Horiguchi wrote:
> Hi Jane,
> 
> On Wed, Jan 16, 2019 at 09:56:02AM -0800, Jane Chu wrote:
>> Hi, Naoya,
>>
>> On 1/16/2019 1:30 AM, Naoya Horiguchi wrote:
>>
>>      diff --git a/mm/memory-failure.c b/mm/memory-failure.c
>>      index 7c72f2a95785..831be5ff5f4d 100644
>>      --- a/mm/memory-failure.c
>>      +++ b/mm/memory-failure.c
>>      @@ -372,7 +372,8 @@ static void kill_procs(struct list_head *to_kill, int forcekill, bool fail,
>>                              if (fail || tk->addr_valid == 0) {
>>                                      pr_err("Memory failure: %#lx: forcibly killing %s:%d because of failure to unmap corrupted page\n",
>>                                             pfn, tk->tsk->comm, tk->tsk->pid);
>>      -                               force_sig(SIGKILL, tk->tsk);
>>      +                               do_send_sig_info(SIGKILL, SEND_SIG_PRIV,
>>      +                                                tk->tsk, PIDTYPE_PID);
>>                              }
>>
>>
>> Since we don't care the return from do_send_sig_info(), would you mind to
>> prefix it with (void) ?
> 
> Sorry, I'm not sure about the benefit to do casting the return value
> just being ignored, so personally I'd like keeping the code simple.
> Do you have some in mind?

It's just coding style I'm used to, no big deal.
Up to you to decide. :)

thanks,
-jane

> 
> - Naoya
> 
