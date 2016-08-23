Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C34076B0069
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 03:40:16 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id o80so78730161wme.1
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 00:40:16 -0700 (PDT)
Received: from mail.ud10.udmedia.de (ud10.udmedia.de. [194.117.254.50])
        by mx.google.com with ESMTPS id j21si19830450wmd.52.2016.08.23.00.40.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Aug 2016 00:40:15 -0700 (PDT)
Date: Tue, 23 Aug 2016 09:40:14 +0200
From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: OOM detection regressions since 4.7
Message-ID: <20160823074014.GB15849@x4>
References: <20160822093249.GA14916@dhcp22.suse.cz>
 <20160823045245.GC17039@js1304-P5Q-DELUXE>
 <20160823073318.GA23577@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160823073318.GA23577@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, greg@suse.cz, Linus Torvalds <torvalds@linux-foundation.org>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 2016.08.23 at 09:33 +0200, Michal Hocko wrote:
> On Tue 23-08-16 13:52:45, Joonsoo Kim wrote:
> [...]
> > Hello, Michal.
> > 
> > I agree with partial revert but revert should be a different form.
> > Below change try to reuse should_compact_retry() version for
> > !CONFIG_COMPACTION but it turned out that it also causes regression in
> > Markus report [1].
> 
> I would argue that CONFIG_COMPACTION=n behaves so arbitrary for high
> order workloads that calling any change in that behavior a regression
> is little bit exaggerated. Disabling compaction should have a very
> strong reason. I haven't heard any so far. I am even wondering whether
> there is a legitimate reason for that these days.

BTW, the current config description:

  CONFIG_COMPACTION:
  Allows the compaction of memory for the allocation of huge pages. 

doesn't make it clear to the user that this is an essential feature.

-- 
Markus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
