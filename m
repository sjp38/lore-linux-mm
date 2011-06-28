Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 20EB86B00F1
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 17:16:57 -0400 (EDT)
Date: Tue, 28 Jun 2011 17:16:47 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH] slub: reduce overhead of slub_debug
Message-ID: <20110628211647.GB11660@redhat.com>
References: <20110626193918.GA3339@joi.lan>
 <alpine.DEB.2.00.1106281431370.27518@router.home>
 <4E0A2E26.5000001@gmail.com>
 <alpine.DEB.2.00.1106281355010.4229@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1106281355010.4229@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: David Daney <ddaney.cavm@gmail.com>, Christoph Lameter <cl@linux.com>, Marcin Slusarz <marcin.slusarz@gmail.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue, Jun 28, 2011 at 01:58:06PM -0700, David Rientjes wrote:

 > SLUB debugging is useful only to diagnose issues or test new code, nobody 
 > is going to be enabling it in production environment.  We don't need 30 
 > new lines of code that make one thing slightly faster

During five of the six months of development, Fedora kernels are built with
slub debugging forced on.  And it turns up problems every single release.

Having the impact of this be lower is very desirable. If this doesn't get
merged, I'd be tempted to carry it in Fedora regardless for this reason.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
