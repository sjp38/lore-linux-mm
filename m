Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f178.google.com (mail-qc0-f178.google.com [209.85.216.178])
	by kanga.kvack.org (Postfix) with ESMTP id E85B96B012A
	for <linux-mm@kvack.org>; Tue, 11 Nov 2014 19:59:08 -0500 (EST)
Received: by mail-qc0-f178.google.com with SMTP id b13so9386229qcw.23
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 16:59:08 -0800 (PST)
Received: from zinan.dashjr.org (zinan.dashjr.org. [2001:470:88ff:2f::1])
        by mx.google.com with ESMTP id p39si39458464qgp.16.2014.11.11.16.59.07
        for <linux-mm@kvack.org>;
        Tue, 11 Nov 2014 16:59:07 -0800 (PST)
From: Luke Dashjr <luke@dashjr.org>
Subject: Re: [Bug 87891] New: kernel BUG at mm/slab.c:2625!
Date: Wed, 12 Nov 2014 00:54:01 +0000
References: <bug-87891-27@https.bugzilla.kernel.org/> <alpine.DEB.2.11.1411111833220.8762@gentwo.org> <20141111164913.3616531c21c91499871c46de@linux-foundation.org>
In-Reply-To: <20141111164913.3616531c21c91499871c46de@linux-foundation.org>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201411120054.04651.luke@dashjr.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Ming Lei <ming.lei@canonical.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Pauli Nieminen <suokkos@gmail.com>, Dave Airlie <airlied@linux.ie>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, bugzilla-daemon@bugzilla.kernel.org, luke-jr+linuxbugs@utopios.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org

On Wednesday, November 12, 2014 12:49:13 AM Andrew Morton wrote:
> But anyway - Luke, please attach your .config to
> https://bugzilla.kernel.org/show_bug.cgi?id=87891?

Done: https://bugzilla.kernel.org/attachment.cgi?id=157381

Luke

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
