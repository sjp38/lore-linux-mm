Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id EE0836B0311
	for <linux-mm@kvack.org>; Wed, 24 May 2017 06:05:19 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id d127so36986560wmf.15
        for <linux-mm@kvack.org>; Wed, 24 May 2017 03:05:19 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y4si24584001edc.183.2017.05.24.03.05.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 May 2017 03:05:18 -0700 (PDT)
Subject: Re: [PATCHv6 04/10] x86/boot/64: Rename init_level4_pgt and
 early_level4_pgt
References: <20170524095419.14281-1-kirill.shutemov@linux.intel.com>
 <20170524095419.14281-5-kirill.shutemov@linux.intel.com>
From: Juergen Gross <jgross@suse.com>
Message-ID: <efcac8cf-a772-3c84-1821-1e243e8cee00@suse.com>
Date: Wed, 24 May 2017 12:05:16 +0200
MIME-Version: 1.0
In-Reply-To: <20170524095419.14281-5-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 24/05/17 11:54, Kirill A. Shutemov wrote:
> With CONFIG_X86_5LEVEL=y, level 4 is no longer top level of page tables.
> 
> Let's give these variable more generic names: init_top_pgt and
> early_top_pgt.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Xen parts: Reviewed-by: Juergen Gross <jgross@suse.com>


Juergen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
