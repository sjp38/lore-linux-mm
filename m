Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id EEF956B0072
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 09:46:11 -0500 (EST)
Date: Mon, 21 Nov 2011 15:46:08 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH] hugetlb: clarify hugetlb_instantiation_mutex usage
Message-ID: <20111121144608.GC16957@tiehlicka.suse.cz>
References: <CAJd=RBC+p8033bHNfP=WQ2SU1Y1zRpj+FEi9FdjuFKkjF_=_iA@mail.gmail.com>
 <20111118150742.GA23223@tiehlicka.suse.cz>
 <CAJd=RBCOK9tis-bF87Csn70miRDqLtCUiZmDH2hnc8i_9+KtNw@mail.gmail.com>
 <20111118161128.GC23223@tiehlicka.suse.cz>
 <20111121122303.GA13594@tiehlicka.suse.cz>
 <20111121141625.GB16957@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111121141625.GB16957@tiehlicka.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

And the follow up documentation patch:
---
