Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 3451F6B0031
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 11:08:00 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id ma3so6882889pbc.27
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 08:07:59 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id tj6si8479877pbc.511.2014.04.07.08.07.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 07 Apr 2014 08:07:59 -0700 (PDT)
Message-ID: <5342BCB1.9010109@oracle.com>
Date: Mon, 07 Apr 2014 10:56:49 -0400
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: mm: BUG in do_huge_pmd_wp_page
References: <51559150.3040407@oracle.com> <515D882E.6040001@oracle.com> <533F09F0.1050206@oracle.com> <20140407144835.GA17774@node.dhcp.inet.fi>
In-Reply-To: <20140407144835.GA17774@node.dhcp.inet.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Hugh Dickins <hughd@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Mel Gorman <mgorman@suse.de>, Dave Jones <davej@redhat.com>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 04/07/2014 10:48 AM, Kirill A. Shutemov wrote:
> On Fri, Apr 04, 2014 at 03:37:20PM -0400, Sasha Levin wrote:
>> > And another ping exactly a year later :)
> I think we could "fix" this false positive with the patch below
> (untested), but it's ugly and doesn't add much value.

I could carry that patch myself and not complain about it
any more if there's no intent to produce a "real" fix, but
I doubt that that's really the path we want to take in the
long run.

We'll end up with a bunch of broken paths when enabling
debug, making any sort of debugging slow and useless, which
isn't a desirable result to say the least.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
