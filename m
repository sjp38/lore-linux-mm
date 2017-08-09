Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id EECA66B025F
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 07:51:03 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id r7so8552279wrb.0
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 04:51:03 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u7si3130473wrb.292.2017.08.09.04.51.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 09 Aug 2017 04:51:02 -0700 (PDT)
Subject: Re: [PATCHv4 13/14] x86/xen: Allow XEN_PV and XEN_PVH to be enabled
 with X86_5LEVEL
References: <20170808125415.78842-1-kirill.shutemov@linux.intel.com>
 <20170808125415.78842-14-kirill.shutemov@linux.intel.com>
From: Juergen Gross <jgross@suse.com>
Message-ID: <c9fedd71-2a89-9c70-0a2d-20ff6dcb5f57@suse.com>
Date: Wed, 9 Aug 2017 13:50:59 +0200
MIME-Version: 1.0
In-Reply-To: <20170808125415.78842-14-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/08/17 14:54, Kirill A. Shutemov wrote:
> With boot-time switching between paging modes, XEN_PV and XEN_PVH can be
> boot into 4-level paging mode.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Juergen Gross <jgross@suse.com>

Reviewed-by: Juergen Gross <jgross@suse.com>
Tested-by: Juergen Gross <jgross@suse.com>


Thanks,

Juergen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
