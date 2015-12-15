Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id A30756B0254
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 06:53:48 -0500 (EST)
Received: by mail-pf0-f178.google.com with SMTP id u66so3671320pfb.3
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 03:53:48 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id wi4si1462201pab.220.2015.12.15.03.53.47
        for <linux-mm@kvack.org>;
        Tue, 15 Dec 2015 03:53:48 -0800 (PST)
Date: Tue, 15 Dec 2015 13:53:42 +0200
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [RFC] mm: change find_vma() function
Message-ID: <20151215115342.GB75130@black.fi.intel.com>
References: <1450090945-4020-1-git-send-email-yalin.wang2010@gmail.com>
 <20151214121107.GB4201@node.shutemov.name>
 <20151214175509.GA25681@redhat.com>
 <20151214211132.GA7390@node.shutemov.name>
 <5603C6DF-DDA5-4B57-9608-63335282B966@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <5603C6DF-DDA5-4B57-9608-63335282B966@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yalin wang <yalin.wang2010@gmail.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Oleg Nesterov <oleg@redhat.com>, akpm@linux-foundation.org, gang.chen.5i5j@gmail.com, mhocko@suse.com, kwapulinski.piotr@gmail.com, aarcange@redhat.com, dcashman@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Dec 15, 2015 at 02:41:21PM +0800, yalin wang wrote:
> > On Dec 15, 2015, at 05:11, Kirill A. Shutemov <kirill@shutemov.name> wrote:
> > Anyway, I don't think it's possible to gain anything measurable from this
> > optimization.
> > 
> the advantage is that if addr dona??t belong to any vma, we dona??t need loop all vma,
> we can break earlier if we found the most closest vma which vma->end_add > addr,

Do you have any workload which can demonstrate the advantage?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
