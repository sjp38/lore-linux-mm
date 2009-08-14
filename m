Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 613BB6B004D
	for <linux-mm@kvack.org>; Fri, 14 Aug 2009 02:56:47 -0400 (EDT)
Date: Fri, 14 Aug 2009 15:56:51 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 4/5] mm: return boolean from page_has_private()
In-Reply-To: <1250065929-17392-4-git-send-email-hannes@cmpxchg.org>
References: <1250065929-17392-1-git-send-email-hannes@cmpxchg.org> <1250065929-17392-4-git-send-email-hannes@cmpxchg.org>
Message-Id: <20090814145115.CBEA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> Make page_has_private() return a true boolean value and remove the
> double negations from the two callsites using it for arithmetic.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Christoph Lameter <cl@linux-foundation.org>

	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
