Date: Tue, 7 Aug 2001 15:23:18 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [RFC] using writepage to start io
Message-ID: <20010807152318.H4036@redhat.com>
References: <01080623182601.01864@starship> <5.1.0.14.2.20010807123805.027f19a0@pop.cus.cam.ac.uk> <01080715292606.02365@starship>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <01080715292606.02365@starship>; from phillips@bonn-fries.net on Tue, Aug 07, 2001 at 03:29:26PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@bonn-fries.net>
Cc: Anton Altaparmakov <aia21@cam.ac.uk>, "Stephen C. Tweedie" <sct@redhat.com>, Chris Mason <mason@suse.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Aug 07, 2001 at 03:29:26PM +0200, Daniel Phillips wrote:

>   Ext3 has its own writeback daemon

Ext3 has a daemon to schedule commits to the journal, but it uses the
normal IO scheduler for unforced writebacks.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
