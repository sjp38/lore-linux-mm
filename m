Date: Sat, 11 Jan 2003 17:57:56 -0500
From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: 2.5.56-mm1
Message-ID: <20030111225756.GA13330@gtf.org>
References: <200301111443.08527.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200301111443.08527.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@math.psu.edu
List-ID: <linux-mm.kvack.org>

On Sat, Jan 11, 2003 at 02:43:08PM -0800, Andrew Morton wrote:
> - dcache-RCU.
> 
>   This was recently updated to fix a rename race.  It's quite stable.  I'm
>   not sure where we stand wrt merging it now.  Al seems to have disappeared.

I talked to him in person last week, and this was one of the topics of
discussion.  He seemed to think it was fundamentally unfixable.  He
proceed to explain why, and then explained the scheme he worked out to
improve things.  Unfortunately my memory cannot do justice to the
details.

Next time he explains it, I will write it down :)

Sorry for so lame a data point :)

	Jeff




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
