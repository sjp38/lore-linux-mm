Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 764E96B0069
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 14:29:46 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id z128so76521829pfb.4
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 11:29:46 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id r20si76948909pfj.47.2017.01.05.11.29.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jan 2017 11:29:45 -0800 (PST)
Date: Thu, 5 Jan 2017 22:29:10 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [RFC, PATCHv2 29/29] mm, x86: introduce RLIMIT_VADDR
Message-ID: <20170105192910.q26ozg4ci4i3j2ai@black.fi.intel.com>
References: <20161227015413.187403-1-kirill.shutemov@linux.intel.com>
 <20161227015413.187403-30-kirill.shutemov@linux.intel.com>
 <5a3dcc25-b264-37c7-c090-09981b23940d@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5a3dcc25-b264-37c7-c090-09981b23940d@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org

On Thu, Jan 05, 2017 at 11:13:57AM -0800, Dave Hansen wrote:
> On 12/26/2016 05:54 PM, Kirill A. Shutemov wrote:
> > MM would use min(RLIMIT_VADDR, TASK_SIZE) as upper limit of virtual
> > address available to map by userspace.
> 
> What happens to existing mappings above the limit when this upper limit
> is dropped?

Nothing: we only prevent creating new mappings. All existing are not
affected.

The semantics here the same as with other resource limits.

> Similarly, why do we do with an application running with something
> incompatible with the larger address space that tries to raise the
> limit?  Say, legacy MPX.

It has to know what it does. Yes, it can change limit to the point where
application is unusable. But you can to the same with other limits.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
