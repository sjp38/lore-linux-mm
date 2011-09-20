Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 911B79000BD
	for <linux-mm@kvack.org>; Tue, 20 Sep 2011 14:38:13 -0400 (EDT)
Message-ID: <4E78DD8B.1020605@redhat.com>
Date: Tue, 20 Sep 2011 14:38:03 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 3/4] mm: filemap: pass __GFP_WRITE from grab_cache_page_write_begin()
References: <1316526315-16801-1-git-send-email-jweiner@redhat.com> <1316526315-16801-4-git-send-email-jweiner@redhat.com> <20110920142553.GA2593@infradead.org>
In-Reply-To: <20110920142553.GA2593@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Johannes Weiner <jweiner@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Dave Chinner <david@fromorbit.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Minchan Kim <minchan.kim@gmail.com>, Chris Mason <chris.mason@oracle.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, xfs@oss.sgi.com, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 09/20/2011 10:25 AM, Christoph Hellwig wrote:
> In addition to regular write shouldn't __do_fault and do_wp_page also
> calls this if they are called on file backed mappings?
>

Probably not do_wp_page since it always creates an
anonymous page, which are not very relevant to the
dirty page cache accounting.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
