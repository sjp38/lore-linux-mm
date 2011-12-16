Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 575546B005A
	for <linux-mm@kvack.org>; Fri, 16 Dec 2011 16:16:43 -0500 (EST)
Received: by iacb35 with SMTP id b35so4075893iac.14
        for <linux-mm@kvack.org>; Fri, 16 Dec 2011 13:16:42 -0800 (PST)
Date: Fri, 16 Dec 2011 13:16:40 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH -mm] slub: debug_guardpage_minorder documentation tweak
In-Reply-To: <20111216132349.GB14271@redhat.com>
Message-ID: <alpine.DEB.2.00.1112161315220.6862@chino.kir.corp.google.com>
References: <1321633507-13614-1-git-send-email-sgruszka@redhat.com> <alpine.DEB.2.00.1112081303100.8127@chino.kir.corp.google.com> <20111212145948.GA2380@redhat.com> <201112130021.41429.rjw@sisk.pl> <alpine.DEB.2.00.1112131640240.32369@chino.kir.corp.google.com>
 <20111216132155.GA14271@redhat.com> <20111216132349.GB14271@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stanislaw Gruszka <sgruszka@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>

On Fri, 16 Dec 2011, Stanislaw Gruszka wrote:

> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>

Acked-by: David Rientjes <rientjes@google.com>

Andrew, this should be folded into 
slub-document-setting-min-order-with-debug_guardpage_minorder-0.patch 
which should be folded into 
slub-min-order-when-debug_guardpage_minorder-0.patch

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
