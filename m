Message-ID: <492C25EF.2020202@redhat.com>
Date: Tue, 25 Nov 2008 11:21:03 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH/RFC] - support inheritance of mlocks across fork/exec
References: <1227561707.6937.61.camel@lts-notebook>
In-Reply-To: <1227561707.6937.61.camel@lts-notebook>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Lee Schermerhorn wrote:
> PATCH/RFC - support inheritance of mlocks across fork/exec

Looks like it could be useful.

> Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
