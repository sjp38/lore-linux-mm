Date: Wed, 23 Jan 2008 15:10:41 -0800
From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [kvm-devel] [RFC][PATCH 0/5] Memory merging driver for Linux
Message-ID: <20080123231037.GA3629@sequoia.sous-sol.org>
References: <4794C2E1.8040607@qumranet.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4794C2E1.8040607@qumranet.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Izik Eidus <izike@qumranet.com>
Cc: kvm-devel <kvm-devel@lists.sourceforge.net>, andrea@qumranet.com, avi@qumranet.com, dor.laor@qumranet.com, linux-mm@kvack.org, yaniv@qumranet.com
List-ID: <linux-mm.kvack.org>

* Izik Eidus (izike@qumranet.com) wrote:
> this module find this identical data (pages) and merge them into one 
> single page
> this new page is write protected so in any case the guest will try to 
> write to it do_wp_page will duplicate the page

What happens if you've merged more pages than you can recover on write
faults?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
