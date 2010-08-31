Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 8DBAB6B01F1
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 10:38:58 -0400 (EDT)
Date: Tue, 31 Aug 2010 22:36:49 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] Make is_mem_section_removable more conformable with
 offlining code
Message-ID: <20100831143649.GA31730@localhost>
References: <20100820141400.GD4636@tiehlicka.suse.cz>
 <20100822004232.GA11007@localhost>
 <20100823092246.GA25772@tiehlicka.suse.cz>
 <20100831141942.GA30353@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100831141942.GA30353@localhost>
Sender: owner-linux-mm@kvack.org
To: Michal Hocko <mhocko@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kleen, Andi" <andi.kleen@intel.com>, Haicheng Li <haicheng.li@linux.intel.com>, Christoph Lameter <cl@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mel Gorman <mel@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 31, 2010 at 10:19:42PM +0800, Wu Fengguang wrote:
> On Mon, Aug 23, 2010 at 05:22:46PM +0800, Michal Hocko wrote:
> > On Sun 22-08-10 08:42:32, Wu Fengguang wrote:
> > > Hi Michal,
> > 
> > Hi,
> > 
> > > 
> > > It helps to explain in changelog/code
> > > 
> > > - in what situation a ZONE_MOVABLE will contain !MIGRATE_MOVABLE
> > >   pages? 
> > 
> > page can be MIGRATE_RESERVE IIUC.
> 
> Yup, it may also be set to MIGRATE_ISOLATE by soft_offline_page().

Ah a non-movable page allocation could fall back into the movable
zone. See __rmqueue_fallback() and the fallbacks[][] array. So the

        if (type != MIGRATE_MOVABLE && !pageblock_free(page))

check in is_mem_section_removable() is correct. It is
set_migratetype_isolate() that should be fixed to use the same check.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
