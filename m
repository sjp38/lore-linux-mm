Date: Tue, 13 Feb 2001 10:08:37 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [PATCH] guard mm->rss with page_table_lock (241p11)
Message-ID: <20010213100837.O20696@redhat.com>
References: <20010129222337.F603@jaquet.dk> <Pine.LNX.4.21.0101291929120.1321-100000@duckman.distro.conectiva> <20010129224311.H603@jaquet.dk> <3A88A6ED.6B51BCA9@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3A88A6ED.6B51BCA9@mvista.com>; from george@mvista.com on Mon, Feb 12, 2001 at 07:15:57PM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: george anzinger <george@mvista.com>
Cc: Rasmus Andersen <rasmus@jaquet.dk>, Rik van Riel <riel@conectiva.com.br>, torvalds@transmeta.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Feb 12, 2001 at 07:15:57PM -0800, george anzinger wrote:
> Excuse me if I am off base here, but wouldn't an atomic operation be
> better here.  There are atomic inc/dec and add/sub macros for this.  It
> just seems that that is all that is needed here (from inspection of the
> patch).

The counter-argument is that we already hold the page table lock in
the vast majority of places where the rss is modified, so overall it's
cheaper to avoid the extra atomic update.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
