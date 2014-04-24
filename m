Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f44.google.com (mail-qa0-f44.google.com [209.85.216.44])
	by kanga.kvack.org (Postfix) with ESMTP id 6584F6B0035
	for <linux-mm@kvack.org>; Thu, 24 Apr 2014 12:52:03 -0400 (EDT)
Received: by mail-qa0-f44.google.com with SMTP id hw13so2535153qab.3
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 09:52:03 -0700 (PDT)
Received: from qmta10.emeryville.ca.mail.comcast.net (qmta10.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:17])
        by mx.google.com with ESMTP id l59si2491501qga.58.2014.04.24.09.52.02
        for <linux-mm@kvack.org>;
        Thu, 24 Apr 2014 09:52:02 -0700 (PDT)
Date: Thu, 24 Apr 2014 11:51:58 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slab: fix the type of the index on freelist index
 accessor
In-Reply-To: <CAAG0J9-8WbO48jXpUfOq6CmHinL9dMg5Ee9-J9qndBEtZgWYJg@mail.gmail.com>
Message-ID: <alpine.DEB.2.10.1404241151150.23715@gentwo.org>
References: <1397805849-4913-1-git-send-email-iamjoonsoo.kim@lge.com> <CAAG0J9-8WbO48jXpUfOq6CmHinL9dMg5Ee9-J9qndBEtZgWYJg@mail.gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Hogan <james.hogan@imgtec.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Steven King <sfking@fdwdc.com>, Geert Uytterhoeven <geert@linux-m68k.org>, akpm@linuxfoundation.org


In case I have not done so yet.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
