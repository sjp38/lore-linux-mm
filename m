Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 8F8B46B005A
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 09:41:10 -0400 (EDT)
Message-ID: <50869E6C.1080907@redhat.com>
Date: Tue, 23 Oct 2012 09:41:00 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] mm/swap: automatic tuning for swapin readahead
References: <50460CED.6060006@redhat.com> <20120906110836.22423.17638.stgit@zurg> <alpine.LSU.2.00.1210011418270.2940@eggly.anvils> <506AACAC.2010609@openvz.org> <alpine.LSU.2.00.1210031337320.1415@eggly.anvils> <506DB816.9090107@openvz.org> <alpine.LSU.2.00.1210081451410.1384@eggly.anvils> <20121016005049.GA1467@kernel.org> <20121022073654.GA7821@kernel.org> <alpine.LNX.2.00.1210222141170.1136@eggly.anvils> <20121023055127.GA24239@kernel.org>
In-Reply-To: <20121023055127.GA24239@kernel.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 10/23/2012 01:51 AM, Shaohua Li wrote:

> I have no strong point against the global state method. But I'd agree making the
> heuristic simple is preferred currently. I'm happy about the patch if the '+1'
> is removed.

Without the +1, how will you figure out when to re-enable readahead?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
