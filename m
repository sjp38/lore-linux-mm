Date: Fri, 14 Jul 2000 11:18:02 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: vmtruncate question
Message-ID: <20000714111802.R3113@redhat.com>
References: <396BCFA8.C033D94A@uow.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <396BCFA8.C033D94A@uow.edu.au>; from andrewm@uow.edu.au on Wed, Jul 12, 2000 at 01:53:44AM +0000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <andrewm@uow.edu.au>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Jul 12, 2000 at 01:53:44AM +0000, Andrew Morton wrote:
> The flushes which surround the second call to zap_page_range()
> would appear to be flushing more memory than is to be
> zapped.  Is this correct, or should it be:

Yes, I noticed that too: I think you're right.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
