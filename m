Date: Sat, 28 Sep 2002 22:11:41 -0400
From: Zach Brown <zab@zabbo.net>
Subject: Re: suspect list_empty( {NULL, NULL} )
Message-ID: <20020928221141.E13817@bitchcake.off.net>
References: <20020928205836.C13817@bitchcake.off.net> <3D96580D.A0F803BC@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3D96580D.A0F803BC@digeo.com>; from akpm@digeo.com on Sat, Sep 28, 2002 at 06:31:57PM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > $22 = {host = 0xc03b6e00
> 
> That's swapper_space.

ah, of course.  that does seem to fix it, thanks.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
