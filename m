Content-Type: text/plain; charset=US-ASCII
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: [RFC] using writepage to start io
Date: Wed, 1 Aug 2001 03:01:17 +0200
References: <233400000.996606471@tiny>
In-Reply-To: <233400000.996606471@tiny>
MIME-Version: 1.0
Message-Id: <01080103011705.00303@starship>
Content-Transfer-Encoding: 7BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Mason <mason@suse.com>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

Hi, Chris

On Tuesday 31 July 2001 21:07, Chris Mason wrote:
> I had to keep some of the flush_dirty_buffer calls as page_launder
> wasn't triggering enough i/o on its own.  What I'd like to do now is
> experiment with changing bdflush to only write pages off the inactive
> dirty lists.

Will kupdate continue to enforce the "no dirty buffer older than 
XX" guarantee?

--
Daniel
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
