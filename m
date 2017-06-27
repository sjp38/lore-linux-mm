Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8895F6B03A8
	for <linux-mm@kvack.org>; Tue, 27 Jun 2017 12:41:56 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 12so5951331wmn.1
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 09:41:56 -0700 (PDT)
Received: from mail-wm0-x22d.google.com (mail-wm0-x22d.google.com. [2a00:1450:400c:c09::22d])
        by mx.google.com with ESMTPS id j61si5906147wrj.331.2017.06.27.09.41.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jun 2017 09:41:55 -0700 (PDT)
Received: by mail-wm0-x22d.google.com with SMTP id w126so29963291wme.0
        for <linux-mm@kvack.org>; Tue, 27 Jun 2017 09:41:55 -0700 (PDT)
Date: Tue, 27 Jun 2017 19:41:52 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: next-20170620 BUG in do_page_fault / do_huge_pmd_wp_page
Message-ID: <20170627164152.w5awvgpyppex6oa2@node.shutemov.name>
References: <20815.1498188418@turing-police.cc.vt.edu>
 <CA+G9fYvpDRb2VLpXC1yiYZGbqO23dMAix4Ra2+8vhzFoc=MdZQ@mail.gmail.com>
 <dde0cb3d-ffa2-f90d-fe21-26cf5dd9383c@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <dde0cb3d-ffa2-f90d-fe21-26cf5dd9383c@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Naresh Kamboju <naresh.kamboju@linaro.org>, valdis.kletnieks@vt.edu
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Jun 27, 2017 at 09:13:31AM +0200, Vlastimil Babka wrote:
> +CC Kirill, those 512 numbers smell like THP related.
> 
> On 06/23/2017 07:48 AM, Naresh Kamboju wrote:
> > Hi Valdis,
> > 
> > On 23 June 2017 at 08:56,  <valdis.kletnieks@vt.edu> wrote:
> >> Saw this at boot of next-20170620.  Not sure how I managed to hit 4 BUG in a row...
> >>
> >> Looked in 'git log -- mm/' but not seeing anything blatantly obvious.
> >>
> >> This ringing any bells?  I'm not in a position to recreate or bisect this until
> >> the weekend.
> >>
> >> [  315.409076] BUG: Bad rss-counter state mm:ffff8a223deb4640 idx:0 val:-512
> >> [  315.412889] BUG: Bad rss-counter state mm:ffff8a223deb4640 idx:1 val:512
> >> [  315.416694] BUG: non-zero nr_ptes on freeing mm: 1
> >> [  315.436098] BUG: Bad page state in process gdm  pfn:3e8400
> >> [  315.439802] page:ffffe8af0fa10000 count:-1 mapcount:0 mapping:          (null) index:0x1

Could you check this helps:

http://lkml.kernel.org/r/20170627163734.6js4jkwkwlz6xwir@black.fi.intel.com

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
