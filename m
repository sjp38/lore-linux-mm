Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 78CC4800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 10:52:33 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 64so2659307pgc.17
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 07:52:33 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id s84si298040pgs.289.2018.01.24.07.52.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jan 2018 07:52:32 -0800 (PST)
Date: Wed, 24 Jan 2018 18:52:27 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 1/3] x86/mm/encrypt: Move sme_populate_pgd*() into
 separate translation unit
Message-ID: <20180124155227.wg7itpohsvd2i7wt@black.fi.intel.com>
References: <20180123171910.55841-1-kirill.shutemov@linux.intel.com>
 <20180123171910.55841-2-kirill.shutemov@linux.intel.com>
 <1dee5138-fe8e-70ec-61d1-86f802e68e7c@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1dee5138-fe8e-70ec-61d1-86f802e68e7c@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jan 24, 2018 at 02:59:58PM +0000, Tom Lendacky wrote:
> >  static void __init sme_clear_pgd(struct sme_populate_pgd_data *ppd)
> 
> If you're going to move some of the functions, did you look at moving the
> sme_enable(), sme_encrypt_kernel(), etc., too?  I believe everything below
> the sme_populate_pgd_data structure is used during early identity-mapped
> boot time. If you move everything, then mm_internal.h doesn't need to be
> updated and all of the identity-mapped early boot code ends up in one
> file.
> 
> You'd have to move the command line declarations and make sev_enabled
> not a static, but it should be doable.

I moved minimum of the code to get the trick work, but I'll look into
moving move there.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
