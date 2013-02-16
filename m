From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] staging: zcache: add TODO file
Date: Sat, 16 Feb 2013 08:29:02 +0800
Message-ID: <31481.5731057481$1360975359@news.gmane.org>
References: <1360779186-17189-1-git-send-email-dan.magenheimer@oracle.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <1360779186-17189-1-git-send-email-dan.magenheimer@oracle.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/devel/>
List-Post: <mailto:devel@linuxdriverproject.org>
List-Help: <mailto:devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: devel-bounces@linuxdriverproject.org
Sender: "devel" <devel-bounces@linuxdriverproject.org>
Cc: sjenning@linux.vnet.ibm.com, dan.magenheimer@oracle.com, konrad.wilk@oracle.com, gregkh@linuxfoundation.org, minchan@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@linuxdriverproject.org, ngupta@vflare.org
List-Id: linux-mm.kvack.org

Hi Dan,
On Wed, Feb 13, 2013 at 10:13:06AM -0800, Dan Magenheimer wrote:
>Add zcache TODO file
>
>Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
>---
> drivers/staging/zcache/TODO |   69 +++++++++++++++++++++++++++++++++++++++++++
> 1 files changed, 69 insertions(+), 0 deletions(-)
> create mode 100644 drivers/staging/zcache/TODO
>
>diff --git a/drivers/staging/zcache/TODO b/drivers/staging/zcache/TODO
>new file mode 100644
>index 0000000..c1e26d4
>--- /dev/null
>+++ b/drivers/staging/zcache/TODO
>@@ -0,0 +1,69 @@
>+
>+** ZCACHE PLAN FOR PROMOTION FROM STAGING **
>+

Great plan! :)

>+Last updated: Feb 13, 2013
>+
>+PLAN STEPS
>+
>+1. merge zcache and ramster to eliminate horrible code duplication
>+2. converge on a predictable, writeback-capable allocator
>+3. use debugfs instead of sysfs (per akpm feedback in 2011)
>+4. zcache side of cleancache/mm WasActive patch
>+5. zcache side of frontswap exclusive gets
>+6. zcache must be able to writeback to physical swap disk
>+    (per Andrea Arcangeli feedback in 2011)
>+7. implement adequate policy for writeback
>+8. frontswap/cleancache work to allow zcache to be loaded
>+    as a module
>+9. get core mm developer to review
>+10. incorporate feedback from review
>+11. get review/acks from 1-2 additional mm developers
>+12. incorporate any feedback from additional mm reviews
>+13. propose location/file-naming in mm tree
>+14. repeat 9-13 as necessary until akpm is happy and merges
>+
>+STATUS/OWNERSHIP
>+
>+1. DONE as part of "new" zcache; in staging/zcache for 3.9
>+2. DONE as part of "new" zcache (cf zbud.[ch]); in staging/zcache for 3.9
>+    (this was the core of the zcache1 vs zcache2 flail)
>+3. DONE as part of "new" zcache; in staging/zcache for 3.9
>+4. DONE (w/caveats) as part of "new" zcache; per cleancache performance
>+    feedback see https://lkml.org/lkml/2011/8/17/351, in
>+    staging/zcache for 3.9; dependent on proposed mm patch, see
>+    https://lkml.org/lkml/2012/1/25/300 
>+5. DONE as part of "new" zcache; performance tuning only,
>+    in staging/zcache for 3.9; dependent on frontswap patch
>+    merged in 3.7 (33c2a174)
>+6. DONE (w/caveats), prototyped as part of "new" zcache, had
>+    bad memory leak; reimplemented to use sjennings clever tricks
>+    and proposed mm patches with new version in staging/zcache
>+    for 3.9, see https://lkml.org/lkml/2013/2/6/437;
>+7. PROTOTYPED as part of "new" zcache; in staging/zcache for 3.9;
>+    needs more review (plan to discuss at LSF/MM 2013)
>+8. IN PROGRESS; owned by Konrad Wilk; v2 recently posted
>+   http://lkml.org/lkml/2013/2/1/542
>+9. IN PROGRESS; owned by Konrad Wilk; Mel Gorman provided
>+   great feedback in August 2012 (unfortunately of "old"
>+   zcache)
>+10. Konrad posted series of fixes (that now need rebasing)
>+    https://lkml.org/lkml/2013/2/1/566 
>+11. NOT DONE; owned by Konrad Wilk
>+12. TBD (depends on quantity of feedback)
>+13. PROPOSED; one suggestion proposed by Dan; needs more ideas/feedback
>+14. TBD (depends on feedback)
>+
>+WHO NEEDS TO AGREE
>+
>+Not sure.  Seth Jennings is now pursuing a separate but semi-parallel
>+track.  Akpm clearly has to approve for any mm merge to happen.  Minchan
>+Kim has interest but may be happy if/when zram is merged into mm.  Konrad
>+Wilk may be maintainer if akpm decides compression is maintainable
>+separately from the rest of mm.  (More LSF/MM 2013 discussion.)
>+
>+ZCACHE FUTURE NEW FUNCTIONALITY
>+
>+A. Support zsmalloc as an alternative high-density allocator
>+    (See https://lkml.org/lkml/2013/1/23/511)
>+B. Support zero-filled pages more efficiently

I'm interested in and will try it if no guys focus on it.

Regards,
Wanpeng Li 

>+C. Possibly support three zbuds per pageframe when space allows
>-- 
>1.7.1
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
