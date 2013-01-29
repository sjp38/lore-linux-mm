Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id E9D066B0002
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 18:07:31 -0500 (EST)
Date: Tue, 29 Jan 2013 15:07:29 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv4 7/7] zswap: add documentation
Message-Id: <20130129150729.0f45c0c5.akpm@linux-foundation.org>
In-Reply-To: <1359495627-30285-8-git-send-email-sjenning@linux.vnet.ibm.com>
References: <1359495627-30285-1-git-send-email-sjenning@linux.vnet.ibm.com>
	<1359495627-30285-8-git-send-email-sjenning@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Tue, 29 Jan 2013 15:40:27 -0600
Seth Jennings <sjenning@linux.vnet.ibm.com> wrote:

> This patch adds the documentation file for the zswap functionality

OK, that sort-of covers some of the things I asked about, although it
is rather skimpy.

It doesn't address pagefaults at all!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
