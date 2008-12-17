Return-Path: <owner-linux-mm@kvack.org>
Date: Wed, 17 Dec 2008 19:34:28 +0100
From: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Subject: Re: test
Message-ID: <20081217183428.GB11815@logfs.org>
References: <20081215192319.GF10471@kvack.org> <20081217153312.GA11815@logfs.org> <20081217165233.GD4247@kvack.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20081217165233.GD4247@kvack.org>
Sender: owner-linux-mm@kvack.org
To: Benjamin LaHaise <bcrl@kvack.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 December 2008 11:52:33 -0500, Benjamin LaHaise wrote:
> Return-path: owner-linux-mm@kvack.org
> X-Spam-Checker-Version: SpamAssassin 3.1.7-deb (2006-10-05) on 
> 	longford.logfs.org
> X-Spam-Level: 
> X-Spam-Status: No, score=-2.6 required=5.0 tests=BAYES_00 autolearn=ham 
> 	version=3.1.7-deb
> Envelope-to: joern@lazybastard.org
> Delivery-date: Wed, 17 Dec 2008 17:54:29 +0100
> Received: from kanga.kvack.org ([205.233.56.17])
> 	by longford.logfs.org with esmtp (Exim 4.63)
> 	(envelope-from <owner-linux-mm@kvack.org>)
> 	id 1LCzfG-0003IM-0B
> 	for joern@lazybastard.org; Wed, 17 Dec 2008 17:54:26 +0100
> Received: by kanga.kvack.org (Postfix)
> 	id B33E96B00A6; Wed, 17 Dec 2008 11:52:33 -0500 (EST)
> Delivered-To: linux-mm-outgoing@kvack.org
> Received: by kanga.kvack.org (Postfix, from userid 0)
> 	id AD61D6B00A9; Wed, 17 Dec 2008 11:52:33 -0500 (EST)
> Delivered-To: linux-mm@kvack.org
> Received: by kanga.kvack.org (Postfix, from userid 63042)
> 	id 6B06B6B00A8; Wed, 17 Dec 2008 11:52:33 -0500 (EST)
> Date: Wed, 17 Dec 2008 11:52:33 -0500
> From: Benjamin LaHaise <bcrl@kvack.org>
> To: JA?rn Engel <joern@logfs.org>
> Cc: linux-mm@kvack.org
> Subject: Re: test
> Message-ID: <20081217165233.GD4247@kvack.org>
> References: <20081215192319.GF10471@kvack.org> <20081217153312.GA11815@logfs.org>
> Mime-Version: 1.0
> Content-Type: text/plain; charset=iso-8859-1
> Content-Disposition: inline
> In-Reply-To: <20081217153312.GA11815@logfs.org>
> User-Agent: Mutt/1.4.2.2i
> Sender: owner-linux-mm@kvack.org
> Precedence: bulk
> X-Loop: owner-majordomo@kvack.org
> Content-Transfer-Encoding: quoted-printable
> 
> The old mail server suffered from massive disk corruption last week, 
> so I took the chance to reinstall with a slightly more modern OS.

Fair enough.

> The mailing lists should be back to normal now.

I'm still struggling with the procmail recipe.  linux-mm has always been
the oddball amongst all mailing lists and continues to be so - just in a
different way now.  The old recipe looked for
* ^Original-Recipient:.*linux-mm@kvack.org
but that is gone now.  Then I changed it to
* ^X-Loop:.*list-linux-mm@kvack.org 
and this mail got misplaced[1], as it contained

> X-Loop: owner-majordomo@kvack.org

So maybe the right header to search for is this one.

> Sender: owner-linux-mm@kvack.org

Any chance that kvack can set either X-BeenThere: or X-Mailing-List: as
almost every other mailing list (the ppc ones set X-Original-To, alas)
does?

[1] The copy sent to me directly got properly sorted into my inbox.  But
the mailing list copy went into my "no clue" mailbox.

JA?rn

-- 
If you're willing to restrict the flexibility of your approach,
you can almost always do something better.
-- John Carmack
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
