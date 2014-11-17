Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 143BC6B0069
	for <linux-mm@kvack.org>; Mon, 17 Nov 2014 14:29:02 -0500 (EST)
Received: by mail-wi0-f171.google.com with SMTP id bs8so4374561wib.10
        for <linux-mm@kvack.org>; Mon, 17 Nov 2014 11:29:01 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w9si17663996wiz.46.2014.11.17.11.29.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Nov 2014 11:29:01 -0800 (PST)
Date: Mon, 17 Nov 2014 14:28:52 -0500
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [PATCH] mm: do not overwrite reserved pages counter at show_mem()
Message-ID: <20141117192852.GA1678@phnom.home.cmpxchg.org>
References: <e34cbf786f7c16d4330889825aa5b13141cc085c.1415989668.git.aquini@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e34cbf786f7c16d4330889825aa5b13141cc085c.1415989668.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org

On Fri, Nov 14, 2014 at 01:34:29PM -0500, Rafael Aquini wrote:
> Minor fixlet to perform the reserved pages counter aggregation
> for each node, at show_mem()
> 
> Signed-off-by: Rafael Aquini <aquini@redhat.com>

ACK

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
