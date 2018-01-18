Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id C9E9F6B0260
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 09:45:18 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id y13so15744987wrb.17
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 06:45:18 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t23sor3590588edb.49.2018.01.18.06.45.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Jan 2018 06:45:17 -0800 (PST)
Date: Thu, 18 Jan 2018 17:45:14 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [mm 4.15-rc8] Random oopses under memory pressure.
Message-ID: <20180118144514.njr5xdagtwzpzep6@node.shutemov.name>
References: <201801160115.w0G1FOIG057203@www262.sakura.ne.jp>
 <CA+55aFxOn5n4O2JNaivi8rhDmeFhTQxEHD4xE33J9xOrFu=7kQ@mail.gmail.com>
 <201801170233.JDG21842.OFOJMQSHtOFFLV@I-love.SAKURA.ne.jp>
 <CA+55aFyxyjN0Mqnz66B4a0R+uR8DdfxdMhcg5rJVi8LwnpSRfA@mail.gmail.com>
 <201801172008.CHH39543.FFtMHOOVSQJLFO@I-love.SAKURA.ne.jp>
 <201801181712.BFD13039.LtHOSVMFJQFOFO@I-love.SAKURA.ne.jp>
 <20180118122550.2lhsjx7hg5drcjo4@node.shutemov.name>
 <20180118131210.456oyh6fw4scwv53@node.shutemov.name>
 <4a6681a7-5ed6-ad9c-5d1d-73f1fcc82f3d@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4a6681a7-5ed6-ad9c-5d1d-73f1fcc82f3d@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, torvalds@linux-foundation.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, tony.luck@intel.com, vbabka@suse.cz, mhocko@kernel.org, aarcange@redhat.com, hillf.zj@alibaba-inc.com, hughd@google.com, oleg@redhat.com, peterz@infradead.org, riel@redhat.com, srikar@linux.vnet.ibm.com, vdavydov.dev@gmail.com, mingo@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org

On Thu, Jan 18, 2018 at 06:38:10AM -0800, Dave Hansen wrote:
> On 01/18/2018 05:12 AM, Kirill A. Shutemov wrote:
> > -		if (pte_page(*pvmw->pte) - pvmw->page >=
> > -				hpage_nr_pages(pvmw->page)) {
> 
> Is ->pte guaranteed to map a page which is within the same section as
> pvmw->page?  Otherwise, with sparsemem (non-vmemmap), the pointer
> arithmetic won't work.

No, it's not guaranteed. It can be arbitrary page.

The arithmetic won't work because they are different "memory objects"?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
