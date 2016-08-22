Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0219B6B025E
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 07:01:17 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l4so59012671wml.0
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 04:01:16 -0700 (PDT)
Received: from mail.ud10.udmedia.de (ud10.udmedia.de. [194.117.254.50])
        by mx.google.com with ESMTPS id h130si15659357wme.36.2016.08.22.04.01.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Aug 2016 04:01:16 -0700 (PDT)
Date: Mon, 22 Aug 2016 13:01:13 +0200
From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: OOM detection regressions since 4.7
Message-ID: <20160822110113.GB314@x4>
References: <20160822093249.GA14916@dhcp22.suse.cz>
 <20160822101614.GA314@x4>
 <20160822105653.GI13596@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160822105653.GI13596@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, greg@suse.cz, Linus Torvalds <torvalds@linux-foundation.org>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 2016.08.22 at 12:56 +0200, Michal Hocko wrote:
> On Mon 22-08-16 12:16:14, Markus Trippelsdorf wrote:
> > On 2016.08.22 at 11:32 +0200, Michal Hocko wrote:
> > > [1] http://lkml.kernel.org/r/20160731051121.GB307@x4
> > 
> > For the report [1] above:
> > 
> > markus@x4 linux % cat .config | grep CONFIG_COMPACTION
> > # CONFIG_COMPACTION is not set
> 
> Hmm, without compaction and a heavy fragmentation then I am afraid we
> cannot really do much. What is the reason to disable compaction in the
> first place?

I don't recall. Must have been some issue in the past. I will re-enable
the option.

-- 
Markus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
