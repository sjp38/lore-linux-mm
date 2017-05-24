Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 554A56B0311
	for <linux-mm@kvack.org>; Wed, 24 May 2017 06:04:02 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 139so37079705wmf.5
        for <linux-mm@kvack.org>; Wed, 24 May 2017 03:04:02 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u3si24013416edc.292.2017.05.24.03.04.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 May 2017 03:04:01 -0700 (PDT)
Subject: Re: [PATCHv6 09/10] x86: Enable 5-level paging support
References: <20170524095419.14281-1-kirill.shutemov@linux.intel.com>
 <20170524095419.14281-10-kirill.shutemov@linux.intel.com>
From: Juergen Gross <jgross@suse.com>
Message-ID: <86216f6e-6af5-a457-90dc-a228b7ca6bdc@suse.com>
Date: Wed, 24 May 2017 12:03:58 +0200
MIME-Version: 1.0
In-Reply-To: <20170524095419.14281-10-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 24/05/17 11:54, Kirill A. Shutemov wrote:
> Most of things are in place and we can enable support of 5-level paging.
> 
> The patch makes XEN_PV dependent on !X86_5LEVEL. XEN_PV is not ready to
> work with 5-level paging.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Xen part: Reviewed-by: Juergen Gross <jgross@suse.com>


Juergen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
