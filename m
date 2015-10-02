Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id C4A0D4402FE
	for <linux-mm@kvack.org>; Fri,  2 Oct 2015 18:37:59 -0400 (EDT)
Received: by qgt47 with SMTP id 47so107289122qgt.2
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 15:37:59 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id k196si12256310qhc.98.2015.10.02.15.37.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Oct 2015 15:37:59 -0700 (PDT)
Date: Fri, 2 Oct 2015 15:37:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 4/4] mm, procfs: Display VmAnon, VmFile and VmShm in
 /proc/pid/status
Message-Id: <20151002153757.dcbf81604107580ef3ff6e65@linux-foundation.org>
In-Reply-To: <1443792951-13944-5-git-send-email-vbabka@suse.cz>
References: <1443792951-13944-1-git-send-email-vbabka@suse.cz>
	<1443792951-13944-5-git-send-email-vbabka@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Jerome Marchand <jmarchan@redhat.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Randy Dunlap <rdunlap@infradead.org>, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Paul Mackerras <paulus@samba.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Linux API <linux-api@vger.kernel.org>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

On Fri,  2 Oct 2015 15:35:51 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:

> From: Jerome Marchand <jmarchan@redhat.com>
> 
> It's currently inconvenient to retrieve MM_ANONPAGES value from status
> and statm files and there is no way to separate MM_FILEPAGES and
> MM_SHMEMPAGES. Add RssAnon, RssFile and RssShm lines in /proc/<pid>/status
> to solve these issues.

This changelog is also head-spinning.

Why is it talking about MM_ANONPAGES and MM_FILEPAGES in the context of
procfs files?  Those terms are kernel-internal stuff and are
meaningless to end users.

So can we please start over with the changelogs?

- What is wrong with the current user interface?

- What changes are we proposing making?

- What new fields are added to the UI?  What is their meaning to users?

- Are any existing UI fields altered?  If so how and why and what
  impact will that have?

Extra points will be awarded for example procfs output.

This is the important stuff!  Once this is all clearly described,
understood and reviewed, then we can get into the
kernel-internal-microdetails like MM_ANONPAGES.


(And "What is wrong with the current user interface?" is important. 
What value does this patchset provide to end users?  Why does anyone
even want these changes?)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
