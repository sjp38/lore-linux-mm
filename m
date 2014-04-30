Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 8C6326B0035
	for <linux-mm@kvack.org>; Wed, 30 Apr 2014 17:01:01 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id kx10so2664588pab.39
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 14:01:01 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id fd9si18242170pad.60.2014.04.30.14.00.59
        for <linux-mm@kvack.org>;
        Wed, 30 Apr 2014 14:01:00 -0700 (PDT)
Date: Wed, 30 Apr 2014 14:00:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5] mm,writeback: fix divide by zero in
 pos_ratio_polynom
Message-Id: <20140430140057.7d2a6e984b2ec987182d2a4e@linux-foundation.org>
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

I'm starting to get worried about 32-bit wraparound in the patch
version number ;)

> Masayoshi-san, does the bug still happen with this version, or does
> this fix the problem?
> 

We could put something like

	if (WARN_ON_ONCE(setpoint == limit))
		setpoint--;

in there if we're not sure.  But it's better to be sure!


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
