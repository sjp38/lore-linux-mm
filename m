Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id 2BDFE6B00D1
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 17:21:09 -0400 (EDT)
Received: by mail-qc0-f180.google.com with SMTP id i17so3103183qcy.25
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 14:21:08 -0700 (PDT)
Received: from qmta10.emeryville.ca.mail.comcast.net (qmta10.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:17])
        by mx.google.com with ESMTP id 38si28285570qgr.2.2014.06.10.14.21.07
        for <linux-mm@kvack.org>;
        Tue, 10 Jun 2014 14:21:08 -0700 (PDT)
Date: Tue, 10 Jun 2014 16:21:04 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [PATCH, RFC 00/10] THP refcounting redesign
In-Reply-To: <20140610204640.GA9594@node.dhcp.inet.fi>
Message-ID: <alpine.DEB.2.10.1406101616520.20047@gentwo.org>
References: <1402329861-7037-1-git-send-email-kirill.shutemov@linux.intel.com> <alpine.DEB.2.10.1406101518510.19364@gentwo.org> <20140610204640.GA9594@node.dhcp.inet.fi>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 10 Jun 2014, Kirill A. Shutemov wrote:

> Could you elaborate here?

The page migration scheme works by locking and also putting in a fake pte
to ensure that any accesses cause a page fault which will then block.
In the THP case we would need a fake pmd.

That allows effectively to force all accesses to the page to stop. Then
you do the page migration (and you could do the splitting etc) and then
replace the fake pmd/pte with real ones.

See the page migration code.

> Agreed. The patchset drops tail page refcounting.

Great. Step in the right diretion.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
