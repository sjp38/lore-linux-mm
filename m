Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B0819830F1
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 09:45:01 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id l4so41978661wml.0
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 06:45:01 -0700 (PDT)
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com. [74.125.82.44])
        by mx.google.com with ESMTPS id p13si11871494wmd.97.2016.08.29.06.45.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Aug 2016 06:45:00 -0700 (PDT)
Received: by mail-wm0-f44.google.com with SMTP id i5so92957330wmg.0
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 06:45:00 -0700 (PDT)
Date: Mon, 29 Aug 2016 15:44:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: what is the purpose of SLAB and SLUB
Message-ID: <20160829134458.GD2968@dhcp22.suse.cz>
References: <1471458050-29622-1-git-send-email-aruna.ramakrishna@oracle.com>
 <20160818115218.GJ30162@dhcp22.suse.cz>
 <20160823021303.GB17039@js1304-P5Q-DELUXE>
 <20160823153807.GN23577@dhcp22.suse.cz>
 <20160824082057.GT2693@suse.de>
 <alpine.DEB.2.20.1608242240460.1837@east.gentwo.org>
 <20160825100707.GU2693@suse.de>
 <alpine.DEB.2.20.1608251451070.10766@east.gentwo.org>
 <87h9a71clo.fsf@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87h9a71clo.fsf@tassilo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Aruna Ramakrishna <aruna.ramakrishna@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Kravetz <mike.kravetz@oracle.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Jiri Slaby <jslaby@suse.cz>

On Fri 26-08-16 13:47:47, Andi Kleen wrote:
> Christoph Lameter <cl@linux.com> writes:
> >
> >> If you want to rework the VM to use a larger fundamental unit, track
> >> sub-units where required and deal with the internal fragmentation issues
> >> then by all means go ahead and deal with it.
> >
> > Hmmm... The time problem is always there. Tried various approaches over
> > the last decade. Could be a massive project. We really would need a
> > larger group of developers to effectively do this.
> 
> I'm surprised that compactions is not able to fix the fragmentation.
> Is the problem that there are too many non movable objects around?

Compaction can certainly help and the more we are proactive in that
direction the better. Vlastimil has already done a first step in that
direction and we a have a dedicated kcompactd kernel thread for that
purpose. But I guess what Mel had in mind is the latency of higher
order pages which is inherently higher with the current page allocator
no matter how well the compaction works. There are other changes, mostly
for the fast path, needed to make higher order pages less of a second
citizen.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
