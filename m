Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 568DE6B025F
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 07:54:24 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id y206so7917477wmd.1
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 04:54:24 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 4si3130064wrm.255.2017.08.09.04.54.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 09 Aug 2017 04:54:23 -0700 (PDT)
Subject: Re: [PATCHv4 05/14] x86/xen: Drop 5-level paging support code from
 XEN_PV code
References: <20170808125415.78842-1-kirill.shutemov@linux.intel.com>
 <20170808125415.78842-6-kirill.shutemov@linux.intel.com>
From: Juergen Gross <jgross@suse.com>
Message-ID: <13475f72-4d10-f6f3-f311-05d875feb740@suse.com>
Date: Wed, 9 Aug 2017 13:54:20 +0200
MIME-Version: 1.0
In-Reply-To: <20170808125415.78842-6-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/08/17 14:54, Kirill A. Shutemov wrote:
> It was decided 5-level paging is not going to be supported in XEN_PV.
> 
> Let's drop the dead code from XEN_PV code.
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
