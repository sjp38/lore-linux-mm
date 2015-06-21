Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 13D986B006E
	for <linux-mm@kvack.org>; Sun, 21 Jun 2015 15:20:21 -0400 (EDT)
Received: by wiga1 with SMTP id a1so58930214wig.0
        for <linux-mm@kvack.org>; Sun, 21 Jun 2015 12:20:20 -0700 (PDT)
Received: from johanna4.rokki.sonera.fi (mta-out1.inet.fi. [62.71.2.230])
        by mx.google.com with ESMTP id da6si15944813wib.118.2015.06.21.12.20.19
        for <linux-mm@kvack.org>;
        Sun, 21 Jun 2015 12:20:19 -0700 (PDT)
Date: Sun, 21 Jun 2015 22:19:58 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC v2 3/3] mm: make swapin readahead to improve thp collapse
 rate
Message-ID: <20150621191958.GA6766@node.dhcp.inet.fi>
References: <1434799686-7929-1-git-send-email-ebru.akagunduz@gmail.com>
 <1434799686-7929-4-git-send-email-ebru.akagunduz@gmail.com>
 <20150621181131.GA6710@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150621181131.GA6710@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, riel@redhat.com, iamjoonsoo.kim@lge.com, xiexiuqi@huawei.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hughd@google.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, raindel@mellanox.com

On Sun, Jun 21, 2015 at 09:11:31PM +0300, Kirill A. Shutemov wrote:
> On Sat, Jun 20, 2015 at 02:28:06PM +0300, Ebru Akagunduz wrote:
> > +			/* pte is unmapped now, we need to map it */
> > +			pte = pte_offset_map(pmd, _address);
> 
> No, it's within the same pte page table. It should be mapped with
> pte_offset_map() above.

Ahh.. do_swap_page() will unmap it. Probably worth rewording the comment.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
