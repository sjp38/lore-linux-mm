Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 783506B005A
	for <linux-mm@kvack.org>; Tue, 10 Jan 2012 00:40:20 -0500 (EST)
Message-ID: <4F0BCF3B.4050901@redhat.com>
Date: Tue, 10 Jan 2012 00:40:11 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: vmscan: cleanup with s/reclaim_mode/isolate_mode/
References: <CAJd=RBBifQggNFtBsq0-Q_fG6mOJ-rJ544Me9pLFXbMi3Xn0gQ@mail.gmail.com>
In-Reply-To: <CAJd=RBBifQggNFtBsq0-Q_fG6mOJ-rJ544Me9pLFXbMi3Xn0gQ@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>

On 01/06/2012 09:01 AM, Hillf Danton wrote:
> With tons of reclaim_mode(defined as one field of struct scan_control) already
> in the file, it is clearer to rename it when setting up the isolation mode.
>
>
> Cc: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
> Cc: David Rientjes<rientjes@google.com>
> Cc: Andrew Morton<akpm@linux-foundation.org>
> Signed-off-by: Hillf Danton<dhillf@gmail.com>

Reviewed-by: Rik van Riel<riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
