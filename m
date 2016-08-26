Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B4BD76B026F
	for <linux-mm@kvack.org>; Fri, 26 Aug 2016 02:26:04 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id o80so48320022wme.1
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 23:26:04 -0700 (PDT)
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com. [74.125.82.49])
        by mx.google.com with ESMTPS id ww3si9287631wjb.172.2016.08.25.23.26.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Aug 2016 23:26:03 -0700 (PDT)
Received: by mail-wm0-f49.google.com with SMTP id q128so265967099wma.1
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 23:26:03 -0700 (PDT)
Date: Fri, 26 Aug 2016 08:26:01 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: OOM detection regressions since 4.7
Message-ID: <20160826062556.GA16195@dhcp22.suse.cz>
References: <20160822093249.GA14916@dhcp22.suse.cz>
 <20160822093707.GG13596@dhcp22.suse.cz>
 <20160822100528.GB11890@kroah.com>
 <20160822105441.GH13596@dhcp22.suse.cz>
 <20160822133114.GA15302@kroah.com>
 <20160822134227.GM13596@dhcp22.suse.cz>
 <20160822150517.62dc7cce74f1af6c1f204549@linux-foundation.org>
 <20160823074339.GB23577@dhcp22.suse.cz>
 <5852cd26-e013-8313-30f0-68a92db02b8f@Quantum.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5852cd26-e013-8313-30f0-68a92db02b8f@Quantum.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Greg KH <gregkh@linuxfoundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 25-08-16 13:30:23, Ralf-Peter Rohbeck wrote:
[...]
> This worked for me for about 12 hours of my torture test. Logs are at
> https://filebin.net/2rfah407nbhzs69e/OOM_4.8.0-rc2_p1.tar.bz2.

Thanks! Can we add your
Tested-by: Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>

to the patch?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
