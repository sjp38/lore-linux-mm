Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 78B4A6B0255
	for <linux-mm@kvack.org>; Fri,  4 Mar 2016 17:53:13 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id l68so38381435wml.0
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 14:53:13 -0800 (PST)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id t82si1230822wmg.117.2016.03.04.14.53.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Mar 2016 14:53:12 -0800 (PST)
Received: by mail-wm0-x22f.google.com with SMTP id l68so8694973wml.1
        for <linux-mm@kvack.org>; Fri, 04 Mar 2016 14:53:12 -0800 (PST)
Date: Sat, 5 Mar 2016 01:53:10 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv3 00/29] huge tmpfs implementation using compound pages
Message-ID: <20160304225310.GB12498@node.shutemov.name>
References: <1457023939-98083-1-git-send-email-kirill.shutemov@linux.intel.com>
 <56D90CF0.9070500@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56D90CF0.9070500@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Mar 03, 2016 at 11:20:00PM -0500, Sasha Levin wrote:
> On 03/03/2016 11:51 AM, Kirill A. Shutemov wrote:
> > I consider it feature complete for initial step into upstream. I'll focus
> > on validation now. I work with Sasha on that.
> 
> Hey Kirill,
> 
> I see the following two (separate) issues. I haven't hit them ever before, so
> I suspect that while they seem unrelated, they are somehow caused by this series.

As I said in private, I failed to derive any useful information from these
crashes. I don't see anything related to the patchset.

Of course, it can be related to the patchset, but there is not enough
information to connect the dots.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
