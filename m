Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 20A456B0253
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 12:03:58 -0400 (EDT)
Received: by wicgk12 with SMTP id gk12so13964790wic.1
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 09:03:57 -0700 (PDT)
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com. [209.85.212.169])
        by mx.google.com with ESMTPS id o14si17332068wiw.9.2015.08.27.09.03.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Aug 2015 09:03:57 -0700 (PDT)
Received: by widdq5 with SMTP id dq5so49763316wid.0
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 09:03:56 -0700 (PDT)
Date: Thu, 27 Aug 2015 18:03:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCHv3 4/5] mm: make compound_head() robust
Message-ID: <20150827160355.GI27052@dhcp22.suse.cz>
References: <20150820163643.dd87de0c1a73cb63866b2914@linux-foundation.org>
 <20150821121028.GB12016@node.dhcp.inet.fi>
 <55DC550D.5060501@suse.cz>
 <20150825183354.GC4881@node.dhcp.inet.fi>
 <20150825201113.GK11078@linux.vnet.ibm.com>
 <55DCD434.9000704@suse.cz>
 <20150825211954.GN11078@linux.vnet.ibm.com>
 <alpine.LSU.2.11.1508261104000.1975@eggly.anvils>
 <20150826212916.GG11078@linux.vnet.ibm.com>
 <20150827150917.GF27052@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150827150917.GF27052@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Hugh Dickins <hughd@google.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>

On Thu 27-08-15 17:09:17, Michal Hocko wrote:
[...]
> Btw. Do we need the same think for page::mapping and KSM?

I guess we are safe here because the address for mappings comes from
kmalloc and that aligned properly, right?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
