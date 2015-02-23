Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 267B56B0032
	for <linux-mm@kvack.org>; Mon, 23 Feb 2015 17:02:39 -0500 (EST)
Received: by padfb1 with SMTP id fb1so30771025pad.8
        for <linux-mm@kvack.org>; Mon, 23 Feb 2015 14:02:38 -0800 (PST)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id c1si3842414pdk.5.2015.02.23.14.02.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 23 Feb 2015 14:02:38 -0800 (PST)
Message-ID: <1424728954.6539.49.camel@stgolabs.net>
Subject: Re: [PATCH v2 1/3] kernel/audit: consolidate handling of
 mm->exe_file
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Mon, 23 Feb 2015 14:02:34 -0800
In-Reply-To: <1579072.xrgTk0Bmz6@sifl>
References: <1424304641-28965-1-git-send-email-dbueso@suse.de>
	 <1424304641-28965-2-git-send-email-dbueso@suse.de>
	 <1424658000.6539.14.camel@stgolabs.net> <1579072.xrgTk0Bmz6@sifl>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Moore <paul@paul-moore.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, eparis@redhat.com, linux-audit@redhat.com

On Mon, 2015-02-23 at 16:59 -0500, Paul Moore wrote:
> Merged into audit#next.

hmm Andrew I was hoping you could take these patches. That way we can
easily build on top. Let me know if you think otherwise, as I've got
more ready to send out with a similar email scheme.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
