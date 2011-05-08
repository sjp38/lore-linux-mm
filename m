Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 43F6E6B0022
	for <linux-mm@kvack.org>; Sun,  8 May 2011 15:36:38 -0400 (EDT)
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id p48JaaeZ028343
	for <linux-mm@kvack.org>; Sun, 8 May 2011 12:36:36 -0700
Received: from pve37 (pve37.prod.google.com [10.241.210.37])
	by kpbe12.cbf.corp.google.com with ESMTP id p48JaUN0018063
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 8 May 2011 12:36:35 -0700
Received: by pve37 with SMTP id 37so3041881pve.35
        for <linux-mm@kvack.org>; Sun, 08 May 2011 12:36:30 -0700 (PDT)
Date: Sun, 8 May 2011 12:36:31 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v2] tmpfs: fix race between umount and writepage
In-Reply-To: <4DC691D0.6050104@parallels.com>
Message-ID: <alpine.LSU.2.00.1105081234240.15963@sister.anvils>
References: <4DAFD0B1.9090603@parallels.com> <20110421064150.6431.84511.stgit@localhost6> <20110421124424.0a10ed0c.akpm@linux-foundation.org> <4DB0FE8F.9070407@parallels.com> <alpine.LSU.2.00.1105031223120.9845@sister.anvils> <4DC4D9A6.9070103@parallels.com>
 <alpine.LSU.2.00.1105071621330.3668@sister.anvils> <4DC691D0.6050104@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Sun, 8 May 2011, Konstantin Khlebnikov wrote:
> 
> Ok, I can test final patch-set on the next week.
> Also I can try to add some swapoff test-cases.

That would be helpful if you have the time: thank you.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
