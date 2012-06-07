Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 138F56B0062
	for <linux-mm@kvack.org>; Thu,  7 Jun 2012 14:49:56 -0400 (EDT)
Date: Thu, 7 Jun 2012 14:42:53 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH 01/11] mm: frontswap: remove casting from function calls
 through ops structure
Message-ID: <20120607184253.GD9472@phenom.dumpdata.com>
References: <1338980115-2394-1-git-send-email-levinsasha928@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1338980115-2394-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: dan.magenheimer@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jun 06, 2012 at 12:55:05PM +0200, Sasha Levin wrote:
> Removes unneeded casts.

On the cover letter can you do a git diff --stat linus/master.. so
that at a quick glance I can figure out how much we are shaving off
the code?

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
