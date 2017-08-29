Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8B5DD6B025F
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 10:14:37 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id a2so6278486pfj.2
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 07:14:37 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id z28si2482034pgc.252.2017.08.29.07.14.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Aug 2017 07:14:36 -0700 (PDT)
Message-ID: <1504015793.5001.58.camel@linux.intel.com>
Subject: Re: [Intel-gfx] [PATCH 01/23] mm/shmem: introduce
 shmem_file_setup_with_mnt
From: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Date: Tue, 29 Aug 2017 17:09:53 +0300
In-Reply-To: <20170825134914.50a2433a5f28ba6ac0ec708d@linux-foundation.org>
References: <20170821183503.12246-1-matthew.auld@intel.com>
	 <20170821183503.12246-2-matthew.auld@intel.com>
	 <1503480688.6276.4.camel@linux.intel.com>
	 <20170823153456.b3c50e1ec109fd69f672b348@linux-foundation.org>
	 <CAM0jSHMiOKGEEsuxUuX5ayD_eAVByQZaCsE8rs8_XPopxnbcfg@mail.gmail.com>
	 <20170825134914.50a2433a5f28ba6ac0ec708d@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Matthew Auld <matthew.william.auld@gmail.com>, Chris Wilson <chris@chris-wilson.co.uk>
Cc: linux-mm@kvack.org, Intel Graphics Development <intel-gfx@lists.freedesktop.org>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Matthew Auld <matthew.auld@intel.com>, "Kirill A . Shutemov" <kirill@shutemov.name>

On Fri, 2017-08-25 at 13:49 -0700, Andrew Morton wrote:
> On Thu, 24 Aug 2017 13:04:09 +0100 Matthew Auld <matthew.william.auld@gmail.com> wrote:
> 
> > On 23 August 2017 at 23:34, Andrew Morton <akpm@linux-foundation.org> wrote:
> > > On Wed, 23 Aug 2017 12:31:28 +0300 Joonas Lahtinen <joonas.lahtinen@linux.intel.com> wrote:
> > > 
> > > > This patch has been floating around for a while now Acked and without
> > > > further comments. It is blocking us from merging huge page support to
> > > > drm/i915.
> > > > 
> > > > Would you mind merging it, or prodding the right people to get it in?
> > > > 
> > > > Regards, Joonas
> > > > 
> > > > On Mon, 2017-08-21 at 19:34 +0100, Matthew Auld wrote:
> > > > > We are planning to use our own tmpfs mnt in i915 in place of the
> > > > > shm_mnt, such that we can control the mount options, in particular
> > > > > huge=, which we require to support huge-gtt-pages. So rather than roll
> > > > > our own version of __shmem_file_setup, it would be preferred if we could
> > > > > just give shmem our mnt, and let it do the rest.
> > > 
> > > hm, it's a bit odd.  I'm having trouble locating the code which handles
> > > huge=within_size (and any other options?).
> > 
> > See here https://patchwork.freedesktop.org/patch/172771/, currently we
> > only care about huge=within_size.
> > 
> > > What other approaches were considered?
> > 
> > We also tried https://patchwork.freedesktop.org/patch/156528/, where
> > it was suggested that we mount our own tmpfs instance.
> > 
> > Following from that we now have our own tmps mnt mounted with
> > huge=within_size. With this patch we avoid having to roll our own
> > __shmem_file_setup like in
> > https://patchwork.freedesktop.org/patch/163024/.
> > 
> > > Was it not feasible to add i915-specific mount options to
> > > mm/shmem.c (for example?).
> > 
> > Hmm, I think within_size should suffice for our needs.
> 
> hm, ok, well, unless someone can think of something cleaner, please add
> my ack and include it in the appropriate drm tree.

Thanks, I will do that. It'll first get incorporated into drm-tip (
https://cgit.freedesktop.org/drm-tip) once the kselftests are finalized
(now that we know we're not facing third rewrite for core MM
dependency). And eventually into drm-next through a pull request to
Dave Airlie.

Regards, Joonas
-- 
Joonas Lahtinen
Open Source Technology Center
Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
