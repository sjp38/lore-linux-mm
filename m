Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 389E16B005A
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 12:21:01 -0400 (EDT)
Received: by qady1 with SMTP id y1so717292qad.14
        for <linux-mm@kvack.org>; Thu, 23 Aug 2012 09:21:00 -0700 (PDT)
Date: Thu, 23 Aug 2012 18:20:54 +0200
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: mmotm 2012-08-13-16-55 uploaded
Message-ID: <20120823162050.GB19305@somewhere.redhat.com>
References: <20120813235651.00A13100047@wpzn3.hot.corp.google.com>
 <20120814105349.GA6905@dhcp22.suse.cz>
 <502A4410.6070201@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <502A4410.6070201@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Michal Hocko <mhocko@suse.cz>, akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org

On Tue, Aug 14, 2012 at 04:26:56PM +0400, Glauber Costa wrote:
> On 08/14/2012 02:53 PM, Michal Hocko wrote:
> > On Mon 13-08-12 16:56:50, Andrew Morton wrote:
> >> > The mm-of-the-moment snapshot 2012-08-13-16-55 has been uploaded to
> >> > 
> >> >    http://www.ozlabs.org/~akpm/mmotm/
> > -mm git tree has been updated as well. You can find the tree at
> > https://github.com/mstsxfx/memcg-devel.git since-3.5
> > 
> > tagged as mmotm-2012-08-13-16-55
> > 
> 
> On top of this tree, people following the kmemcg development may also
> want to checkout
> 
>    git://github.com/glommer/linux.git memcg-3.5/kmemcg-stack
> 
> A branch called memcg-3.5/kmemcg-slab is also available with the slab
> changes ontop.

I tested it successfully to stop a forkbomb in a container.
One may need the following fix as well: http://marc.info/?l=linux-kernel&m=134573636430031&w=2

Andrew, others, what is your opinion on this patchset?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
