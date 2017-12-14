Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id E241A6B0038
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 19:42:38 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id f9so2269335wra.2
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 16:42:38 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c2sor2050968edi.46.2017.12.13.16.42.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Dec 2017 16:42:37 -0800 (PST)
Date: Thu, 14 Dec 2017 03:42:36 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv4 09/12] x86/mm: Provide pmdp_establish() helper
Message-ID: <20171214004235.uuyyhk5zpvutysct@node.shutemov.name>
References: <20171213105756.69879-1-kirill.shutemov@linux.intel.com>
 <20171213105756.69879-10-kirill.shutemov@linux.intel.com>
 <20171213160951.249071f2aecdccb38b6bb646@linux-foundation.org>
 <20171214003318.xli42qgybplln754@node.shutemov.name>
 <20171213163639.7e1fb5c4082888d2e399b310@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171213163639.7e1fb5c4082888d2e399b310@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>

On Wed, Dec 13, 2017 at 04:36:39PM -0800, Andrew Morton wrote:
> So how the heck do we test this?  Add an artificial delay on the other
> side to open the race window?

I'll look tomorrow how we can provide proper testing for the corner case.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
