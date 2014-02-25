Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f169.google.com (mail-ea0-f169.google.com [209.85.215.169])
	by kanga.kvack.org (Postfix) with ESMTP id 7B5E26B00A0
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 18:03:45 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id d10so432466eaj.14
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 15:03:44 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id i43si16373506eev.49.2014.02.25.15.03.43
        for <linux-mm@kvack.org>;
        Tue, 25 Feb 2014 15:03:44 -0800 (PST)
Message-ID: <530D212E.3020307@redhat.com>
Date: Tue, 25 Feb 2014 18:03:10 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] mm, thp: Add VM_INIT_DEF_MASK and PRCTL_THP_DISABLE
References: <cover.1392009759.rs.git.athorlton@sgi.com> <890608e8ec2968cf6b115411a62f76503ee10331.1392009760.git.athorlton@sgi.com>
In-Reply-To: <890608e8ec2968cf6b115411a62f76503ee10331.1392009760.git.athorlton@sgi.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Thorlton <athorlton@sgi.com>, linux-kernel@vger.kernel.org
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Oleg Nesterov <oleg@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux390@de.ibm.com, linux-s390@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On 02/25/2014 03:54 PM, Alex Thorlton wrote:
> This patch adds a VM_INIT_DEF_MASK, to allow us to set the default flags
> for VMs.  It also adds a prctl control which alllows us to set the THP
> disable bit in mm->def_flags so that VMs will pick up the setting as
> they are created.
> 
> Signed-off-by: Alex Thorlton <athorlton@sgi.com>
> Suggested-by: Oleg Nesterov <oleg@redhat.com>

Acked-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
