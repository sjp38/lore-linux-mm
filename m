Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id C42AD6B0032
	for <linux-mm@kvack.org>; Thu, 11 Dec 2014 20:59:32 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id rd3so6248489pab.28
        for <linux-mm@kvack.org>; Thu, 11 Dec 2014 17:59:32 -0800 (PST)
Received: from cnbjrel01.sonyericsson.com (cnbjrel01.sonyericsson.com. [219.141.167.165])
        by mx.google.com with ESMTPS id fk9si78575pab.185.2014.12.11.17.59.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 11 Dec 2014 17:59:31 -0800 (PST)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Fri, 12 Dec 2014 09:59:15 +0800
Subject: RE: [RFC] mm:fix zero_page huge_zero_page rss/pss statistic
Message-ID: <35FD53F367049845BC99AC72306C23D103E688B31406@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103E688B313EE@CNBJMBX05.corpusers.net>
 <CALYGNiOuBKz8shHSrFCp0BT5AV6XkNOCHj+LJedQQ-2YdZtM7w@mail.gmail.com>
 <35FD53F367049845BC99AC72306C23D103E688B313F2@CNBJMBX05.corpusers.net>
 <20141205143134.37139da2208c654a0d3cd942@linux-foundation.org>
 <35FD53F367049845BC99AC72306C23D103E688B313F4@CNBJMBX05.corpusers.net>
 <20141208114601.GA28846@node.dhcp.inet.fi>
 <35FD53F367049845BC99AC72306C23D103E688B313FB@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E688B31403@CNBJMBX05.corpusers.net>
 <20141210110556.GA10630@node.dhcp.inet.fi>
In-Reply-To: <20141210110556.GA10630@node.dhcp.inet.fi>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "'Kirill A. Shutemov'" <kirill@shutemov.name>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Konstantin Khlebnikov' <koct9i@gmail.com>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>, "'n-horiguchi@ah.jp.nec.com'" <n-horiguchi@ah.jp.nec.com>, "'oleg@redhat.com'" <oleg@redhat.com>, "'gorcunov@openvz.org'" <gorcunov@openvz.org>, "'pfeiner@google.com'" <pfeiner@google.com>

> -----Original Message-----
> From: Kirill A. Shutemov [mailto:kirill@shutemov.name]
> Sent: Wednesday, December 10, 2014 7:06 PM
> To: Wang, Yalin
> Cc: 'Andrew Morton'; 'Konstantin Khlebnikov'; 'linux-
> kernel@vger.kernel.org'; 'linux-mm@kvack.org'; 'linux-arm-
> kernel@lists.infradead.org'; 'n-horiguchi@ah.jp.nec.com'; 'oleg@redhat.co=
m';
> 'gorcunov@openvz.org'; 'pfeiner@google.com'
> Subject: Re: [RFC] mm:fix zero_page huge_zero_page rss/pss statistic
>=20
> On Wed, Dec 10, 2014 at 03:22:21PM +0800, Wang, Yalin wrote:
> > smaps_pte_entry() doesn't ignore zero_huge_page, but it ignore
> > zero_page, because vm_normal_page() will ignore it. We remove
> > vm_normal_page() call, because walk_page_range() have ignore VM_PFNMAP
> > vma maps, it's safe to just use pfn_valid(), so that we can also
> > consider zero_page to be a valid page.
>=20
> We fixed huge zero page accounting in smaps recentely. See mm tree.
>=20
Hi=20
I can't find the git, could you send me a link?
Thank you !

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
