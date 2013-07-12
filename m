Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 4DA596B0032
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 02:37:04 -0400 (EDT)
Message-ID: <51DFA3FD.2020201@intel.com>
Date: Thu, 11 Jul 2013 23:36:45 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm: add a field to store names for private anonymous
 memory
References: <1373596462-27115-1-git-send-email-ccross@android.com> <1373596462-27115-2-git-send-email-ccross@android.com>
In-Reply-To: <1373596462-27115-2-git-send-email-ccross@android.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin Cross <ccross@android.com>
Cc: linux-kernel@vger.kernel.org, Kyungmin Park <kmpark@infradead.org>, Christoph Hellwig <hch@infradead.org>, John Stultz <john.stultz@linaro.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Pekka Enberg <penberg@kernel.org>, Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Cyrill Gorcunov <gorcunov@openvz.org>, David Rientjes <rientjes@google.com>, Davidlohr Bueso <dave@gnu.org>, Kees Cook <keescook@chromium.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, David Howells <dhowells@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Dave Jones <davej@redhat.com>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Oleg Nesterov <oleg@redhat.com>, Shaohua Li <shli@fusionio.com>, Sasha Levin <sasha.levin@oracle.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@kernel.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org

On 07/11/2013 07:34 PM, Colin Cross wrote:
> +		pages_pinned = get_user_pages(current, mm, page_start_vaddr,
> +				1, 0, 0, &page, NULL);
> +		if (pages_pinned < 1) {
> +			seq_puts(m, "<fault>]");
> +			return;
> +		}
> +
> +		kaddr = (const char *)kmap(page);
> +		len = min(max_len, PAGE_SIZE - page_offset);
> +		write_len = strnlen(kaddr + page_offset, len);
> +		seq_write(m, kaddr + page_offset, write_len);
> +		kunmap(page);
> +		put_page(page);

This looks a bit like access_process_vm()?  Can you perhaps use it here?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
