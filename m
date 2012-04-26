Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id E5AE36B0044
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 15:44:17 -0400 (EDT)
Received: by werj55 with SMTP id j55so1471246wer.14
        for <linux-mm@kvack.org>; Thu, 26 Apr 2012 12:44:16 -0700 (PDT)
Subject: Re: [PATCH] slub: prevent validate_slab() error due to race
 condition
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <4F999FFB.3070408@hp.com>
References: <1335466658-29063-1-git-send-email-Waiman.Long@hp.com>
	 <1335467575.2775.61.camel@edumazet-glaptop>  <4F999FFB.3070408@hp.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 26 Apr 2012 21:44:11 +0200
Message-ID: <1335469451.2775.64.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Don Morris <don.morris@hp.com>
Cc: Waiman Long <Waiman.Long@hp.com>, cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 2012-04-26 at 12:20 -0700, Don Morris wrote:

> Note that he sets n here, hence the if() block on 2458 can not
> be taken (!n fails) and the if(likely(!n)) is not taken for the
> same reason. As such, the code falls through to the returns for
> either the slab being empty (or not) where the node lock is
> released (2529 / 2543).

Ah yes, you're right, thanks for clarification.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
