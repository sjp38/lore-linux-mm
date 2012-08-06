Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 13AF56B0044
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 15:01:29 -0400 (EDT)
Date: Mon, 6 Aug 2012 16:00:54 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH v5 1/3] mm: introduce compaction and migration for virtio
 ballooned pages
Message-ID: <20120806190053.GA3968@t510.redhat.com>
References: <cover.1344259054.git.aquini@redhat.com>
 <212b5297df32cb4e3f60d5b76a8cb0629d328a4e.1344259054.git.aquini@redhat.com>
 <50200F1F.7060605@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50200F1F.7060605@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>

On Mon, Aug 06, 2012 at 02:38:23PM -0400, Rik van Riel wrote:
> On 08/06/2012 09:56 AM, Rafael Aquini wrote:
> 
> >@@ -846,6 +861,21 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
> >  			goto out;
> >
> >  	rc = __unmap_and_move(page, newpage, force, offlining, mode);
> >+
> >+	if (unlikely(is_balloon_page(newpage)&&
> >+		     balloon_compaction_enabled())) {
> 
> Could that be collapsed into one movable_balloon_page(newpage) function
> call?
> 
Keeping is_balloon_page() as is, and itroducing this new movable_balloon_page()
function call, or just doing a plain rename, as Andrew has first suggested?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
