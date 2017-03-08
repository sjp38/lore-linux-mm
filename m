Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 502726B03D8
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 10:07:48 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id w189so60113274pfb.4
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 07:07:48 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id 73si3497200pfz.297.2017.03.08.07.07.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 07:07:47 -0800 (PST)
Date: Wed, 8 Mar 2017 18:07:42 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 0/7] 5-level paging: prepare generic code
Message-ID: <20170308150742.aaqfknxhurvvrvsl@black.fi.intel.com>
References: <20170306204514.1852-1-kirill.shutemov@linux.intel.com>
 <20170308142501.GB11034@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170308142501.GB11034@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Mar 08, 2017 at 03:25:01PM +0100, Michal Hocko wrote:
> Btw. my build test machinery has reported this:
> microblaze/allnoconfig

Thanks.

Fixup is below. I guess it should be folded into 4/7.

diff --git a/arch/microblaze/include/asm/page.h b/arch/microblaze/include/asm/page.h
index fd850879854d..d506bb0893f9 100644
--- a/arch/microblaze/include/asm/page.h
+++ b/arch/microblaze/include/asm/page.h
@@ -95,7 +95,8 @@ typedef struct { unsigned long pgd; } pgd_t;
 #   else /* CONFIG_MMU */
 typedef struct { unsigned long	ste[64]; }	pmd_t;
 typedef struct { pmd_t		pue[1]; }	pud_t;
-typedef struct { pud_t		pge[1]; }	pgd_t;
+typedef struct { pud_t		p4e[1]; }	p4d_t;
+typedef struct { p4d_t		pge[1]; }	pgd_t;
 #   endif /* CONFIG_MMU */
 
 # define pte_val(x)	((x).pte)
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
