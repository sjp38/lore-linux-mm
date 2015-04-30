Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 44E876B0032
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 08:03:57 -0400 (EDT)
Received: by widdi4 with SMTP id di4so16514010wid.0
        for <linux-mm@kvack.org>; Thu, 30 Apr 2015 05:03:56 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id c10si3588319wja.204.2015.04.30.05.03.55
        for <linux-mm@kvack.org>;
        Thu, 30 Apr 2015 05:03:55 -0700 (PDT)
Date: Thu, 30 Apr 2015 15:03:44 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv5 17/28] mm, thp: remove infrastructure for handling
 splitting PMDs
Message-ID: <20150430120344.GC15874@node.dhcp.inet.fi>
References: <1429823043-157133-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1429823043-157133-18-git-send-email-kirill.shutemov@linux.intel.com>
 <55410355.8090707@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55410355.8090707@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Apr 29, 2015 at 06:14:13PM +0200, Jerome Marchand wrote:
> On 04/23/2015 11:03 PM, Kirill A. Shutemov wrote:
> > With new refcounting we don't need to mark PMDs splitting. Let's drop code
> > to handle this.
> > 
> > Arch-specific code will removed separately.
> 
> This series only removed code from x86 arch. Does that mean other arches
> patches will come later?

Initially I hoped it will be just trivial dropping dead code and can be
done later. But we need to do a bit more at least for powerpc (see
patchset by Aneesh). I will need to check other arch's code.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
