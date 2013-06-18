Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id B338C6B0033
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 16:20:46 -0400 (EDT)
Date: Tue, 18 Jun 2013 14:50:55 -0400
From: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Subject: Re: [PATCH 0/2] hugetlb fixes
Message-ID: <20130618185055.GA27618@logfs.org>
References: <1371581225-27535-1-git-send-email-joern@logfs.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1371581225-27535-1-git-send-email-joern@logfs.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>

On Tue, 18 June 2013 14:47:03 -0400, Joern Engel wrote:
> 
> Test program below is failing before these two patches and passing
> after.

Actually, do we have a place to stuff kernel tests?  And if not,
should we have one?

JA?rn

--
My second remark is that our intellectual powers are rather geared to
master static relations and that our powers to visualize processes
evolving in time are relatively poorly developed.
-- Edsger W. Dijkstra

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
