Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id 817166B006C
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 13:55:51 -0400 (EDT)
Received: by mail-qg0-f42.google.com with SMTP id z60so1035883qgd.15
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 10:55:51 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e6si4122540qar.66.2014.10.23.10.55.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Oct 2014 10:55:49 -0700 (PDT)
Message-ID: <54494101.6010701@redhat.com>
Date: Thu, 23 Oct 2014 13:55:13 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] Convert khugepaged to a task_work function
References: <1414032567-109765-1-git-send-email-athorlton@sgi.com>
In-Reply-To: <1414032567-109765-1-git-send-email-athorlton@sgi.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Bob Liu <lliubbo@gmail.com>, David Rientjes <rientjes@google.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@redhat.com>, Kees Cook <keescook@chromium.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Vladimir Davydov <vdavydov@parallels.com>, linux-kernel@vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 10/22/2014 10:49 PM, Alex Thorlton wrote:

> Alex Thorlton (4): Disable khugepaged thread Add pgcollapse
> controls to task_struct Convert khugepaged scan functions to work
> with task_work Add /proc files to expose per-mm pgcollapse stats

Is it just me, or did the third patch never show up in other people's
email either?

I don't see it in my inbox, my lkml folder, my linux-mm folder, or
on lkml.org

- -- 
All rights reversed
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJUSUEBAAoJEM553pKExN6DougH/0fPp5nZkQ4oF3zrbLO8Hsig
muVu1VU+fy9Hkrp5SeHCXBpZmr9d00A/U4mAIrcDPrdCKWOWfG76BF31Qf4mWKwP
IB+YSHL4X/3LDGylq06xEZ3x+dci24v8Bq+3CLjMFphKcqY7A/R2VFDF82+f25jh
AanF4V6RMRSYoUVYQYbwtyToanSGb4hUKAh6chCXHRNL9m/wNwj5tiItMVY/N852
Zk0NgofzMV9yThnPCXloEr6toRJm1NrQlLYg/q5LHxA4b62NPGlmsod7gzg88svP
Q6I8quUY72sqsvMO5NfJGMxqK11PYEfo41jO2Q3sLfaMiKg0lnSBcr+FogiovGQ=
=QNt6
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
