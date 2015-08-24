From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: mmap: Check all failures before set values
Date: Mon, 24 Aug 2015 15:57:16 +0200
Message-ID: <20150824135716.GO17078@dhcp22.suse.cz>
References: <1440349179-18304-1-git-send-email-gang.chen.5i5j@qq.com>
 <20150824113212.GL17078@dhcp22.suse.cz>
 <55DB1D94.3050404@hotmail.com>
 <COL130-W527FEAA0BEC780957B6B18B9620@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <COL130-W527FEAA0BEC780957B6B18B9620@phx.gbl>
Sender: linux-kernel-owner@vger.kernel.org
To: Chen Gang <xili_gchen_5257@hotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "riel@redhat.com" <riel@redhat.com>, "sasha.levin@oracle.com" <sasha.levin@oracle.com>, "gang.chen.5i5j@gmail.com" <gang.chen.5i5j@gmail.com>, Linux Memory <linux-mm@kvack.org>, kernel mailing list <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

On Mon 24-08-15 21:34:25, Chen Gang wrote:
> On 8/24/15 19:32, Michal Hocko wrote:
> > On Mon 24-08-15 00:59:39, gang.chen.5i5j@qq.com wrote:
> >>> From: Chen Gang <gang.chen.5i5j@gmail.com>
> >>>
> >>> When failure occurs and return, vma->vm_pgoff is already set, which is
> >>> not a good idea.
> > Why? The vma is not inserted anywhere and the failure path is supposed
> > to simply free the vma.
> >
> 
> It can save several insns when failure occurs.

The failure is quite unlikely, though.

> It is always a little better to let the external function suppose fewer
> callers' behalf.

I am sorry but I do not understand what you are saying here.

> It can save the code readers' (especially new readers') time resource
> to avoid to analyze why set 'vma->vm_pgoff' before checking '-ENOMEM'
> (may it cause issue? or is 'vm_pgoff' related with the next checking?).

Then your changelog should be specific about these reasons. "not a good
idea" is definitely not a good justification for a patch. I am not
saying the patch is incorrect I just do not sure it is worth it. The
code is marginally better. But others might think otherwise. The
changelog needs some more work for sure.
-- 
Michal Hocko
SUSE Labs
