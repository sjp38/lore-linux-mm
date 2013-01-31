Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id AF4836B0005
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 18:59:41 -0500 (EST)
Date: Thu, 31 Jan 2013 15:59:40 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/6] fs: Take mapping lock in generic read paths
Message-Id: <20130131155940.7b1f8e0e.akpm@linux-foundation.org>
In-Reply-To: <1359668994-13433-3-git-send-email-jack@suse.cz>
References: <1359668994-13433-1-git-send-email-jack@suse.cz>
	<1359668994-13433-3-git-send-email-jack@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Thu, 31 Jan 2013 22:49:50 +0100
Jan Kara <jack@suse.cz> wrote:

> Add mapping lock to struct address_space and grab it in all paths
> creating pages in page cache to read data into them. That means buffered
> read, readahead, and page fault code.

Boy, this does look expensive in both speed and space.

As you pointed out in [0/n], it's 2-3%.  As always with pagecache
stuff, the cost of filling the page generally swamps any inefficiencies
in preparing that page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
