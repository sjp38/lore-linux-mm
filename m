Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 434836B004D
	for <linux-mm@kvack.org>; Tue, 25 Mar 2014 14:07:07 -0400 (EDT)
Received: by mail-ie0-f174.google.com with SMTP id rp18so763029iec.33
        for <linux-mm@kvack.org>; Tue, 25 Mar 2014 11:07:07 -0700 (PDT)
Received: from qmta09.emeryville.ca.mail.comcast.net (qmta09.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:96])
        by mx.google.com with ESMTP id l4si28591464igx.25.2014.03.25.11.07.04
        for <linux-mm@kvack.org>;
        Tue, 25 Mar 2014 11:07:05 -0700 (PDT)
Date: Tue, 25 Mar 2014 13:07:02 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: slab_common: fix the check for duplicate slab names
In-Reply-To: <20140325170324.GC580@redhat.com>
Message-ID: <alpine.DEB.2.10.1403251306260.26471@nuc>
References: <alpine.LRH.2.02.1403041711300.29476@file01.intranet.prod.int.rdu2.redhat.com> <20140325170324.GC580@redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Snitzer <snitzer@redhat.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, linux-kernel@vger.kernel.org, "Alasdair G. Kergon" <agk@redhat.com>, Mikulas Patocka <mpatocka@redhat.com>

On Tue, 25 Mar 2014, Mike Snitzer wrote:

> This patch still isn't upstream.  Who should be shepherding it to Linus?

Pekka usually does that.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
