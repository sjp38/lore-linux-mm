Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id EEF556B0260
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 10:40:30 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id w130so12609705lfd.3
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 07:40:30 -0700 (PDT)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.16])
        by mx.google.com with ESMTPS id 8si3798207wmu.80.2016.07.07.07.40.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jul 2016 07:40:29 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id 4DA421C168E
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 15:40:29 +0100 (IST)
Date: Thu, 7 Jul 2016 15:40:27 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 1/9] x86, pkeys: add fault handling for PF_PK page fault
 bit
Message-ID: <20160707144027.GX11498@techsingularity.net>
References: <20160707124719.3F04C882@viggo.jf.intel.com>
 <20160707124720.6E0DC397@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160707124720.6E0DC397@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, dave.hansen@linux.intel.com, arnd@arndb.de, hughd@google.com, viro@zeniv.linux.org.uk

On Thu, Jul 07, 2016 at 05:47:20AM -0700, Dave Hansen wrote:
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> PF_PK means that a memory access violated the protection key
> access restrictions.  It is unconditionally an access_error()
> because the permissions set on the VMA don't matter (the PKRU
> value overrides it), and we never "resolve" PK faults (like
> how a COW can "resolve write fault).
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>

An access fault gets propgated as SEGV_PKUERR. What happens if glibc
does not recognise it?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
