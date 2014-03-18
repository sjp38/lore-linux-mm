Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 52BCE6B00E8
	for <linux-mm@kvack.org>; Tue, 18 Mar 2014 03:08:01 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id r10so6676165pdi.35
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 00:08:01 -0700 (PDT)
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com. [202.81.31.144])
        by mx.google.com with ESMTPS id f1si17016280pbn.76.2014.03.18.00.07.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 18 Mar 2014 00:08:00 -0700 (PDT)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <raghavendra.kt@linux.vnet.ibm.com>;
	Tue, 18 Mar 2014 17:07:56 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 6BBB72BB0056
	for <linux-mm@kvack.org>; Tue, 18 Mar 2014 18:07:53 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s2I6lgut20185216
	for <linux-mm@kvack.org>; Tue, 18 Mar 2014 17:47:44 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s2I77pKU004889
	for <linux-mm@kvack.org>; Tue, 18 Mar 2014 18:07:51 +1100
Message-ID: <5327F218.1000506@linux.vnet.ibm.com>
Date: Tue, 18 Mar 2014 12:43:28 +0530
From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH V6 ] mm readahead: Fix readahead fail for memoryless cpu
 and limit readahead pages
References: <1392708338-19685-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com> <20140218094920.GB29660@quack.suse.cz> <53034C66.90707@linux.vnet.ibm.com> <871ty1zig4.fsf@redhat.com>
In-Reply-To: <871ty1zig4.fsf@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Madper Xie <cxie@redhat.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, rientjes@google.com, Linus <torvalds@linux-foundation.org>, nacc@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 03/17/2014 07:37 AM, Madper Xie wrote:
>
> Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com> writes:
>
>> On 02/18/2014 03:19 PM, Jan Kara wrote:
>>> On Tue 18-02-14 12:55:38, Raghavendra K T wrote:
> Hi. Just a concern. Will the performance reduce on some special storage
> backend? E.g. tape.
> The existent applications may using readahead for userspace I/O schedule
> to decrease seeking time.

I have not tested the patch on such systems yet unfortunately :(.
Sequential read with huge file has not suffered on disk based system,
but I think, I should be honest enough not to guess the effect on tape.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
