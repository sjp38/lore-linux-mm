Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 232DC6B02A3
	for <linux-mm@kvack.org>; Tue, 15 May 2018 10:11:20 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e16-v6so145609pfn.5
        for <linux-mm@kvack.org>; Tue, 15 May 2018 07:11:20 -0700 (PDT)
Received: from mx142.netapp.com (mx142.netapp.com. [2620:10a:4005:8000:2306::b])
        by mx.google.com with ESMTPS id a64-v6si111615pla.530.2018.05.15.07.11.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 May 2018 07:11:19 -0700 (PDT)
Subject: Re: [PATCH] mm: Add new vma flag VM_LOCAL_CPU
References: <0efb5547-9250-6b6c-fe8e-cf4f44aaa5eb@netapp.com>
 <20180514191551.GA27939@bombadil.infradead.org>
 <7ec6fa37-8529-183d-d467-df3642bcbfd2@netapp.com>
 <20180515004137.GA5168@bombadil.infradead.org>
 <f3a66d8b-b9dc-b110-08aa-a63f0c309fb2@netapp.com>
 <20180515111159.GA31599@bombadil.infradead.org>
 <6999e635-e804-99d0-12fc-c13ff3e9ca58@netapp.com>
 <20180515120355.GE31599@bombadil.infradead.org>
 <afe2c02f-3ecd-5f54-53ab-d45c11a5b4aa@netapp.com>
 <20180515135056.GG31599@bombadil.infradead.org>
From: Boaz Harrosh <boazh@netapp.com>
Message-ID: <da89bf77-fcb5-1c0c-f5ce-66e552d9a54d@netapp.com>
Date: Tue, 15 May 2018 17:10:57 +0300
MIME-Version: 1.0
In-Reply-To: <20180515135056.GG31599@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Jeff Moyer <jmoyer@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.
 Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van
 Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Amit Golander <Amit.Golander@netapp.com>

On 15/05/18 16:50, Matthew Wilcox wrote:
> On Tue, May 15, 2018 at 04:29:22PM +0300, Boaz Harrosh wrote:
>> On 15/05/18 15:03, Matthew Wilcox wrote:
>>> You're getting dangerously close to admitting that the entire point
>>> of this exercise is so that you can link non-GPL NetApp code into the
>>> kernel in clear violation of the GPL.
>>
>> It is not that at all. What I'm trying to do is enable a zero-copy,
>> synchronous, low latency, low overhead. highly parallel - a new modern
>> interface with application servers.
> 
> ... and fully buzzword compliant.
> 
>> You yourself had such a project that could easily be served out-of-the-box
>> with zufs, of a device that wanted to sit in user-mode.
> 
> For a very different reason.  I think the source code to that project
> is publically available; the problem is that it's not written in C.
> 

Exactly the point, sir. Many reasons to sit in user-land for example
for me it is libraries that can not be loaded into Kernel.

>> Sometimes it is very convenient and needed for Servers to sit in
>> user-mode. And this interface allows that. And it is not always
>> a licensing thing. Though yes licensing is also an issue sometimes.
>> It is the reality we are living in.
>>
>> But please indulge me I am curious how the point of signing /sbin/
>> servers, made you think about GPL licensing issues?
>>
>> That said, is your point that as long as user-mode servers are sloooowwww
>> they are OK to be supported but if they are as fast as the kernel,
>> (as demonstrated a zufs based FS was faster then xfs-dax on same pmem)
>> Then it is a GPL violation?
> 
> No.  Read what Linus wrote:
> 
>    NOTE! This copyright does *not* cover user programs that use kernel
>  services by normal system calls - this is merely considered normal use
>  of the kernel, and does *not* fall under the heading of "derived work".
> 
> What you're doing is far beyond that exception.  You're developing in
> concert a userspace and kernel component, and claiming that the GPL does
> not apply to the userspace component.  I'm not a lawyer, but you're on
> very thin ice.
> 

But I am not the first one here am I? Fuse and other interfaces already do
exactly this long before I did. Actually any Kernel Interface has some user-mode
component, specifically written for it. And again I am only legally doing exactly as
FUSE is doing only much faster, and more importantly for me highly parallel on all
cores. Because from my testing the biggest problem of FUSE for me is that it does not
scale

I'm not a lawyer either but I think I'm doing OK. Because I am doing exactly
like FUSE is doing. Only some 15 years later, with modern CPUs in mind. I do not
think I am doing anything new here, am I?

Thanks
Boaz
