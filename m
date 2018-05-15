Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 429FC6B02AD
	for <linux-mm@kvack.org>; Tue, 15 May 2018 10:31:19 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id d9-v6so186422plj.4
        for <linux-mm@kvack.org>; Tue, 15 May 2018 07:31:19 -0700 (PDT)
Received: from mx144.netapp.com (mx144.netapp.com. [2620:10a:4005:8000:2306::d])
        by mx.google.com with ESMTPS id g187-v6si121372pgc.644.2018.05.15.07.31.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 May 2018 07:31:18 -0700 (PDT)
Subject: Re: [PATCH] mm: Add new vma flag VM_LOCAL_CPU
References: <20180514191551.GA27939@bombadil.infradead.org>
 <7ec6fa37-8529-183d-d467-df3642bcbfd2@netapp.com>
 <20180515004137.GA5168@bombadil.infradead.org>
 <f3a66d8b-b9dc-b110-08aa-a63f0c309fb2@netapp.com>
 <20180515111159.GA31599@bombadil.infradead.org>
 <6999e635-e804-99d0-12fc-c13ff3e9ca58@netapp.com>
 <20180515120355.GE31599@bombadil.infradead.org>
 <afe2c02f-3ecd-5f54-53ab-d45c11a5b4aa@netapp.com>
 <20180515135056.GG31599@bombadil.infradead.org>
 <da89bf77-fcb5-1c0c-f5ce-66e552d9a54d@netapp.com>
 <20180515141839.GI31599@bombadil.infradead.org>
From: Boaz Harrosh <boazh@netapp.com>
Message-ID: <c07e1d43-598e-ac20-316d-64f6b6a0a4c7@netapp.com>
Date: Tue, 15 May 2018 17:30:43 +0300
MIME-Version: 1.0
In-Reply-To: <20180515141839.GI31599@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Boaz Harrosh <boazh@netapp.com>
Cc: Jeff Moyer <jmoyer@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H.
 Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Amit Golander <Amit.Golander@netapp.com>

On 15/05/18 17:18, Matthew Wilcox wrote:
> On Tue, May 15, 2018 at 05:10:57PM +0300, Boaz Harrosh wrote:
>> I'm not a lawyer either but I think I'm doing OK. Because I am doing exactly
>> like FUSE is doing. Only some 15 years later, with modern CPUs in mind. I do not
>> think I am doing anything new here, am I?
> 
> You should talk to a lawyer.  I'm not giving you legal advice.
> I'm telling you that I think what you're doing is unethical.
> .
> 

Not more unethical than what is already there. And I do not see how
this is unethical at all? I trust your opinion and would really want
to understand.

For example your not-in-c zero-copy Server. How is it unethical?
I have the same problem actually some important parts are not in C.

How is it unethical to want to make this run fast?

Thanks
Boaz
