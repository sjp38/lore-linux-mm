Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id D62466B02FA
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 13:02:37 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id s3so3338434oia.4
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 10:02:37 -0700 (PDT)
Received: from mail-ot0-x236.google.com (mail-ot0-x236.google.com. [2607:f8b0:4003:c0f::236])
        by mx.google.com with ESMTPS id 72si242848otc.327.2017.06.14.10.02.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jun 2017 10:02:37 -0700 (PDT)
Received: by mail-ot0-x236.google.com with SMTP id k4so5126056otd.0
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 10:02:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <e944ba00-3139-8da0-a1f9-642be9300c7c@suse.cz>
References: <149739530052.20686.9000645746376519779.stgit@dwillia2-desk3.amr.corp.intel.com>
 <149739530612.20686.14760671150202647861.stgit@dwillia2-desk3.amr.corp.intel.com>
 <e944ba00-3139-8da0-a1f9-642be9300c7c@suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 14 Jun 2017 10:02:36 -0700
Message-ID: <CAPcyv4h2GfqK3o4WdrKuhKnmjWeXBjeCOCsMv4M-xg9PViLbFw@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] mm: improve readability of transparent_hugepage_enabled()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Wed, Jun 14, 2017 at 9:53 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
> On 06/14/2017 01:08 AM, Dan Williams wrote:
>> Turn the macro into a static inline and rewrite the condition checks for
>> better readability in preparation for adding another condition.
>>
>> Cc: Jan Kara <jack@suse.cz>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
>> [ross: fix logic to make conversion equivalent]
>> Acked-by: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>
> Reviewed-by: Vlastimil Babka <vbabka@suse.cz>
>
> vbabka@gusiac:~/wrk/cbmc> cbmc test-thp.c
> CBMC version 5.3 64-bit x86_64 linux
> Parsing test-thp.c
> file <command-line> line 0: <command-line>:0:0: warning:
> "__STDC_VERSION__" redefined
> file <command-line> line 0: <built-in>: note: this is the location of
> the previous definition
> Converting
> Type-checking test-thp
> file test-thp.c line 75 function main: function `assert' is not declared
> Generating GOTO Program
> Adding CPROVER library
> Function Pointer Removal
> Partial Inlining
> Generic Property Instrumentation
> Starting Bounded Model Checking
> size of program expression: 171 steps
> simple slicing removed 3 assignments
> Generated 1 VCC(s), 1 remaining after simplification
> Passing problem to propositional reduction
> converting SSA
> Running propositional reduction
> Post-processing
> Solving with MiniSAT 2.2.0 with simplifier
> 4899 variables, 13228 clauses
> SAT checker: negated claim is UNSATISFIABLE, i.e., holds
> Runtime decision procedure: 0.008s
> VERIFICATION SUCCESSFUL
>
> (and yeah, the v1 version fails :)

Can you share the test-thp.c so I can add this to my test collection?
I'm assuming cbmc is "Bounded Model Checker for C/C++"?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
