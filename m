Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 1ACA26B02DF
	for <linux-mm@kvack.org>; Fri,  3 May 2013 11:34:53 -0400 (EDT)
Date: Fri, 3 May 2013 17:34:50 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: OOM-killer and strange RSS value in 3.9-rc7
Message-ID: <20130503153450.GA18709@dhcp22.suse.cz>
References: <0000013e427023d7-9456c313-8654-420c-b85a-cb79cc3c4ffc-000000@email.amazonses.com>
 <20130426062436.GB4441@localhost.localdomain>
 <0000013e46cba821-d5c54c99-3b5c-4669-9a54-9fb8f4ee516f-000000@email.amazonses.com>
 <20130427112418.GC4441@localhost.localdomain>
 <0000013e5645b356-09aa6796-0a95-40f1-8ec5-6e2e3d0c434f-000000@email.amazonses.com>
 <20130429145711.GC1172@dhcp22.suse.cz>
 <20130502105637.GD4441@localhost.localdomain>
 <0000013e65cb32b3-047cd2d6-dfc8-41d2-a792-9b398f9a1baf-000000@email.amazonses.com>
 <20130503030345.GE4441@localhost.localdomain>
 <0000013e6aff6f95-b8fa366e-51a5-4632-962e-1b990520f5a8-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0000013e6aff6f95-b8fa366e-51a5-4632-962e-1b990520f5a8-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Han Pingtian <hanpt@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, penberg@kernel.org, rientjes@google.com, linux-mm@kvack.org

On Fri 03-05-13 15:25:25, Christoph Lameter wrote:
> On Fri, 3 May 2013, Han Pingtian wrote:
> 
> > On Thu, May 02, 2013 at 03:10:15PM +0000, Christoph Lameter wrote:
> > > On Thu, 2 May 2013, Han Pingtian wrote:
> > >
> > > > Looks like "ibmvscsi" + "slub" can trigger this problem.
> > >
> > > And the next merge of the slab-next tree will also cause SLAB to trigger
> > > this issue. I would like to have this fixes. The slab allocator purpose is
> > > to servr objects that are a fraction of a page and not objects that are
> > > larger than the maximum allowed sizes of the page allocator.
> >
> > So the problem is in memory management code, not in ibmvscis? And looks
> > like there is a fix already?
> 
> Both should be fixed.

Could you point to the specific commit(s), please?

> Making requests for large amounts of memory from an allocator that is
> supposed to hand out fraction of a page does not make sense.

AFAIR there were lots of objects in size-512 as well.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
