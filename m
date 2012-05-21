Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id D0D9F6B0081
	for <linux-mm@kvack.org>; Mon, 21 May 2012 04:48:10 -0400 (EDT)
Message-ID: <4FBA0148.10205@kernel.org>
Date: Mon, 21 May 2012 17:48:08 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] documentation: update how page-cluster affects swap
 I/O
References: <1337587755-4743-1-git-send-email-ehrhardt@linux.vnet.ibm.com> <1337587755-4743-3-git-send-email-ehrhardt@linux.vnet.ibm.com>
In-Reply-To: <1337587755-4743-3-git-send-email-ehrhardt@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ehrhardt@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, axboe@kernel.dk

On 05/21/2012 05:09 PM, ehrhardt@linux.vnet.ibm.com wrote:

> From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
> 
> Fix of the documentation of /proc/sys/vm/page-cluster to match the behavior of
> the code and add some comments about what the tunable will change in that
> behavior.
> 
> Signed-off-by: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
> Acked-by: Jens Axboe <axboe@kernel.dk>


Reviewed-by: Minchan Kim <minchan@kernel.org>

-- 

Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
