Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 36FB86B0005
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 04:36:20 -0500 (EST)
Received: by mail-pf0-f181.google.com with SMTP id q63so102167824pfb.0
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 01:36:20 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id sm4si50068567pac.245.2016.02.16.01.36.19
        for <linux-mm@kvack.org>;
        Tue, 16 Feb 2016 01:36:19 -0800 (PST)
Date: Tue, 16 Feb 2016 12:36:14 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv2 02/28] rmap: introduce rmap_walk_locked()
Message-ID: <20160216093614.GA46557@black.fi.intel.com>
References: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1455200516-132137-3-git-send-email-kirill.shutemov@linux.intel.com>
 <87y4ardqqv.fsf@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87y4ardqqv.fsf@tassilo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Feb 11, 2016 at 10:52:08AM -0800, Andi Kleen wrote:
> "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:
> 
> > rmap_walk_locked() is the same as rmap_walk(), but caller takes care
> > about relevant rmap lock.
> >
> > It's preparation to switch THP splitting from custom rmap walk in
> > freeze_page()/unfreeze_page() to generic one.
> 
> Would be better to move all locking into the callers, with an
> appropiate helper for users who don't want to deal with it.
> Conditional locking based on flags is always tricky.

Hm. That's kinda tricky for rmap_walk_ksm()..

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
