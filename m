Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id E6CB96B005D
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 09:00:02 -0500 (EST)
Date: Mon, 7 Jan 2013 13:59:59 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] typo: replace kernelcore with Movable
Message-ID: <20130107135959.GE3885@suse.de>
References: <5aed74b1520f495521fe97b99b714cfe7572faa1.1357359930.git.wpan@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <5aed74b1520f495521fe97b99b714cfe7572faa1.1357359930.git.wpan@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weiping Pan <wpan@redhat.com>
Cc: linux-mm@kvack.org

On Sat, Jan 05, 2013 at 12:29:17PM +0800, Weiping Pan wrote:
> Han Pingtian found a typo in Documentation/kernel-parameters.txt
> about "kernelcore=", that "kernelcore" should be replaced with "Movable" here.
> 
> Signed-off-by: Weiping Pan <wpan@redhat.com>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
