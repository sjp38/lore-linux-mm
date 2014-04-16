From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] thp: close race between split and zap huge pages
Date: Wed, 16 Apr 2014 11:42:36 +0300
Message-ID: <20140416084236.GA23247@node.dhcp.inet.fi>
References: <1397598536-25074-1-git-send-email-kirill.shutemov@linux.intel.com>
 <CAA_GA1ecVD2GuxvPqBhGKdUfMeBJU+m-i5XeSzMmDXy=QncLqA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAA_GA1ecVD2GuxvPqBhGKdUfMeBJU+m-i5XeSzMmDXy=QncLqA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Bob Liu <lliubbo@gmail.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Sasha Levin <sasha.levin@oracle.com>, Dave Jones <davej@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

On Wed, Apr 16, 2014 at 07:52:29AM +0800, Bob Liu wrote:
> >         *ptl = pmd_lock(mm, pmd);
> > -       if (pmd_none(*pmd))
> > +       if (!pmd_present(*pmd))
> >                 goto unlock;
> 
> But I didn't get the idea why pmd_none() was removed?

!pmd_present(*pmd) is weaker check then pmd_none(*pmd). I mean if
pmd_none(*pmd) is true then pmd_present(*pmd) is always false.
Correct me if I'm wrong.

-- 
 Kirill A. Shutemov
