Date: Wed, 12 Mar 2003 18:16:01 -0500 (EST)
From: Rik van Riel <riel@surriel.com>
Subject: Re: [PATCH 2.5.64-mm5] objrmap fix for nonlinear
In-Reply-To: <110230000.1047509378@baldur.austin.ibm.com>
Message-ID: <Pine.LNX.4.44.0303121814560.3890-100000@dhcp64-226.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <Pine.LNX.4.44.0303121814562.3890@dhcp64-226.boston.redhat.com>
Content-Disposition: INLINE
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dmccr@us.ibm.com>
Cc: Andrew Morton <akpm@digeo.com>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 12 Mar 2003, Dave McCracken wrote:

> I've convinced myself that anyone else trying to touch those areas will
> block on the locks I already hold.  It survives the abuse test I've thrown
> at it.

Could I get a copy of that abuse test ? ;))

(if possible to riel-at-redhat.com, which I'm not throwing
out to the spammers since I don't control the spam filtering
for that address)

thanks,

Rik (who wants to port some of the partial object rmap code to 2.4)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
