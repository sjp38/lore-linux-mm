From: Artem Savkov <artem.savkov@gmail.com>
Subject: Re: [PATCHv12 14/37] futex, thp: remove special case for THP in
 get_futex_key
Date: Thu, 22 Oct 2015 12:33:44 +0200
Message-ID: <20151022103344.GB29487@littlebeast.usersys.redhat.com>
References: <1444145044-72349-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1444145044-72349-15-git-send-email-kirill.shutemov@linux.intel.com>
 <20151022082433.GA29487@littlebeast.usersys.redhat.com>
 <20151022094945.GE10597@node.shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151022094945.GE10597@node.shutemov.name>
Sender: linux-kernel-owner@vger.kernel.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

On Thu, Oct 22, 2015 at 12:49:45PM +0300, Kirill A. Shutemov wrote:
> On Thu, Oct 22, 2015 at 10:24:33AM +0200, Artem Savkov wrote:
> > On Tue, Oct 06, 2015 at 06:23:41PM +0300, Kirill A. Shutemov wrote:
> > > With new THP refcounting, we don't need tricks to stabilize huge page.
> > > If we've got reference to tail page, it can't split under us.
> > > 
> > > This patch effectively reverts a5b338f2b0b1.
> > > 
> > > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > > Tested-by: Sasha Levin <sasha.levin@oracle.com>
> > > Tested-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> > > Acked-by: Jerome Marchand <jmarchan@redhat.com>
> > > ---
> > >  kernel/futex.c | 61 ++++++++++++----------------------------------------------
> > >  1 file changed, 12 insertions(+), 49 deletions(-)
> > 
> > This patch breaks compound page futexes with the following panic:
>
> Thanks for report. Patch below fixes the issue for me.
> Could you test it as well?
> 
Yep, this patch does fix the problem for me as well.

-- 
Regards,
  Artem
