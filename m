Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id E41586B0032
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 13:22:41 -0400 (EDT)
Date: Tue, 23 Jul 2013 12:22:30 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: zswap: add runtime enable/disable
Message-ID: <20130723172230.GA5820@medulla.variantweb.net>
References: <1374521642-25478-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <20130722232529.GA23208@hacker.(null)>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130722232529.GA23208@hacker.(null)>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@sr71.net>, Bob Liu <lliubbo@gmail.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jul 23, 2013 at 07:25:29AM +0800, Wanpeng Li wrote:
> On Mon, Jul 22, 2013 at 02:34:02PM -0500, Seth Jennings wrote:
> >@@ -612,7 +612,7 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
> > 	u8 *src, *dst;
> > 	struct zswap_header *zhdr;
> >
> >-	if (!tree) {
> >+	if (!zswap_enabled || !tree) {
> 
> If this check should be added to all hooks in zswap?

No.  We want to continue to allow loads and invalidates since zswap will
still have pages stored it in.  It just won't accept any new pages.

Seth

> 
> > 		ret = -ENODEV;
> > 		goto reject;
> > 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
