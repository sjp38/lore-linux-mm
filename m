Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 8B7C66B01EE
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 10:47:20 -0400 (EDT)
From: Tarkan Erimer <tarkan.erimer@turknet.net.tr>
Subject: Re: [PATCH 0/14] Memory Compaction v7
Date: Tue, 6 Apr 2010 17:47:16 +0300
References: <1270224168-14775-1-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1270224168-14775-1-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-9"
Content-Transfer-Encoding: 7bit
Message-Id: <201004061747.16886.tarkan.erimer@turknet.net.tr>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Mel,

On Friday 02 April 2010 07:02:34 pm Mel Gorman wrote:
> The only change is relatively minor and is around the migration of unmapped
> PageSwapCache pages. Specifically, it's not safe to access anon_vma for
> these pages when remapping after migration completes so the last patch
> makes sure we don't.
> 
> Are there any further obstacles to merging?
> 

These patches are applicable to which kernel version or versions ?
I tried on 2.6.33.2 and 2.6.34-rc3 without succeed. 

Tarkan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
