Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 843766B0035
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 17:33:04 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id ey11so2681743pad.17
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 14:33:04 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id ho7si18325638pad.192.2014.04.30.14.33.02
        for <linux-mm@kvack.org>;
        Wed, 30 Apr 2014 14:33:03 -0700 (PDT)
Date: Wed, 30 Apr 2014 14:32:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5] mm,writeback: fix divide by zero in
 pos_ratio_polynom
Message-Id: <20140430143259.022534b79b01c5234df79dc7@linux-foundation.org>
In-Reply-To: <20140430164255.7a753a8e@cuia.bos.redhat.com>
References: <20140429151910.53f740ef@annuminas.surriel.com>
	<5360C9E7.6010701@jp.fujitsu.com>
	<20140430093035.7e7226f2@annuminas.surriel.com>
	<20140430134826.GH4357@dhcp22.suse.cz>
	<20140430104114.4bdc588e@cuia.bos.redhat.com>
	<20140430120001.b4b95061ac7252a976b8a179@linux-foundation.org>
	<53614F3C.8020009@redhat.com>
	<20140430123526.bc6a229c1ea4addad1fb483d@linux-foundation.org>
	<20140430160218.442863e0@cuia.bos.redhat.com>
	<20140430131353.fa9f49604ea39425bc93c24a@linux-foundation.org>
	<20140430164255.7a753a8e@cuia.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Michal Hocko <mhocko@suse.cz>, Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, sandeen@redhat.com, jweiner@redhat.com, kosaki.motohiro@jp.fujitsu.com, fengguang.wu@intel.com, mpatlasov@parallels.com, Motohiro.Kosaki@us.fujitsu.com

On Wed, 30 Apr 2014 16:42:55 -0400 Rik van Riel <riel@redhat.com> wrote:

> On Wed, 30 Apr 2014 13:13:53 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > This was a consequence of 64->32 truncation and it can't happen any
> > more, can it?
> 
> Andrew, this is cleaner indeed :)
> 
> Masayoshi-san, does the bug still happen with this version, or does
> this fix the problem?

I assumed we wanted a reported-by in there.

> Subject: mm,writeback: fix divide by zero in pos_ratio_polynom
> 
> It is possible for "limit - setpoint + 1" to equal zero, after
> getting truncated to a 32 bit variable, and resulting in a divide
> by zero error.
> 
> Using the fully 64 bit divide functions avoids this problem.

This isn't the whole story, is it?  I added stuff:

: Using the fully 64 bit divide functions avoids this problem.  It also will
: cause pos_ratio_polynom() to return the correct value when (setpoint -
: limit) exceeds 2^32.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
