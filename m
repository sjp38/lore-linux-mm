Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id E759C6B0036
	for <linux-mm@kvack.org>; Fri, 31 Jan 2014 19:32:29 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id bj1so5078438pad.11
        for <linux-mm@kvack.org>; Fri, 31 Jan 2014 16:32:29 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id to9si12233826pbc.335.2014.01.31.16.32.28
        for <linux-mm@kvack.org>;
        Fri, 31 Jan 2014 16:32:29 -0800 (PST)
Message-ID: <52EC4083.8010309@intel.com>
Date: Fri, 31 Jan 2014 16:32:03 -0800
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [LSF/MM TOPIC] Fixing large block devices on 32 bit
References: <1391194978.2172.20.camel@dabdike.int.hansenpartnership.com> <52EC19E6.9010509@intel.com> <1391210864.2172.61.camel@dabdike.int.hansenpartnership.com> <52EC3D9F.8040702@intel.com> <20140201002547.GA3551@node.dhcp.inet.fi>
In-Reply-To: <20140201002547.GA3551@node.dhcp.inet.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, linux-scsi <linux-scsi@vger.kernel.org>, linux-ide <linux-ide@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org

On 01/31/2014 04:25 PM, Kirill A. Shutemov wrote:
>> > I think all we have to do is set a low bit in page->mapping
> It's already in use to say page->mapping is anon_vma. ;)

I weasel-worded that by not saying *THE* low bit. ;)

We find *some* discriminator whether it be a page flag or an actual bit
in page->mapping, or a magic value that doesn't collide with the
existing PAGE_MAPPING_* flags.

Poor 'struct page'.  It's the doormat of data structures.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
