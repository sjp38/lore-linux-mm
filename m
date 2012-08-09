Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 199106B0081
	for <linux-mm@kvack.org>; Thu,  9 Aug 2012 11:26:21 -0400 (EDT)
Date: Thu, 9 Aug 2012 08:26:20 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH v2 4/6] x86: Add clear_page_nocache
Message-ID: <20120809152620.GH2644@tassilo.jf.intel.com>
References: <1344524583-1096-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1344524583-1096-5-git-send-email-kirill.shutemov@linux.intel.com>
 <5023F1BC0200007800093EF0@nat28.tlf.novell.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5023F1BC0200007800093EF0@nat28.tlf.novell.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Beulich <JBeulich@suse.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> While on 64-bit this is fine, I fail to see how you avoid using the
> SSE2 instruction on non-SSE2 systems.

You're right, this needs a fallback path for 32bit non sse
(and fixing the ABI)

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
