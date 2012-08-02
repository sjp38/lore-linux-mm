Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id A2CA86B005D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 12:09:40 -0400 (EDT)
Date: Thu, 2 Aug 2012 11:09:37 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 05/23 V2] mm,migrate: use N_MEMORY instead
 N_HIGH_MEMORY
In-Reply-To: <1343887288-8866-6-git-send-email-laijs@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1208021109200.23049@router.home>
References: <1343887288-8866-1-git-send-email-laijs@cn.fujitsu.com> <1343887288-8866-6-git-send-email-laijs@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Wang Sheng-Hui <shhuiw@gmail.com>, linux-mm@kvack.org

On Thu, 2 Aug 2012, Lai Jiangshan wrote:

> The code here need to handle with the nodes which have memory, we should
> use N_MEMORY instead.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
