Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9B90F6B0038
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 02:41:31 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id h65so2186533wmd.7
        for <linux-mm@kvack.org>; Mon, 17 Apr 2017 23:41:31 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r2si19282717wra.223.2017.04.17.23.41.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 17 Apr 2017 23:41:30 -0700 (PDT)
Date: Tue, 18 Apr 2017 08:41:25 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Add additional consistency check
Message-ID: <20170418064124.GA22360@dhcp22.suse.cz>
References: <20170411141956.GP6729@dhcp22.suse.cz>
 <alpine.DEB.2.20.1704111110130.24725@east.gentwo.org>
 <20170411164134.GA21171@dhcp22.suse.cz>
 <alpine.DEB.2.20.1704111254390.25069@east.gentwo.org>
 <20170411183035.GD21171@dhcp22.suse.cz>
 <alpine.DEB.2.20.1704111335540.6544@east.gentwo.org>
 <20170411185555.GE21171@dhcp22.suse.cz>
 <alpine.DEB.2.20.1704111356460.6911@east.gentwo.org>
 <20170411193948.GA29154@dhcp22.suse.cz>
 <alpine.DEB.2.20.1704171021450.28407@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1704171021450.28407@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon 17-04-17 10:22:29, Cristopher Lameter wrote:
> On Tue, 11 Apr 2017, Michal Hocko wrote:
> 
> > On Tue 11-04-17 13:59:44, Cristopher Lameter wrote:
> > > On Tue, 11 Apr 2017, Michal Hocko wrote:
> > >
> > > > I didn't say anything like that. Hence the proposed patch which still
> > > > needs some more thinking and evaluation.
> > >
> > > This patch does not even affect kfree().
> >
> > Ehm? Are we even talking about the same thing? The whole discussion was
> > to catch invalid pointers to _kfree_ and why BUG* is not the best way to
> > handle that.
> 
> The patch does not do that. See my review. Invalid points to kfree are
> already caught with a bug on. See kfree in mm/slub.c

Are you even reading those emails? First of all we are talking about
slab here. Secondly I've already pointed out that the BUG_ON(!PageSlab)
in kmem_freepages is already too late because we do operate on a
potential garbage from invalid page...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
