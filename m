Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A54FF6B0005
	for <linux-mm@kvack.org>; Wed, 22 Jun 2016 08:55:07 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id a66so1946804wme.1
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 05:55:07 -0700 (PDT)
Received: from plane.gmane.org (plane.gmane.org. [80.91.229.3])
        by mx.google.com with ESMTPS id j72si114103lfe.155.2016.06.22.05.55.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Jun 2016 05:55:06 -0700 (PDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1bFhgO-0005mM-74
	for linux-mm@kvack.org; Wed, 22 Jun 2016 14:55:04 +0200
Received: from pd953e4e5.dip0.t-ipconnect.de ([217.83.228.229])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 14:55:04 +0200
Received: from holger by pd953e4e5.dip0.t-ipconnect.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Wed, 22 Jun 2016 14:55:04 +0200
From: Holger =?iso-8859-1?q?Hoffst=E4tte?= <holger@applied-asynchrony.com>
Subject: Re: [PATCH v8 1/2] sb: add a new writeback list for sync
Date: Wed, 22 Jun 2016 12:46:35 +0000 (UTC)
Message-ID: <pan$a4de2$c46ac11d$189b022f$c3599939@applied-asynchrony.com>
References: <1466594593-6757-1-git-send-email-bfoster@redhat.com>
	<1466594593-6757-2-git-send-email-bfoster@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org

On Wed, 22 Jun 2016 07:23:12 -0400, Brian Foster wrote:

> From: Dave Chinner <dchinner@redhat.com>
> 
> wait_sb_inodes() currently does a walk of all inodes in the
> filesystem to find dirty one to wait on during sync. This is highly
> inefficient and wastes a lot of CPU when there are lots of clean
> cached inodes that we don't need to wait on.
(..)

> Tested-by: Holger HoffstA?tte <holger.hoffstaette@applied-asynchrony.com>

Brian alerted me to the fact that I'm confused, so for the record this
should have been:

Tested-by: Holger HoffstA?tte <holger@applied-asynchrony.com>

sorry..ETOOMANYADDRS :(

-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
