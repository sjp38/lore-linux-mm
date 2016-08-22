Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 845746B0069
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 18:06:04 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id o124so221578624pfg.1
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 15:06:04 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id fn9si139351pad.209.2016.08.22.15.06.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Aug 2016 15:06:03 -0700 (PDT)
Date: Mon, 22 Aug 2016 15:05:17 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: OOM detection regressions since 4.7
Message-Id: <20160822150517.62dc7cce74f1af6c1f204549@linux-foundation.org>
In-Reply-To: <20160822134227.GM13596@dhcp22.suse.cz>
References: <20160822093249.GA14916@dhcp22.suse.cz>
	<20160822093707.GG13596@dhcp22.suse.cz>
	<20160822100528.GB11890@kroah.com>
	<20160822105441.GH13596@dhcp22.suse.cz>
	<20160822133114.GA15302@kroah.com>
	<20160822134227.GM13596@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Greg KH <gregkh@linuxfoundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, 22 Aug 2016 15:42:28 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> Of course, if Linus/Andrew doesn't like to take those compaction
> improvements this late then I will ask to merge the partial revert to
> Linus tree as well and then there is not much to discuss.

This sounds like the prudent option.  Can we get 4.8 working
well-enough, backport that into 4.7.x and worry about the fancier stuff
for 4.9?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
