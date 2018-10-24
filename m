Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id E90196B0008
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 15:40:32 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id a72-v6so4670132pfj.14
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 12:40:32 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [198.137.202.136])
        by mx.google.com with ESMTPS id w64-v6si2153248pfw.101.2018.10.24.12.40.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 24 Oct 2018 12:40:31 -0700 (PDT)
Subject: Re: [PATCH 2/2] x86/ldt: Unmap PTEs for the slow before freeing LDT
References: <20181023163157.41441-1-kirill.shutemov@linux.intel.com>
 <20181023163157.41441-3-kirill.shutemov@linux.intel.com>
From: "H. Peter Anvin" <hpa@zytor.com>
Message-ID: <8430e07d-4648-3543-08e5-03b9550d9f72@zytor.com>
Date: Wed, 24 Oct 2018 12:39:51 -0700
MIME-Version: 1.0
In-Reply-To: <20181023163157.41441-3-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 10/23/18 9:31 AM, Kirill A. Shutemov wrote:
> 
> It shouldn't be a particularly hot path anyway.
> 

That's putting it mildly.

	-hpa
