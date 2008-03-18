Received: by el-out-1112.google.com with SMTP id y26so55665ele.4
        for <linux-mm@kvack.org>; Tue, 18 Mar 2008 12:32:50 -0700 (PDT)
Message-ID: <84144f020803181232y55a35393id73d2bd78f8d6159@mail.gmail.com>
Date: Tue, 18 Mar 2008 21:32:48 +0200
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [patch 8/9] Pageflags: Eliminate PG_xxx aliases
In-Reply-To: <20080318182036.212376083@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080318181957.138598511@sgi.com>
	 <20080318182036.212376083@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, apw@shadowen.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Jeremy Fitzhardinge <jeremy@goop.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 18, 2008 at 8:20 PM, Christoph Lameter <clameter@sgi.com> wrote:
>   #ifdef CONFIG_HIGHMEM
>   /*
>   * Must use a macro here due to header dependency issues. page_zone() is not
>   * available at this point.
>   */
>  -#define PageHighMem(__p) is_highmem(page_zone(page))
>  +#define PageHighMem(__p) is_highmem(page_zone(__p))

Looks like this hunk should be in some other patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
