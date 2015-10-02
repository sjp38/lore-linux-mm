Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id 90F154402FE
	for <linux-mm@kvack.org>; Fri,  2 Oct 2015 18:37:18 -0400 (EDT)
Received: by qgx61 with SMTP id 61so107428823qgx.3
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 15:37:18 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 21si12291295qha.12.2015.10.02.15.37.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Oct 2015 15:37:18 -0700 (PDT)
Date: Fri, 2 Oct 2015 15:37:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 3/4] mm, shmem: Add shmem resident memory accounting
Message-Id: <20151002153716.8dfc261ed775c63caea92c69@linux-foundation.org>
In-Reply-To: <1443792951-13944-4-git-send-email-vbabka@suse.cz>
References: <1443792951-13944-1-git-send-email-vbabka@suse.cz>
	<1443792951-13944-4-git-send-email-vbabka@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Jerome Marchand <jmarchan@redhat.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Randy Dunlap <rdunlap@infradead.org>, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Paul Mackerras <paulus@samba.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Linux API <linux-api@vger.kernel.org>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

On Fri,  2 Oct 2015 15:35:50 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:

> From: Jerome Marchand <jmarchan@redhat.com>

Changelog is a bit weird.

> Currently looking at /proc/<pid>/status or statm, there is no way to
> distinguish shmem pages from pages mapped to a regular file (shmem
> pages are mapped to /dev/zero), even though their implication in
> actual memory use is quite different.

OK, that's a bunch of stuff about the user interface.

> This patch adds MM_SHMEMPAGES counter to mm_rss_stat to account for
> shmem pages instead of MM_FILEPAGES.

And that has nothing to do with the user interface.

So now this little reader is all confused.  The patch doesn't actually
address the described problem at all, does it?  It's preparatory stuff
only?  No changes to the kernel's user interface?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
