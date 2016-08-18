Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id F29E18309D
	for <linux-mm@kvack.org>; Thu, 18 Aug 2016 10:46:08 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id x131so70285544ite.0
        for <linux-mm@kvack.org>; Thu, 18 Aug 2016 07:46:08 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0074.hostedemail.com. [216.40.44.74])
        by mx.google.com with ESMTPS id y203si5410200itc.30.2016.08.18.07.46.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Aug 2016 07:46:08 -0700 (PDT)
Message-ID: <1471531563.4319.41.camel@perches.com>
Subject: Re: [PATCH] proc, smaps: reduce printing overhead
From: Joe Perches <joe@perches.com>
Date: Thu, 18 Aug 2016 07:46:03 -0700
In-Reply-To: <20160818144149.GO30162@dhcp22.suse.cz>
References: <1471519888-13829-1-git-send-email-mhocko@kernel.org>
	 <1471526765.4319.31.camel@perches.com>
	 <20160818142616.GN30162@dhcp22.suse.cz>
	 <20160818144149.GO30162@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Jann Horn <jann@thejh.net>

On Thu, 2016-08-18 at 16:41 +0200, Michal Hocko wrote:
> On Thu 18-08-16 16:26:16, Michal Hocko wrote:
> > b) doesn't it try to be overly clever when doing that in the caller
> > doesn't cost all that much? Sure you can save few bytes in the spaces
> > but then I would just argue to use \t rather than fixed string length.
> ohh, I misread the code. It tries to emulate the width formater. But is
> this really necessary? Do we know about any tools doing a fixed string
> parsing?

I don't, but it's proc and all the output formatting
shouldn't be changed.

Appended to is generally OK, but whitespace changed is
not good.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
