Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 4BC286B0033
	for <linux-mm@kvack.org>; Mon, 19 Aug 2013 18:48:32 -0400 (EDT)
Date: Mon, 19 Aug 2013 15:48:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 0/7] Improving munlock() performance for large
 non-THP areas
Message-Id: <20130819154830.f863757c899bac69360a05b5@linux-foundation.org>
In-Reply-To: <1376915022-12741-1-git-send-email-vbabka@suse.cz>
References: <1376915022-12741-1-git-send-email-vbabka@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: =?ISO-8859-1?Q?J=F6rn?= Engel <joern@logfs.org>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

On Mon, 19 Aug 2013 14:23:35 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:

> The goal of this patch series is to improve performance of munlock() of large
> mlocked memory areas on systems without THP. This is motivated by reported very
> long times of crash recovery of processes with such areas, where munlock() can
> take several seconds. See http://lwn.net/Articles/548108/

That was a very nice patchset.  Not bad for a first effort ;)

Thanks, and welcome.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
