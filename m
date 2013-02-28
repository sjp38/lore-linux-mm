Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id C767B6B0006
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 17:14:45 -0500 (EST)
Date: Thu, 28 Feb 2013 14:14:41 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH v2 2/2] mm: tuning hardcoded reserved memory
Message-Id: <20130228141441.7dbd19be.akpm@linux-foundation.org>
In-Reply-To: <20130227210925.GB8429@localhost.localdomain>
References: <20130227210925.GB8429@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Shewmaker <agshew@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 27 Feb 2013 16:09:25 -0500
Andrew Shewmaker <agshew@gmail.com> wrote:

> Add a rootuser_reserve_pages knob to allow admins of large memory 
> systems running with overcommit disabled to change the hardcoded 
> memory reserve to something other than 3%.
> 
> Signed-off-by: Andrew Shewmaker <agshew@gmail.com>
> 
> ---
> 
> Patch based off of mmotm git tree as of February 27th.
> 
> I set rootuser_reserve pages to be a default of 1000, and I suppose 
> I should have initialzed similarly to the way min_free_kbytes is, 
> scaling it with the size of the box. However, I wanted to get a 
> simple version of this patch out for feedback to see if it has any 
> chance of acceptance or if I need to take an entirely different 
> approach.
> 
> Any feedback will be appreciated!

Seems reasonable.

Yes, we should scale the initial value according to the machine size in
some fashion.

btw, both these patches had the same title.  Please avoid this.
Documentation/SubmittingPatches section 15 has all the details.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
