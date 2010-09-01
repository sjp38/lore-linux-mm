Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id C570D6B0047
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 08:41:45 -0400 (EDT)
Date: Wed, 1 Sep 2010 14:41:38 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] Make is_mem_section_removable more conformable with
 offlining code
Message-ID: <20100901124138.GD6663@tiehlicka.suse.cz>
References: <20100820141400.GD4636@tiehlicka.suse.cz>
 <20100822004232.GA11007@localhost>
 <20100823092246.GA25772@tiehlicka.suse.cz>
 <20100831141942.GA30353@localhost>
 <20100901121951.GC6663@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100901121951.GC6663@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kleen, Andi" <andi.kleen@intel.com>, Haicheng Li <haicheng.li@linux.intel.com>, Christoph Lameter <cl@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mel Gorman <mel@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed 01-09-10 14:19:51, Michal Hocko wrote:
> On Tue 31-08-10 22:19:42, Wu Fengguang wrote:
> > On Mon, Aug 23, 2010 at 05:22:46PM +0800, Michal Hocko wrote:
> > > On Sun 22-08-10 08:42:32, Wu Fengguang wrote:
> > > > Hi Michal,
> > > 
> > > Hi,
> > > 
> > > > 
> > > > It helps to explain in changelog/code
> > > > 
> > > > - in what situation a ZONE_MOVABLE will contain !MIGRATE_MOVABLE
> > > >   pages? 
> > > 
> > > page can be MIGRATE_RESERVE IIUC.
> > 
> > Yup, it may also be set to MIGRATE_ISOLATE by soft_offline_page().
> 
> Doesn't it make sense to check for !MIGRATE_UNMOVABLE then?

Something like the following patch.
