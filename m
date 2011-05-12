Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 09F086B0024
	for <linux-mm@kvack.org>; Thu, 12 May 2011 13:06:31 -0400 (EDT)
Received: by gwaa12 with SMTP id a12so830394gwa.14
        for <linux-mm@kvack.org>; Thu, 12 May 2011 10:06:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1305217843.2575.57.camel@mulgrave.site>
References: <1305127773-10570-1-git-send-email-mgorman@suse.de>
	<1305127773-10570-4-git-send-email-mgorman@suse.de>
	<alpine.DEB.2.00.1105120942050.24560@router.home>
	<1305213359.2575.46.camel@mulgrave.site>
	<alpine.DEB.2.00.1105121024350.26013@router.home>
	<1305214993.2575.50.camel@mulgrave.site>
	<20110512154649.GB4559@redhat.com>
	<1305216023.2575.54.camel@mulgrave.site>
	<alpine.DEB.2.00.1105121121120.26013@router.home>
	<1305217843.2575.57.camel@mulgrave.site>
Date: Thu, 12 May 2011 20:06:27 +0300
Message-ID: <BANLkTi=MD+voG1i7uDyueV22_daGHPRdqw@mail.gmail.com>
Subject: Re: [PATCH 3/3] mm: slub: Default slub_max_order to 0
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@hansenpartnership.com>
Cc: Christoph Lameter <cl@linux.com>, Dave Jones <davej@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Thu, May 12, 2011 at 7:30 PM, James Bottomley
<James.Bottomley@hansenpartnership.com> wrote:
> So suggest an alternative root cause and a test to expose it.

Is your .config available somewhere, btw?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
