Content-Type: text/plain; charset=US-ASCII
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: [RFC] using writepage to start io
Date: Tue, 7 Aug 2001 17:51:26 +0200
References: <01080623182601.01864@starship> <01080715292606.02365@starship> <20010807152318.H4036@redhat.com>
In-Reply-To: <20010807152318.H4036@redhat.com>
MIME-Version: 1.0
Message-Id: <01080717512607.02365@starship>
Content-Transfer-Encoding: 7BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Anton Altaparmakov <aia21@cam.ac.uk>, Chris Mason <mason@suse.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 07 August 2001 16:23, Stephen C. Tweedie wrote:
> Hi,
>
> On Tue, Aug 07, 2001 at 03:29:26PM +0200, Daniel Phillips wrote:
> >   Ext3 has its own writeback daemon
>
> Ext3 has a daemon to schedule commits to the journal, but it uses the
> normal IO scheduler for unforced writebacks.

Yes.  The currently favored journalling mode uses a writeback journal,
no?  In other words the ext3 journal daemon seems to fit the description
pretty well, especially if you have several of them on one disk.

--
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
