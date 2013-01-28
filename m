Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 575A26B0010
	for <linux-mm@kvack.org>; Mon, 28 Jan 2013 18:54:54 -0500 (EST)
Date: Mon, 28 Jan 2013 15:54:52 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/11] ksm: NUMA trees and page migration
Message-Id: <20130128155452.16882a6e.akpm@linux-foundation.org>
In-Reply-To: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils>
References: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Anton Arapov <anton@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 25 Jan 2013 17:53:10 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> Here's a KSM series

Sanity check: do you have a feeling for how useful KSM is? 
Performance/space improvements for typical (or atypical) workloads? 
Are people using it?  Successfully?

IOW, is it justifying itself?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
