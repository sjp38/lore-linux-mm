Received: from wli by holomorphy with local (Exim 3.34 #1 (Debian))
	id 17uRYC-0002se-00
	for <linux-mm@kvack.org>; Wed, 25 Sep 2002 22:51:00 -0700
Date: Wed, 25 Sep 2002 22:51:00 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [1/13] add __GFP_NOKILL
Message-ID: <20020926055100.GU22942@holomorphy.com>
References: <20020926054220.GH22942@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <20020926054220.GH22942@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 25, 2002 at 10:42:20PM -0700, William Lee Irwin III wrote:
> --- linux-2.5.33/include/linux/gfp.h	2002-08-31 15:04:53.000000000 -0700
> +++ linux-2.5.33-mm5/include/linux/gfp.h	2002-09-08 19:52:51.000000000 -0700

Despite these lines saying 2.5.33, these are all rediffs of the 2.5.33-mm5
patches against 2.5.38-mm2.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
