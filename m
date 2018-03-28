Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7765F6B002B
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 11:44:57 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id e9so2692596ioj.18
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 08:44:57 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0172.hostedemail.com. [216.40.44.172])
        by mx.google.com with ESMTPS id c189-v6si3152734ith.120.2018.03.28.08.44.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Mar 2018 08:44:56 -0700 (PDT)
Message-ID: <1522251891.12357.102.camel@perches.com>
Subject: Re: [PATCH] mm: Use octal not symbolic permissions
From: Joe Perches <joe@perches.com>
Date: Wed, 28 Mar 2018 08:44:51 -0700
In-Reply-To: <20180328130623.GB8976@dhcp22.suse.cz>
References: 
	<2e032ef111eebcd4c5952bae86763b541d373469.1522102887.git.joe@perches.com>
	 <20180328130623.GB8976@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Hugh Dickins <hughd@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 2018-03-28 at 15:06 +0200, Michal Hocko wrote:
> On Mon 26-03-18 15:22:32, Joe Perches wrote:
> > mm/*.c files use symbolic and octal styles for permissions.
> > 
> > Using octal and not symbolic permissions is preferred by many as more
> > readable.
> > 
> > https://lkml.org/lkml/2016/8/2/1945
> > 
> > Prefer the direct use of octal for permissions.
> > 
> > Done using
> > $ scripts/checkpatch.pl -f --types=SYMBOLIC_PERMS --fix-inplace mm/*.c
> > and some typing.
> > 
> > Before:	 $ git grep -P -w "0[0-7]{3,3}" mm | wc -l
> > 44
> > After:	 $ git grep -P -w "0[0-7]{3,3}" mm | wc -l
> > 86
> 

> Ohh, I absolutely detest those symbolic names. I always have to check
> what they actually mean to be sure. Octal representation is quite
> natural to read. So for once I am really happy about such a clean up
> change.
> 
> Btw. something like this should be quite easy to automate via
> coccinelle AFAIU. 

checkpatch is currently better at this, for some
definition of better, than Coccinelle.

Julia and I had a discussion about it awhile ago.
https://lkml.org/lkml/2017/2/4/140

S_<FOO> groupings need to be combined and can
appear in arbitrary order.

Coccinelle would need the same octal addition in
some code path as checkpatch already has.

> > Miscellanea:
> > 
> > o Whitespace neatening around these conversions.
> > 
> > Signed-off-by: Joe Perches <joe@perches.com>
> 
> I hope I haven't overlooked any potential mismatch...

Doubtful as the conversion is completely automated.
