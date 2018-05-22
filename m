Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1FA3F6B000E
	for <linux-mm@kvack.org>; Tue, 22 May 2018 12:46:07 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id k4-v6so954849qtm.4
        for <linux-mm@kvack.org>; Tue, 22 May 2018 09:46:07 -0700 (PDT)
Received: from a9-92.smtp-out.amazonses.com (a9-92.smtp-out.amazonses.com. [54.240.9.92])
        by mx.google.com with ESMTPS id 75-v6si3076804qvb.84.2018.05.22.09.46.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 22 May 2018 09:46:06 -0700 (PDT)
Date: Tue, 22 May 2018 16:46:05 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: Add new vma flag VM_LOCAL_CPU
In-Reply-To: <50cbc27f-0014-0185-048d-25640f744b5b@linux.intel.com>
Message-ID: <0100016388be5738-df8f9d12-7011-4e4e-ba5b-33973e5da794-000000@email.amazonses.com>
References: <0efb5547-9250-6b6c-fe8e-cf4f44aaa5eb@netapp.com> <20180514191551.GA27939@bombadil.infradead.org> <7ec6fa37-8529-183d-d467-df3642bcbfd2@netapp.com> <20180515004137.GA5168@bombadil.infradead.org> <f3a66d8b-b9dc-b110-08aa-a63f0c309fb2@netapp.com>
 <010001637399f796-3ffe3ed2-2fb1-4d43-84f0-6a65b6320d66-000000@email.amazonses.com> <5aea6aa0-88cc-be7a-7012-7845499ced2c@netapp.com> <50cbc27f-0014-0185-048d-25640f744b5b@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Boaz Harrosh <boazh@netapp.com>, Jeff Moyer <jmoyer@redhat.com>, Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Amit Golander <Amit.Golander@netapp.com>

On Tue, 22 May 2018, Dave Hansen wrote:

> On 05/22/2018 09:05 AM, Boaz Harrosh wrote:
> > How can we implement "Private memory"?
>
> Per-cpu page tables would do it.

We already have that for percpu subsystem. See alloc_percpu()
