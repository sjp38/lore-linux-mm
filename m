Date: Tue, 13 May 2003 14:04:03 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Race between vmtruncate and mapped areas?
Message-ID: <20030513210403.GT8978@holomorphy.com>
References: <154080000.1052858685@baldur.austin.ibm.com> <3EC15C6D.1040403@kolumbus.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3EC15C6D.1040403@kolumbus.fi>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mika Penttil? <mika.penttila@kolumbus.fi>
Cc: Dave McCracken <dmccr@us.ibm.com>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, May 13, 2003 at 11:58:21PM +0300, Mika Penttil? wrote:
> Isn't that what inode->i_sem is supposed to protect...?
> --Mika

It's already called under inode->i_sem. The trouble is that it's not
the ->i_sem but the ->page_lock that's taken by those it's racing
against.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
