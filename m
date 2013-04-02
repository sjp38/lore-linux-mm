Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 6A41F6B0002
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 01:34:35 -0400 (EDT)
Received: by mail-lb0-f175.google.com with SMTP id o10so108096lbi.34
        for <linux-mm@kvack.org>; Mon, 01 Apr 2013 22:34:33 -0700 (PDT)
Message-ID: <515A6DE5.8000508@openvz.org>
Date: Tue, 02 Apr 2013 09:34:29 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH v2 0/2] fix hugepage coredump
References: <1364836882-9713-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1364836882-9713-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Naoya Horiguchi wrote:
> Hi,
>
> Here is 2nd version of hugepage coredump fix.
> See individual patches for more details.
>
> Thanks,
> Naoya Horiguchi

ACK to both patches


VM_* bits cleanup patchset was merged into v3.7, so only two recent stable kernels needs this fix.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
