Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 668966B0279
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 13:16:42 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id a38so3924115ota.12
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 10:16:42 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d79si267793oig.224.2017.06.14.10.16.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jun 2017 10:16:41 -0700 (PDT)
Received: from mail-ua0-f170.google.com (mail-ua0-f170.google.com [209.85.217.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id DF330239B4
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 17:16:40 +0000 (UTC)
Received: by mail-ua0-f170.google.com with SMTP id h39so4912037uaa.3
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 10:16:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <06ea73a2-f724-5b3e-5d9d-143d91ba94ae@intel.com>
References: <cover.1497415951.git.luto@kernel.org> <65ee83f8ef7259053e117355b0597b03ce096e07.1497415951.git.luto@kernel.org>
 <06ea73a2-f724-5b3e-5d9d-143d91ba94ae@intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 14 Jun 2017 10:16:19 -0700
Message-ID: <CALCETrXJx5c=OdNYtKJ7v3187L0r1jGuX_hfMeb76qqLGjDYxQ@mail.gmail.com>
Subject: Re: [PATCH v2 03/10] x86/mm: Give each mm TLB flush generation a
 unique ID
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Borislav Petkov <bp@alien8.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>, Arjan van de Ven <arjan@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>

On Wed, Jun 14, 2017 at 8:54 AM, Dave Hansen <dave.hansen@intel.com> wrote:
> On 06/13/2017 09:56 PM, Andy Lutomirski wrote:
>>  typedef struct {
>> +     /*
>> +      * ctx_id uniquely identifies this mm_struct.  A ctx_id will never
>> +      * be reused, and zero is not a valid ctx_id.
>> +      */
>> +     u64 ctx_id;
>
> Ahh, and you need this because an mm itself might get reused by being
> freed and reallocated?

Exactly.  I didn't want to have to zap the data structures on each CPU
every time an mm is freed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
