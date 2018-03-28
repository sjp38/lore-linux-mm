Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id EBC106B0027
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 15:07:31 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id c1so1591803wri.22
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 12:07:31 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i17si3568477wrc.244.2018.03.28.12.07.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 28 Mar 2018 12:07:30 -0700 (PDT)
Date: Wed, 28 Mar 2018 21:07:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Use octal not symbolic permissions
Message-ID: <20180328190726.GR9275@dhcp22.suse.cz>
References: <2e032ef111eebcd4c5952bae86763b541d373469.1522102887.git.joe@perches.com>
 <20180328130623.GB8976@dhcp22.suse.cz>
 <1522251891.12357.102.camel@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1522251891.12357.102.camel@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Hugh Dickins <hughd@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 28-03-18 08:44:51, Joe Perches wrote:
> On Wed, 2018-03-28 at 15:06 +0200, Michal Hocko wrote:
> > On Mon 26-03-18 15:22:32, Joe Perches wrote:
> > > mm/*.c files use symbolic and octal styles for permissions.
> > > 
> > > Using octal and not symbolic permissions is preferred by many as more
> > > readable.
> > > 
> > > https://lkml.org/lkml/2016/8/2/1945
> > > 
> > > Prefer the direct use of octal for permissions.
> > > 
> > > Done using
> > > $ scripts/checkpatch.pl -f --types=SYMBOLIC_PERMS --fix-inplace mm/*.c
[...]
> > I hope I haven't overlooked any potential mismatch...
> 
> Doubtful as the conversion is completely automated.

Ohh, I failed to see --fix-inplace option for checkpatch. I wasn't aware
that checkpatch can perform changes as well.

-- 
Michal Hocko
SUSE Labs
