Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8DC416B025F
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 03:57:43 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id k69so1912100wmc.14
        for <linux-mm@kvack.org>; Thu, 20 Jul 2017 00:57:43 -0700 (PDT)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id l98si3114428wrc.370.2017.07.20.00.57.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jul 2017 00:57:42 -0700 (PDT)
Received: by mail-wm0-x231.google.com with SMTP id w191so19132679wmw.1
        for <linux-mm@kvack.org>; Thu, 20 Jul 2017 00:57:42 -0700 (PDT)
Date: Thu, 20 Jul 2017 10:57:40 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 0/8] 5-level paging enabling for v4.14
Message-ID: <20170720075740.4zo6hvkbjwrylfqe@node.shutemov.name>
References: <20170716225954.74185-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170716225954.74185-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 17, 2017 at 01:59:46AM +0300, Kirill A. Shutemov wrote:
> Hi,
> 
> As Ingo requested, I'm resending the rebased patchset after merge window to be
> queued for v4.14.
> 
> The patches was reordered and few more fixes added: for Xen and dump_pagetables.
> 
> Please consider applying.

Ingo, can we get this applied? You seems had no issue with the patchset
before merge window.

I would also appreciate feed on boot-time switching patchset.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
